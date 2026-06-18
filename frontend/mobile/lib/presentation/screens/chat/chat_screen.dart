import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../widgets/chat/chat_bubble.dart';

/// The "Chat" tab inside the Work Order detail screen.
/// Field workers talk directly to the client here — the backend routes
/// the message through the Telegram bot transparently.
class ChatScreen extends StatefulWidget {
  final String taskId;

  const ChatScreen({super.key, required this.taskId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with AutomaticKeepAliveClientMixin {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(ChatLoadRequested(widget.taskId));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatBloc>().add(ChatMessageSent(text));
    _inputController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatLoaded) _scrollToBottom();
      },
      builder: (context, state) {
        return Column(
          children: [
            Expanded(child: _buildMessageList(state)),
            _buildInputBar(context, state),
          ],
        );
      },
    );
  }

  Widget _buildMessageList(ChatState state) {
    return switch (state) {
      ChatInitial() || ChatLoading() => const Center(
          child: CircularProgressIndicator(color: AppColors.operationalBlue),
        ),
      ChatLoaded() => state.messages.isEmpty
          ? const _EmptyChatView()
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: state.messages[index]);
              },
            ),
      ChatError() => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat_bubble_outline,
                  size: 40, color: AppColors.onSurfaceMuted),
              const SizedBox(height: 12),
              Text(
                state.message,
                style: const TextStyle(
                  color: AppColors.onSurfaceMuted,
                  fontFamily: 'IBMPlexSans',
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
    };
  }

  Widget _buildInputBar(BuildContext context, ChatState state) {
    final canSend = state is ChatLoaded && !state.isSending;

    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        10 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                minLines: 1,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  hintText: 'Message client or dispatcher...',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                    borderSide: BorderSide(
                        color: AppColors.operationalBlue, width: 1.5),
                  ),
                ),
                onSubmitted: canSend ? (_) => _onSend() : null,
              ),
            ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: canSend
                  ? _SendButton(key: const ValueKey('send'), onTap: _onSend)
                  : const SizedBox(
                      key: ValueKey('loading'),
                      width: 42,
                      height: 42,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.operationalBlue,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SendButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.operationalBlue,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(Icons.send_rounded, color: Colors.white, size: 19),
        ),
      ),
    );
  }
}

class _EmptyChatView extends StatelessWidget {
  const _EmptyChatView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined,
              size: 48, color: AppColors.operationalBlue.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'No messages yet.\nSend the first message to the client.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 14,
              color: AppColors.onSurfaceMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
