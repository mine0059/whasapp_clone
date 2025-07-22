import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';

class MessageCard extends StatelessWidget {
  MessageCard({
    super.key,
    this.createdAt,
    this.onSwipe,
    this.message,
    this.isShowTick,
    this.isSeen,
    this.onLongPress,
    required this.isMe,
  });

  final Timestamp? createdAt;
  final VoidCallback? onSwipe;
  final String? message;
  final bool? isShowTick;
  final bool? isSeen;
  final VoidCallback? onLongPress;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      child: SwipeTo(
        onRightSwipe: onSwipe != null ? (details) => onSwipe!() : null,
        child: GestureDetector(
          onLongPress: onLongPress,
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: ClipPath(
              clipper: UpperNipMessageClipper(
                isMe ? MessageType.send : MessageType.receive,
              ),
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      top: 4,
                      bottom: 4,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                      minHeight: 40,
                    ),
                    // padding: EdgeInsets.only(
                    //   top: 8,
                    //   bottom: 8,
                    //   left: isMe ? 10 : 15,
                    //   right: isMe ? 25 : 10,
                    // ),
                    decoration: BoxDecoration(
                      color: isMe ? messageColor : senderMessageColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 8,
                          bottom: 8,
                          left: isMe ? 10 : 15,
                          right: isMe ? 15 : 10,
                        ),
                        child: Text(
                          "${message!}                  ",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: isMe ? 15 : 10,
                    child: Row(
                      children: [
                        Text(
                          DateFormat.jm().format(createdAt!.toDate()),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB3B3B3),
                          ),
                        ),
                        if (isShowTick == true) ...[
                          const SizedBox(width: 4),
                          Icon(
                            isSeen == true ? Icons.done_all : Icons.done,
                            color: isSeen == true
                                ? const Color(0xFF53BDEB)
                                : const Color(0xFFB3B3B3),
                            size: 16,
                          )
                        ]
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
