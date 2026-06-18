import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asar_field_worker/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/chat_remote_datasource.dart';
import '../../../data/repositories/chat_repository_impl.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../widgets/chat/chat_bubble.dart';

class SupportChatScreen extends StatelessWidget {
  const SupportChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatBloc(
        chatRepository: ChatRepositoryImpl(remote: ChatRemoteDataSource()),
      )..add(const ChatSupportLoadRequested()),
      child: const _SupportChatView(),
    );
  }
}

class _SupportChatView extends StatelessWidget {
  const _SupportChatView();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.operationalBlue,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.supportChatTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'IBMPlexSans',
              ),
            ),
            Text(
              l.supportChatSubtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontFamily: 'IBMPlexSans',
              ),
            ),
          ],
        ),
      ),
      body: const _SupportBody(),
    );
  }
}

class _SupportBody extends StatefulWidget {
  const _SupportBody();

  @override
  State<_SupportBody> createState() => _SupportBodyState();
}

class _SupportBodyState extends State<_SupportBody> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

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
          ? const _EmptySupportView()
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: state.messages[index]);
              },
            ),
      ChatError() => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.onSurfaceMuted,
                fontFamily: 'IBMPlexSans',
                fontSize: 14,
              ),
            ),
          ),
        ),
    };
  }

  Widget _buildInputBar(BuildContext context, ChatState state) {
    final canSend = state is ChatLoaded && !state.isSending;
    final l = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        10 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: const Border(top: BorderSide(color: AppColors.divider)),
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
                decoration: InputDecoration(
                  hintText: l.supportChatHint,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                    borderSide: BorderSide(
                        color: AppColors.operationalBlue, width: 1.5,),
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

class _EmptySupportView extends StatelessWidget {
  const _EmptySupportView();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.headset_mic_outlined,
              size: 56,
              color: AppColors.operationalBlue.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l.supportChatEmpty,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 14,
                color: AppColors.onSurfaceMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
