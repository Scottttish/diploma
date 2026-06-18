import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/entities/sender_type.dart';

/// Renders a single message bubble.
///
/// We check the specific sender type here to decide which side of the screen
/// to pin the chat bubble — worker messages always go right, everyone else left.
/// The dispatcher variant gets a distinct background so it doesn't visually
/// blend with client messages when both appear in the same thread.
class ChatBubble extends StatelessWidget {
  final MessageEntity message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isOutgoing = message.senderType.isOutgoing;

    return Padding(
      padding: EdgeInsets.only(
        left: isOutgoing ? 64 : 0,
        right: isOutgoing ? 0 : 64,
        top: 4,
        bottom: 4,
      ),
      child: Align(
        alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isOutgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isOutgoing) _SenderLabel(senderType: message.senderType),
            _BubbleBody(message: message, isOutgoing: isOutgoing),
          ],
        ),
      ),
    );
  }
}

class _SenderLabel extends StatelessWidget {
  final SenderType senderType;

  const _SenderLabel({required this.senderType});

  @override
  Widget build(BuildContext context) {
    final label = switch (senderType) {
      SenderType.client => 'Client',
      SenderType.dispatcher => 'Dispatcher',
      SenderType.worker => '',
    };

    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 2),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceMuted,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _BubbleBody extends StatelessWidget {
  final MessageEntity message;
  final bool isOutgoing;

  const _BubbleBody({required this.message, required this.isOutgoing});

  Color get _backgroundColor {
    if (isOutgoing) return AppColors.bubbleOutgoing;
    if (message.senderType == SenderType.dispatcher) {
      return AppColors.bubbleDispatcher;
    }
    return AppColors.bubbleIncoming;
  }

  Color get _textColor {
    return isOutgoing
        ? AppColors.onBubbleOutgoing
        : AppColors.onBubbleIncoming;
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(14),
          topRight: const Radius.circular(14),
          bottomLeft: Radius.circular(isOutgoing ? 14 : 2),
          bottomRight: Radius.circular(isOutgoing ? 2 : 14),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            isOutgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            message.messageText,
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _textColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeFormat.format(message.sentAt),
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 10,
                  color: _textColor.withOpacity(0.6),
                ),
              ),
              if (message.isPending) ...[
                const SizedBox(width: 4),
                SizedBox(
                  width: 9,
                  height: 9,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: _textColor.withOpacity(0.5),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
