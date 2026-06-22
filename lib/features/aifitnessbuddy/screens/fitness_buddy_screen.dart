import 'package:flutter/material.dart';

import '../../../core/storage/api_session_store.dart';
import '../../../screens/dashboard_screen.dart';
import '../data/fitness_buddy_api.dart';

class FitnessBuddyFeatureScreen extends StatefulWidget {
  static const routeName = '/fitness-buddy';

  const FitnessBuddyFeatureScreen({super.key});

  @override
  State<FitnessBuddyFeatureScreen> createState() =>
      _FitnessBuddyFeatureScreenState();
}

class _FitnessBuddyFeatureScreenState extends State<FitnessBuddyFeatureScreen> {
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  bool isTyping = false;
  bool isSending = false;

  int userId = 0;
  int? chatId;

  final List<Map<String, dynamic>> messages = [
    {
      'message_id': null,
      'role': 'bot',
      'text':
          'Hi, I’m Fitness Buddy.\n\nTell me what you need today—BMI help, calories, workout guidance, motivation, or wellness tips.',
    },
  ];

  @override
  void initState() {
    super.initState();
    loadChat();
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> loadChat() async {
    final savedUserId = await ApiSessionStore.getUserId();

    debugPrint('AI BUDDY USER ID FROM API SESSION: $savedUserId');

    if (!mounted) return;

    setState(() {
      userId = savedUserId;
    });

    if (userId <= 0) {
      debugPrint('AI BUDDY USER ID NOT FOUND');
      return;
    }

    try {
      final startedChatId = await FitnessBuddyApi.startChat(userId: userId);

      if (!mounted) return;

      setState(() {
        chatId = startedChatId;
      });

      await loadMessages();
    } catch (e) {
      debugPrint('LOAD CHAT ERROR: $e');
    }
  }

  Future<void> loadMessages() async {
    if (chatId == null || chatId == 0) return;

    try {
      final dbMessages = await FitnessBuddyApi.getMessages(chatId: chatId!);

      if (!mounted) return;

      if (dbMessages.isEmpty) return;

      setState(() {
        messages.clear();

        for (final item in dbMessages) {
          messages.add({
            'message_id':
                int.tryParse(item['message_id']?.toString() ?? '0') ?? 0,
            'role': item['role']?.toString() ?? 'bot',
            'text': cleanBotText(item['content']?.toString() ?? ''),
          });
        }
      });

      scrollToBottom();
    } catch (e) {
      debugPrint('LOAD MESSAGES ERROR: $e');
    }
  }

  String cleanBotText(String text) {
    return text
        .replaceAll('[b]', '')
        .replaceAll('[/b]', '')
        .replaceAll('[i]', '')
        .replaceAll('[/i]', '')
        .replaceAll('❌ ', '')
        .trim();
  }

  void showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> sendMessage([String? preset]) async {
    if (isSending) return;

    final text = (preset ?? messageController.text).trim();

    if (text.isEmpty) {
      return;
    }

    if (userId <= 0) {
      await loadChat();
    }

    if (userId <= 0) {
      showError('User account was not found. Please login again.');
      return;
    }

    final userMessageIndex = messages.length;

    setState(() {
      isSending = true;
      isTyping = true;
      messages.add({'message_id': null, 'role': 'user', 'text': text});
      messageController.clear();
    });

    scrollToBottom();

    try {
      final result = await FitnessBuddyApi.sendMessage(
        userId: userId,
        chatId: chatId,
        content: text,
      );

      if (!mounted) return;

      final newChatId = int.tryParse(result['chat_id'].toString()) ?? 0;
      final reply = cleanBotText(result['reply']?.toString() ?? '');

      final userMessageId =
          int.tryParse(result['user_message_id']?.toString() ?? '0') ?? 0;

      final botMessageId =
          int.tryParse(result['bot_message_id']?.toString() ?? '0') ?? 0;

      setState(() {
        if (newChatId > 0) {
          chatId = newChatId;
        }

        if (userMessageIndex < messages.length && userMessageId > 0) {
          messages[userMessageIndex]['message_id'] = userMessageId;
        }

        messages.add({
          'message_id': botMessageId,
          'role': 'bot',
          'text': reply.isEmpty
              ? 'Sorry, I could not prepare a response right now.'
              : reply,
        });

        isTyping = false;
        isSending = false;
      });

      scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isTyping = false;
        isSending = false;
      });

      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      showError(errorMessage);
    }
  }

  int asInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  Future<bool> confirmAction({
    required String title,
    required String message,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(
                confirmText,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  Future<void> deleteUserMessagePair(int userIndex) async {
    if (isSending) return;

    if (userIndex < 0 || userIndex >= messages.length) return;

    final selectedMessage = messages[userIndex];

    if (selectedMessage['role'] != 'user') return;

    final confirmed = await confirmAction(
      title: 'Delete message?',
      message:
          'This will delete your message and the AI response connected to it.',
      confirmText: 'Delete',
    );

    if (!confirmed) return;

    final indexesToRemove = <int>[userIndex];

    // Delete every AI reply after this user message until the next user message.
    // This is safer than checking only role == 'bot'.
    int nextIndex = userIndex + 1;

    while (nextIndex < messages.length) {
      final nextRole = messages[nextIndex]['role']?.toString().toLowerCase();

      if (nextRole == 'user') {
        break;
      }

      indexesToRemove.add(nextIndex);
      nextIndex++;
    }

    final messageIds = indexesToRemove
        .map((index) => asInt(messages[index]['message_id']))
        .where((id) => id > 0)
        .toList();

    try {
      for (final messageId in messageIds) {
        await FitnessBuddyApi.deleteMessage(messageId: messageId);
      }

      if (!mounted) return;

      setState(() {
        indexesToRemove.sort((a, b) => b.compareTo(a));

        for (final index in indexesToRemove) {
          if (index >= 0 && index < messages.length) {
            messages.removeAt(index);
          }
        }
      });
    } catch (e) {
      showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> deleteEntireConversation() async {
    if (isSending) return;

    final confirmed = await confirmAction(
      title: 'Delete conversation?',
      message: 'This will delete the entire AI Fitness Buddy conversation.',
      confirmText: 'Delete all',
    );

    if (!confirmed) return;

    final messageIds = messages
        .map((message) => asInt(message['message_id']))
        .where((id) => id > 0)
        .toList();

    try {
      for (final messageId in messageIds) {
        await FitnessBuddyApi.deleteMessage(messageId: messageId);
      }

      if (!mounted) return;

      setState(() {
        isTyping = false;
        isSending = false;

        messages.clear();
        messages.add({
          'message_id': null,
          'role': 'bot',
          'text':
              'Hi, I’m Fitness Buddy.\n\nTell me what you need today—BMI help, calories, workout guidance, motivation, or wellness tips.',
        });
      });

      scrollToBottom();
    } catch (e) {
      showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBF8),
      body: SafeArea(
        child: Column(
          children: [
            buildHeroHeader(),
            buildQuickPrompts(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (isTyping && index == messages.length) {
                    return buildTypingBubble();
                  }

                  final item = messages[index];
                  final isUser = item['role'] == 'user';

                  return buildMessageBubble(
                    text: item['text']?.toString() ?? '',
                    isUser: isUser,
                    onLongPress: isUser
                        ? () {
                            deleteUserMessagePair(index);
                          }
                        : null,
                  );
                },
              ),
            ),
            buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget buildHeroHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B6E1F), Color(0xFF168A2A), Color(0xFF35B653)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.13),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    DashboardScreen.routeName,
                  );
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Expanded(
                child: Text(
                  'Fitness Buddy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              InkWell(
                onTap: deleteEntireConversation,
                borderRadius: BorderRadius.circular(19),
                child: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    height: 78,
                    width: 78,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        height: 62,
                        width: 62,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: Color(0xFF168A2A),
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 7,
                    bottom: 7,
                    child: Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7CFF8F),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FitnessGo Assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Guides you through fitness, calories, BMI, and motivation.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildQuickPrompts() {
    final items = [
      'BMI',
      'Calories',
      'Workout',
      'Motivation',
      'Articles',
      'Tips',
    ];

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 10, 18, 0),
          child: Row(
            children: [
              Text(
                'Quick prompts',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Spacer(),
              Icon(Icons.swipe_rounded, color: Colors.black38, size: 16),
              SizedBox(width: 4),
              Text(
                'Swipe',
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 66,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 9),
            itemBuilder: (context, index) {
              final label = items[index];

              return InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: isSending
                    ? null
                    : () {
                        sendMessage(label);
                      },
                child: Container(
                  width: chipWidth(label),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE1E8DE)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.035),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 31,
                        width: 31,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEAF7EA),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconForPrompt(label),
                          color: const Color(0xFF168A2A),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  double chipWidth(String label) {
    if (label.length <= 4) return 96;
    if (label.length <= 8) return 122;
    if (label.length <= 13) return 150;
    return 190;
  }

  IconData iconForPrompt(String label) {
    final text = label.toLowerCase();

    if (text.contains('bmi')) return Icons.monitor_weight_rounded;
    if (text.contains('calorie')) return Icons.local_fire_department_rounded;
    if (text.contains('workout')) return Icons.fitness_center_rounded;
    if (text.contains('motivation')) return Icons.auto_awesome_rounded;
    if (text.contains('article')) return Icons.article_rounded;
    if (text.contains('tip')) return Icons.spa_rounded;

    return Icons.auto_awesome_rounded;
  }

  Widget buildMessageBubble({
    required String text,
    required bool isUser,
    VoidCallback? onLongPress,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = screenWidth * 0.68;

    final bubble = GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        margin: EdgeInsets.only(
          left: isUser ? 80 : 8,
          right: isUser ? 8 : 80,
          bottom: 10,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF168A2A) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 5),
            bottomRight: Radius.circular(isUser ? 5 : 18),
          ),
          border: isUser ? null : Border.all(color: const Color(0xFFE1E8DE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: bubble,
    );
  }

  Widget buildTypingDot() {
    return Container(
      height: 7,
      width: 7,
      decoration: const BoxDecoration(
        color: Color(0xFF777777),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 8, right: 80, bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE1E8DE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildTypingDot(),
            const SizedBox(width: 5),
            buildTypingDot(),
            const SizedBox(width: 5),
            buildTypingDot(),
          ],
        ),
      ),
    );
  }

  Widget buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              enabled: !isSending,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                sendMessage();
              },
              decoration: InputDecoration(
                hintText: 'Ask Fitness Buddy...',
                hintStyle: const TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w700,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAF6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFE1E8DE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFE1E8DE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: Color(0xFF168A2A),
                    width: 1.3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          InkWell(
            onTap: isSending
                ? null
                : () {
                    sendMessage();
                  },
            borderRadius: BorderRadius.circular(25),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: isSending
                    ? const Color(0xFF8CCF99)
                    : const Color(0xFF168A2A),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF168A2A).withOpacity(0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
