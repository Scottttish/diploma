import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/entities/sender_type.dart';
import '../../../domain/repositories/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

/// Manages the live chat view for a single task conversation.
///
/// We use polling rather than WebSocket here because the FastAPI backend
/// relays messages through the Telegram bot asynchronously — a simple
/// GET every N seconds is sufficient and keeps the connection model simple.
/// If the backend later adds WebSocket support, only this BLoC needs to change.
final class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  Timer? _pollTimer;
  final _uuid = const Uuid();

  ChatBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(const ChatInitial()) {
    on<ChatLoadRequested>(_onLoad);
    on<ChatSupportLoadRequested>(_onSupportLoad);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatPolled>(_onPolled);
  }

  Future<void> _onSupportLoad(
    ChatSupportLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    try {
      final conversation = await _chatRepository.getSupportConversation();
      final messages = await _chatRepository.fetchMessages(conversation.id);
      emit(ChatLoaded(conversationId: conversation.id, messages: messages));
      _startPolling();
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoad(
    ChatLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    try {
      final conversation =
          await _chatRepository.fetchConversation(event.taskId);
      final messages =
          await _chatRepository.fetchMessages(conversation.id);

      emit(ChatLoaded(
        conversationId: conversation.id,
        messages: messages,
      ));

      _startPolling();
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatLoaded) return;

    // Add an optimistic local message so the UI responds instantly.
    // The isPending flag shows a small "sending" indicator on the bubble.
    final optimistic = MessageEntity(
      id: _uuid.v4(),
      conversationId: current.conversationId,
      senderType: SenderType.worker,
      messageText: event.messageText,
      sentAt: DateTime.now(),
      isPending: true,
    );

    emit(current.copyWith(
      messages: [...current.messages, optimistic],
      isSending: true,
    ));

    try {
      final confirmed = await _chatRepository.sendMessage(
        conversationId: current.conversationId,
        messageText: event.messageText,
      );

      // Replace the local optimistic entry with the server-confirmed message.
      final updatedMessages = current.messages
          .where((m) => m.id != optimistic.id)
          .toList()
        ..add(confirmed);

      emit(current.copyWith(messages: updatedMessages, isSending: false));
    } catch (e) {
      // Remove the optimistic message on failure so the UI doesn't lie.
      final rolledBack =
          current.messages.where((m) => m.id != optimistic.id).toList();
      emit(current.copyWith(messages: rolledBack, isSending: false));
    }
  }

  Future<void> _onPolled(
    ChatPolled event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatLoaded) return;

    try {
      final messages =
          await _chatRepository.fetchMessages(current.conversationId);
      emit(current.copyWith(messages: messages));
    } catch (_) {
      // Silent poll failure — we don't want to disrupt the screen.
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: AppConstants.chatPollIntervalSeconds),
      (_) => add(const ChatPolled()),
    );
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
