part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

final class ChatLoadRequested extends ChatEvent {
  final String taskId;
  const ChatLoadRequested(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

final class ChatMessageSent extends ChatEvent {
  final String messageText;
  const ChatMessageSent(this.messageText);

  @override
  List<Object?> get props => [messageText];
}

/// Loads the worker ↔ dispatcher support conversation (no task context).
final class ChatSupportLoadRequested extends ChatEvent {
  const ChatSupportLoadRequested();
}

/// Fired by the periodic timer to fetch new messages from the backend.
final class ChatPolled extends ChatEvent {
  const ChatPolled();
}
