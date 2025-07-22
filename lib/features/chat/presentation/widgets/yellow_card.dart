import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';

class YellowCard extends StatelessWidget {
  const YellowCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: yellowCardBgColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline,
            size: 15,
            color: yellowCardTextColor,
          ),
          Expanded(
            child: Text(
              'Message and calls are end-to-end encrypted. Only people in this chat can read, listen to, or share them. Learn more.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: yellowCardTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
