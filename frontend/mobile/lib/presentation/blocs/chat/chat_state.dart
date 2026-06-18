part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

final class ChatInitial extends ChatState {
  const ChatInitial();
}

final class ChatLoading extends ChatState {
  const ChatLoading();
}

final class ChatLoaded extends ChatState {
  final String conversationId;
  final List<MessageEntity> messages;
  final bool isSending;

  const ChatLoaded({
    required this.conversationId,
    required this.messages,
    this.isSending = false,
  });

  ChatLoaded copyWith({List<MessageEntity>? messages, bool? isSending}) {
    return ChatLoaded(
      conversationId: conversationId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [conversationId, messages, isSending];
}

final class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
