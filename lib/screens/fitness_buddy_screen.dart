import 'package:flutter/material.dart';

import '../data/local_fitness_buddy_service.dart';
import 'dashboard_screen.dart';

class FitnessBuddyScreen extends StatefulWidget {
  static const routeName = '/fitness-buddy';

  const FitnessBuddyScreen({super.key});

  @override
  State<FitnessBuddyScreen> createState() => _FitnessBuddyScreenState();
}

class _FitnessBuddyScreenState extends State<FitnessBuddyScreen> {
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  bool isTyping = false;
  List<String> suggestions = LocalFitnessBuddyService.suggestions;

  final List<Map<String, String>> messages = [
    {
      'role': 'bot',
      'text':
          'Hi, I’m Fitness Buddy.\n\nTell me what you need today—BMI help, calories, workout guidance, motivation, or wellness tips.',
    },
  ];

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
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
    final text = (preset ?? messageController.text).trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      messages.add({'role': 'user', 'text': text});
      messageController.clear();
      isTyping = true;
    });

    scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 550));

    if (!mounted) return;

    setState(() {
      messages.add({
        'role': 'bot',
        'text': LocalFitnessBuddyService.reply(text),
      });
      isTyping = false;
      suggestions = LocalFitnessBuddyService.suggestions;
    });

    scrollToBottom();
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

                  return buildMessageBubble(
                    text: item['text'] ?? '',
                    isUser: item['role'] == 'user',
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
          colors: [
            Color(0xFF0B6E1F),
            Color(0xFF168A2A),
            Color(0xFF35B653),
          ],
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
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 22,
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
                          Icons.psychology_alt_rounded,
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
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
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
          const SizedBox(height: 14),
          Row(
            children: [
              buildStatusPill(Icons.bolt_rounded, 'Local assistant'),
              const SizedBox(width: 8),
              buildStatusPill(Icons.favorite_rounded, 'Fitness guidance'),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildStatusPill(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
          child: Row(
            children: const [
              Text(
                'Quick prompts',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Spacer(),
              Icon(
                Icons.swipe_rounded,
                color: Colors.black38,
                size: 16,
              ),
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
                onTap: () {
                  sendMessage(label);
                },
                child: Container(
                  width: chipWidth(label),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFE1E8DE),
                    ),
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
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 318),
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF168A2A) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(isUser ? 22 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 22),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: const Color(0xFFE1E8DE),
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.38,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFE1E8DE),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF168A2A),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Preparing response...',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSuggestionReplies() {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final text = suggestions[index];

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              sendMessage(text);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7EA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFC7EBCB),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF168A2A),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );
        },
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
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
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
                  borderSide: const BorderSide(
                    color: Color(0xFFE1E8DE),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: Color(0xFFE1E8DE),
                  ),
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
            onTap: sendMessage,
            borderRadius: BorderRadius.circular(25),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF168A2A),
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






