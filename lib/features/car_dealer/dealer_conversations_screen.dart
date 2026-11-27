import 'package:flutter/material.dart';

import '../../core/services/active_role_session.dart';
import '../../core/widgets/logout_confirmation_dialog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_shared_components.dart';
import '../account_selection/account_type_selection_screen.dart';
import '../customer/services/customer_local_store.dart';

/// Dealer-facing view of customer conversations. Conversations only appear here
/// after a customer sends an inquiry from a dealer or car detail page.
class DealerConversationsScreen extends StatefulWidget {
  const DealerConversationsScreen({super.key});

  @override
  State<DealerConversationsScreen> createState() =>
      _DealerConversationsScreenState();
}

class _DealerConversationsScreenState extends State<DealerConversationsScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    CustomerLocalStore.instance.initialize();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('المحادثات'),
          actions: [
            IconButton(
              tooltip: 'تسجيل الخروج',
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: CustomerLocalStore.instance,
          builder: (context, _) {
            final conversations = CustomerLocalStore.instance.conversations
                .where((item) =>
                    '${item.dealerName} ${item.carName} ${item.lastMessage}'
                        .contains(_query))
                .toList();
            return ListView(padding: const EdgeInsets.all(16), children: [
              const Text('قائمة المحادثات',
                  textAlign: TextAlign.right, style: AppTextStyles.heading),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  hintText: 'ابحث في المحادثات',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              if (conversations.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(28),
                  child: Text('لا توجد محادثات واردة حالياً.',
                      textAlign: TextAlign.center, style: AppTextStyles.body),
                ),
              for (final conversation in conversations)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.mint,
                        child:
                            Icon(Icons.person_outline, color: AppColors.brand),
                      ),
                      title: Text(
                        conversation.customerName.isEmpty
                            ? 'عميل'
                            : conversation.customerName,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodyMedium,
                      ),
                      subtitle: Text(
                        '${conversation.carName.isEmpty ? '' : '${conversation.carName} • '}${conversation.lastMessage}',
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                      trailing: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(conversation.updatedAt,
                            style: AppTextStyles.caption),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              DealerChatRoomScreen(conversation: conversation),
                        ),
                      ),
                    ),
                  ),
                ),
            ]);
          },
        ),
      );

  Future<void> _logout() async {
    final confirm = await showLogoutConfirmationDialog(context);
    if (confirm != true || !mounted) return;
    await ActiveRoleSessionStore.instance.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
          builder: (_) => const AccountTypeSelectionScreen()),
      (_) => false,
    );
  }
}

class DealerChatRoomScreen extends StatefulWidget {
  const DealerChatRoomScreen({super.key, required this.conversation});
  final CustomerConversation conversation;

  @override
  State<DealerChatRoomScreen> createState() => _DealerChatRoomScreenState();
}

class _DealerChatRoomScreenState extends State<DealerChatRoomScreen> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text;
    _controller.clear();
    await CustomerLocalStore.instance
        .sendMessage(widget.conversation.id, text, fromCustomer: false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(widget.conversation.customerName.isEmpty
                ? 'محادثة العميل'
                : widget.conversation.customerName)),
        body: Column(children: [
          if (widget.conversation.carName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: AppCard(
                child: Row(children: [
                  const Icon(Icons.directions_car_outlined,
                      color: AppColors.brand),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(widget.conversation.carName,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodyMedium),
                  ),
                  const AppStatusBadge('استفسار سيارة'),
                ]),
              ),
            ),
          Expanded(
            child: AnimatedBuilder(
              animation: CustomerLocalStore.instance,
              builder: (context, _) {
                final messages = CustomerLocalStore
                        .instance.messages[widget.conversation.id] ??
                    [];
                if (messages.isEmpty) {
                  return const Center(
                      child: Text('لا توجد رسائل في هذه المحادثة بعد.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body));
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final message in messages)
                      Align(
                        alignment: message.fromCustomer
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(maxWidth: 290),
                          decoration: BoxDecoration(
                            color: message.fromCustomer
                                ? AppColors.white
                                : AppColors.brand,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: message.fromCustomer
                                    ? AppColors.border
                                    : AppColors.brand),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(message.text,
                                  textAlign: TextAlign.right,
                                  style: message.fromCustomer
                                      ? AppTextStyles.body
                                      : AppTextStyles.body
                                          .copyWith(color: AppColors.white)),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(message.sentAt,
                                    textAlign: TextAlign.left,
                                    style: AppTextStyles.caption.copyWith(
                                        color: message.fromCustomer
                                            ? AppColors.secondary
                                            : AppColors.white
                                                .withValues(alpha: .8))),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Expanded(
                    child: TextField(
                        controller: _controller,
                        decoration:
                            const InputDecoration(hintText: 'اكتب ردك'))),
                IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send, color: AppColors.brand)),
              ]),
            ),
          ),
        ]),
      );
}
