import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/core/theme/text_style_helper.dart';
import 'package:islami/features/assistant/data/datasources/assistant_remote_data_source.dart';
import 'package:islami/features/assistant/data/repositories/assistant_repository_impl.dart';
import 'package:islami/features/assistant/domain/usecases/send_message.dart';
import 'package:islami/features/assistant/presentation/cubit/ai_chat_cubit.dart';
import 'package:islami/features/assistant/presentation/cubit/ai_chat_state.dart';
import '../widgets/chat_disclaimer.dart';
import '../widgets/chat_input_area.dart';
import '../widgets/chat_message_list.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key, this.onMenuTap});
  final VoidCallback? onMenuTap;
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  void _send(BuildContext context) {
    final cubit = context.read<AiChatCubit>();
    final text = _inputController.text.trim();
    if (text.isEmpty || cubit.state.isLoading) return;
    _inputController.clear();
    cubit.send(text);
  }

  Future<void> _confirmClear(BuildContext context) async {
    if (context.read<AiChatCubit>().state.isEmpty) return;
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final palette = dialogContext.palette;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: palette.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: palette.primary.withValues(alpha: 0.3)),
            ),
            title: Text('مسح المحادثة', style: TextStylesHelper.largeLabelTextStyle(dialogContext)),
            content: Text('هل تريد مسح جميع الرسائل؟', style: TextStylesHelper.mediumLabelTextStyle(dialogContext, textColor: palette.onBackground)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text('إلغاء', style: TextStylesHelper.mediumLabelTextStyle(dialogContext, textColor: palette.onBackground.withValues(alpha: 0.7)))),
              TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text('مسح', style: TextStylesHelper.mediumLabelTextStyle(dialogContext))),
            ],
          ),
        );
      },
    );
    if (shouldClear == true && mounted) context.read<AiChatCubit>().clear();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AiChatCubit(SendMessage(AssistantRepositoryImpl(AssistantRemoteDataSource()))),
    child: Builder(builder: (scopedContext) => BlocListener<AiChatCubit, AiChatState>(
      listenWhen: (previous, current) => previous.messages.length != current.messages.length,
      listener: (_, __) => _scrollDown(),
      child: _buildScreen(scopedContext),
    )),
  );

  Widget _buildScreen(BuildContext context) {
    final palette = context.palette;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: palette.background,
        appBar: AppBar(
          backgroundColor: palette.background,
          foregroundColor: palette.primary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(tooltip: 'القائمة الرئيسية', onPressed: widget.onMenuTap, icon: const Icon(Icons.menu_rounded)),
          title: Text('اسأل المساعد', style: TextStylesHelper.largeLabelTextStyle(context)),
          actions: [BlocBuilder<AiChatCubit, AiChatState>(builder: (context, state) => state.isEmpty
            ? const SizedBox.shrink()
            : IconButton(tooltip: 'مسح المحادثة', onPressed: () => _confirmClear(context), icon: const Icon(Icons.delete_outline_rounded)))],
        ),
        body: Column(children: [
          const ChatDisclaimer(),
          Expanded(child: BlocBuilder<AiChatCubit, AiChatState>(builder: (context, state) => ChatMessageList(
            messages: state.messages, isLoading: state.isLoading, scrollController: _scrollController))),
          BlocBuilder<AiChatCubit, AiChatState>(builder: (context, state) => ChatInputArea(
            controller: _inputController, isLoading: state.isLoading, onSend: () => _send(context))),
        ]),
      ),
    );
  }
}
