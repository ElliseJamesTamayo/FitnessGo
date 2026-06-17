import 'package:flutter/material.dart';

class FAQsScreen extends StatelessWidget {
  static const routeName = '/faqs';

  const FAQsScreen({super.key});

  static const List<_FAQData> faqs = [
    _FAQData(
      question: 'What is FitnessGo?',
      answer:
          'FitnessGo is a personalized fitness management app that helps you track calories, save favorite workouts and articles, set fitness goals, and improve your overall wellness.',
    ),
    _FAQData(
      question: 'How does FitnessGo personalize my experience?',
      answer:
          'FitnessGo uses your age, gender, height, weight, activity level, fitness goal, and health conditions to personalize calorie goals, workouts, and recommendations.',
    ),
    _FAQData(
      question: 'How do I create a FitnessGo account?',
      answer:
          'You can create an account by signing up with your username, email, password, and personal information, then verifying your email with a 6-digit OTP.',
    ),
    _FAQData(
      question: 'How do I edit my profile information?',
      answer:
          'Go to Profile > Edit Profile to update your personal information like name, age, gender, or weight.',
    ),
    _FAQData(
      question: 'Can I update my fitness goals later?',
      answer:
          'Yes. Go to Profile > My Goals > Edit Fitness Goals to update your goal, desired weight, and daily calorie target.',
    ),
    _FAQData(
      question: 'How do I change my profile picture?',
      answer:
          'Go to Profile > Edit Profile Picture and upload a new photo.',
    ),
    _FAQData(
      question: 'How do I reset my password if I forget it?',
      answer:
          'Click Forgot Password on the login screen, enter your email, verify the OTP, and create a new password.',
    ),
    _FAQData(
      question: 'How do I change my password while logged in?',
      answer:
          'Go to Profile > Change Password, verify your email using OTP, then set a new password.',
    ),
    _FAQData(
      question: 'Is my personal data secure?',
      answer:
          'Yes. FitnessGo securely stores your data and protects your account using email verification and password security.',
    ),
    _FAQData(
      question: 'How do I log my food intake?',
      answer:
          'Go to Calorie Counter, enter food type, weight, meal type such as breakfast, lunch, snack, or dinner, and save it.',
    ),
    _FAQData(
      question: 'Does FitnessGo calculate calories automatically?',
      answer:
          'Yes. The Calorie Counter helps estimate food calories based on your input.',
    ),
    _FAQData(
      question: 'Can I edit or delete food entries?',
      answer:
          'Yes. Go to Activity Log > Food, select an entry, and edit or delete it.',
    ),
    _FAQData(
      question: 'Can I view my past calorie intake?',
      answer:
          'Yes. Use the calendar view in the Activity Log to see food entries by date.',
    ),
    _FAQData(
      question: 'Does FitnessGo provide workout exercises?',
      answer:
          'Yes. FitnessGo provides beginner, intermediate, and advanced workout routines.',
    ),
    _FAQData(
      question: 'Can I save workouts or exercises?',
      answer:
          'Yes. You can save exercises and view them later in Activity Log > Workouts.',
    ),
    _FAQData(
      question: 'What is the Wellness Hub?',
      answer:
          'The Wellness Hub provides health articles, exercise guides, and fitness tips to support your wellness journey.',
    ),
    _FAQData(
      question: 'Can I save health articles?',
      answer:
          'Yes. Saved articles are available in Activity Log > Articles.',
    ),
    _FAQData(
      question: 'What is the Fitness Wall?',
      answer:
          'The Fitness Wall is a feature in FitnessGo where users can post fitness-related content such as workouts, progress updates, and motivational messages. It serves as a space to share personal fitness journeys and view posts from other users.',
    ),
    _FAQData(
      question: 'Who can see my posts on the Fitness Wall?',
      answer:
          'Public posts are visible to all FitnessGo users.\n\nPrivate posts are visible only to the post owner.\n\nHowever, all posts, public and private, may be reviewed by authorized system administrators for moderation and system management purposes only.',
    ),
    _FAQData(
      question: 'What type of content can I post on the Fitness Wall?',
      answer:
          'You can post:\n\n• Workout routines\n• Fitness progress updates\n• Motivational or wellness messages\n• Fitness-related photos\n\nContent should be respectful and appropriate.',
    ),
    _FAQData(
      question: 'What type of posts are not allowed?',
      answer:
          'Not allowed posts include:\n\n• Offensive, explicit, or hateful content\n• Harassment or bullying\n• Misleading or harmful fitness information\n• Spam or non-fitness-related content',
    ),
    _FAQData(
      question: 'What happens if I post inappropriate content?',
      answer:
          'If a post violates system rules, the following actions may be taken:\n\n• Post removal\n• Warning notification\n• Account deactivation for repeated or serious violations',
    ),
    _FAQData(
      question: 'Can I edit or delete my posts?',
      answer:
          'Yes. Tap the three dots on your post to edit, change privacy, or delete it. Other users cannot modify your posts.',
    ),
    _FAQData(
      question: 'Can I set my post privacy?',
      answer:
          'Yes. You can choose whether your post is public or private.',
    ),
    _FAQData(
      question: 'Why was my post removed from the Fitness Wall?',
      answer:
          'Posts may be removed if they:\n\n• Contain inappropriate or offensive content\n• Violate FitnessGo’s community guidelines\n• Include misleading or harmful information\n\nRepeated violations may result in account restrictions.',
    ),
    _FAQData(
      question: 'Why can’t I see some posts on the Fitness Wall?',
      answer:
          'You may not see certain posts if:\n\n• The post is set to Private\n• The post was removed by an administrator\n• The account that created the post has been deactivated',
    ),
    _FAQData(
      question: 'Is the Fitness Wall available to all users?',
      answer:
          'Yes. All active FitnessGo users can access the Fitness Wall and create posts.',
    ),
    _FAQData(
      question: 'How does the Fitness Wall help users stay motivated?',
      answer:
          'By viewing fitness updates and progress from other users, the Fitness Wall encourages consistency, inspiration, and awareness of healthy lifestyles even without direct interaction features.',
    ),
    _FAQData(
      question: 'Are Fitness Wall activities monitored?',
      answer:
          'Yes. All Fitness Wall posts, including private posts, may be reviewed by administrators. Moderation activities are logged for accountability.',
    ),
    _FAQData(
      question: 'Why is moderation necessary?',
      answer:
          'Moderation helps maintain a safe, respectful, and fitness-focused environment for all users.',
    ),
    _FAQData(
      question: 'Is my information protected?',
      answer:
          'Yes. Admin access is limited to authorized personnel and is used strictly for moderation and system management purposes.',
    ),
    _FAQData(
      question: 'What is the AI Fitness Buddy?',
      answer:
          'The AI Fitness Buddy helps answer questions about workouts, calorie tracking, wellness articles, and app navigation.',
    ),
    _FAQData(
      question: 'Can I use FitnessGo offline?',
      answer:
          'No. FitnessGo requires an active internet connection to access features such as calorie tracking, workout content, wellness articles, and data synchronization.',
    ),
    _FAQData(
      question: 'Who can manage or moderate Fitness Wall content?',
      answer:
          'System administrators can review and manage Fitness Wall posts to ensure all content follows community guidelines.',
    ),
    _FAQData(
      question: 'What can administrators see on the Fitness Wall?',
      answer:
          'Administrators can view:\n\n• All posts, public and private\n• Post content, text and images\n• Post creation date and time\n• Post visibility setting',
    ),
    _FAQData(
      question: 'Can administrators edit user posts?',
      answer:
          'No. Administrators cannot edit user posts. They can only remove posts that violate policies.',
    ),
    _FAQData(
      question: 'Can Fitness Wall activity affect my account status?',
      answer:
          'Yes. Accounts that accumulate five violations related to Fitness Wall posts will be automatically deactivated by the system.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF4),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 22, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF245C24),
                      size: 29,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'FAQs',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                'Find quick answers about your account, calories, workouts, Fitness Wall, and app features.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
                itemCount: faqs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _FAQCard(data: faqs[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQData {
  final String question;
  final String answer;

  const _FAQData({
    required this.question,
    required this.answer,
  });
}

class _FAQCard extends StatefulWidget {
  final _FAQData data;

  const _FAQCard({
    required this.data,
  });

  @override
  State<_FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<_FAQCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE4ECE0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: expanded ? const Color(0xFF008000) : Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Icon(
                    expanded
                        ? Icons.remove_circle_outline_rounded
                        : Icons.add_circle_outline_rounded,
                    color: expanded ? Colors.white : const Color(0xFF008000),
                    size: 23,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.data.question,
                      style: TextStyle(
                        color: expanded ? Colors.white : Colors.black87,
                        fontSize: 14.5,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.data.answer,
                  style: const TextStyle(
                    color: Color(0xFF245C24),
                    fontSize: 13.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }
}


