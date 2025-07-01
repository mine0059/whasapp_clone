import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp_clone/features/app/global/widgets/profile_widget.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';
import 'package:timeago/timeago.dart' as timeago;

class SingleChatPage extends StatefulWidget {
  const SingleChatPage({super.key, required this.uid});

  final String? uid;

  @override
  State<SingleChatPage> createState() => _SingleChatPageState();
}

class _SingleChatPageState extends State<SingleChatPage> {
  final TextEditingController _textMessageController = TextEditingController();

  bool _isDisplaySendButton = false;
  bool _isShowAttachmentButton = false;

  @override
  void dispose() {
    _textMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leadingWidth: 30,
        title: Row(
          children: [
            const SizedBox(width: 5),
            SizedBox(
              width: 40,
              height: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: profileWidget(),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chat Name',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  timeago.format(
                    DateTime.now().subtract(const Duration(minutes: 15)),
                  ),
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 12,
                    // fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call_outlined),
            color: Colors.white,
            iconSize: 28,
            onPressed: () {
              // Handle video call action
            },
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined),
            color: Colors.white,
            iconSize: 25,
            onPressed: () {
              // Handle voice call action
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            color: appBarColor,
            iconSize: 25,
            // Add offset to move popup menu down
            offset: const Offset(0, 53), // This moves the menu down
            elevation: 5, // Add elevation for modern shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            onSelected: (value) {},
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_contact',
                child: Text('View Contact'),
              ),
              const PopupMenuItem(
                value: 'search',
                child: Text('Search'),
              ),
              const PopupMenuItem(
                value: 'mute',
                child: Text('Mute notifications'),
              ),
              const PopupMenuItem(
                value: 'chat_theme',
                child: Text('Chat theme'),
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _isShowAttachmentButton = false;
          });
        },
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 0,
              child: Image.asset(
                "assets/whatsapp_bg_image.png",
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      _messageLayout(
                          messageBgColor: messageColor,
                          alignment: Alignment.centerRight,
                          createdAt: Timestamp.now(),
                          message: "Hello, how are you?",
                          isShowTick: true,
                          isSeen: false,
                          onLongPress: () {},
                          onSwipe: () {},
                          isMe: true),
                      _messageLayout(
                          messageBgColor: messageColor,
                          alignment: Alignment.centerRight,
                          createdAt: Timestamp.now(),
                          message:
                              "Just wanted to check in and see what has been done",
                          isShowTick: true,
                          isSeen: false,
                          onLongPress: () {},
                          onSwipe: () {},
                          isMe: true),
                      _messageLayout(
                          messageBgColor: messageColor,
                          alignment: Alignment.centerRight,
                          createdAt: Timestamp.now(),
                          message: "Hello",
                          isShowTick: true,
                          isSeen: false,
                          onLongPress: () {},
                          onSwipe: () {},
                          isMe: true),
                      _messageLayout(
                          messageBgColor: senderMessageColor,
                          alignment: Alignment.centerLeft,
                          createdAt: Timestamp.now(),
                          message: "i'm fine thank you",
                          isShowTick: true,
                          isSeen: true,
                          onLongPress: () {},
                          onSwipe: () {},
                          isMe: false),
                      _messageLayout(
                          messageBgColor: senderMessageColor,
                          alignment: Alignment.centerLeft,
                          createdAt: Timestamp.now(),
                          message:
                              "Well i have been doing so much lately and i think we can have a session on this topic and fix all errors as well as implement new features",
                          isShowTick: true,
                          isSeen: false,
                          onLongPress: () {},
                          onSwipe: () {},
                          isMe: false),
                      _messageLayout(
                          messageBgColor: senderMessageColor,
                          alignment: Alignment.centerLeft,
                          createdAt: Timestamp.now(),
                          message: "Hi",
                          isShowTick: true,
                          isSeen: true,
                          onLongPress: () {},
                          onSwipe: () {},
                          isMe: false),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      left: 10, right: 10, bottom: 5, top: 5),
                  child: Row(
                    children: [
                      Expanded(
                          child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: chatBarMessageColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        height: 50,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            textSelectionTheme: const TextSelectionThemeData(
                              cursorColor:
                                  Color(0xFF00D4AA), // WhatsApp green cursor
                            ),
                          ),
                          child: TextField(
                            onTap: () {
                              setState(() {
                                _isShowAttachmentButton = false;
                              });
                            },
                            controller: _textMessageController,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  _isDisplaySendButton = true;
                                });
                              } else {
                                setState(() {
                                  _isDisplaySendButton = false;
                                });
                              }
                            },
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              prefixIcon: IconButton(
                                icon: const Icon(
                                  Icons.emoji_emotions_outlined,
                                  color: greyColor,
                                ),
                                onPressed: () {
                                  // Handle emoji button press
                                },
                              ),
                              suffixIcon: Wrap(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isShowAttachmentButton =
                                            !_isShowAttachmentButton;
                                      });
                                    },
                                    icon: const Icon(Icons.attach_file),
                                    color: greyColor,
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.camera_alt_outlined),
                                    color: greyColor,
                                  ),
                                ],
                              ),
                              border: InputBorder.none,
                              hintText: "Message",
                              hintStyle: const TextStyle(
                                color: lightGreyColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      )),
                      const SizedBox(width: 5),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: tabColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              _isDisplaySendButton ? Icons.send : Icons.mic,
                              // size: 28,
                              color: Colors.white,
                            )),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
            _isShowAttachmentButton == true
                ? Positioned(
                    bottom: 65,
                    // top: 340,
                    top: 500,
                    left: 15,
                    right: 15,
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.20,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _attachWindowItem(
                                icon: Icons.photo_outlined,
                                label: "Gallery",
                                color: Colors.indigo,
                                onTap: () {},
                              ),
                              _attachWindowItem(
                                icon: Icons.camera_alt_outlined,
                                label: "Camera",
                                color: Colors.redAccent,
                                onTap: () {},
                              ),
                              _attachWindowItem(
                                icon: Icons.location_on,
                                label: "Location",
                                color: Colors.greenAccent,
                                onTap: () {},
                              ),
                              _attachWindowItem(
                                icon: Icons.person,
                                label: "Contact",
                                color: const Color.fromARGB(255, 57, 162, 241),
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              _attachWindowItem(
                                icon: Icons.insert_drive_file_outlined,
                                label: "Document",
                                color: Colors.purple,
                                onTap: () {},
                              ),
                              _attachWindowItem(
                                icon: Icons.headphones,
                                label: "Audio",
                                color: const Color.fromARGB(255, 255, 124, 64),
                                onTap: () {},
                              ),
                              _attachWindowItem(
                                icon: Icons.poll_outlined,
                                label: "Poll",
                                color: Colors.yellow,
                                onTap: () {},
                              ),
                              _attachWindowItem(
                                icon: Icons.event_outlined,
                                label: "Event",
                                color: const Color.fromARGB(255, 233, 52, 52),
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  _messageLayout({
    Color? messageBgColor,
    Alignment? alignment,
    Timestamp? createdAt,
    VoidCallback? onSwipe,
    String? message,
    bool? isShowTick,
    bool? isSeen,
    VoidCallback? onLongPress,
    required bool isMe, // New parameter to determine message direction
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      child: SwipeTo(
        onRightSwipe: onSwipe != null ? (details) => onSwipe() : null,
        child: GestureDetector(
          onLongPress: onLongPress,
          child: Container(
            alignment: alignment,
            child: Container(
              margin: EdgeInsets.only(
                left: isMe ? 50 : 8,
                right: isMe ? 8 : 50,
                top: 4,
                bottom: 4,
              ),
              child: CustomPaint(
                painter: MessageBubblePainter(
                  color: messageBgColor!,
                  isMe: isMe,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                    minHeight: 40,
                  ),
                  padding: EdgeInsets.only(
                    left: isMe ? 12 : 20,
                    right: isMe ? 20 : 12,
                    top: 8,
                    bottom: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Spacer(),
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
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _attachWindowItem({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF1E272C),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF2A3942),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: greyColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for WhatsApp-style message bubbles with tail
class MessageBubblePainter extends CustomPainter {
  final Color color;
  final bool isMe;

  MessageBubblePainter({required this.color, required this.isMe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isMe) {
      // Right-side bubble (my messages)
      path.addRRect(
        RRect.fromLTRBAndCorners(
          0,
          0,
          size.width - 10,
          size.height,
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(2),
          bottomLeft: const Radius.circular(18),
          bottomRight: const Radius.circular(18),
        ),
      );

      // Add the tail pointing right
      path.moveTo(size.width - 10, 10);
      path.lineTo(size.width, 0); // Points to top
      path.lineTo(size.width - 10, 0);
      path.close();
    } else {
      // Left-side bubble (other person's messages)
      path.addRRect(
        RRect.fromLTRBAndCorners(
          10,
          0,
          size.width,
          size.height,
          topLeft: const Radius.circular(0),
          topRight: const Radius.circular(18),
          bottomLeft: const Radius.circular(18),
          bottomRight: const Radius.circular(18),
        ),
      );

      // Add the tail pointing left
      path.moveTo(10, 10);
      path.lineTo(0, 0); // Points to top
      path.lineTo(10, 0);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



// this commented out code is the chat message box(container) design we have to patern here should in case we want to make use of any of them later 
// below is the one 
// child: Stack(
//   children: [
//     // FIX 5: STACK-BASED APPROACH - Text flows naturally, time/tick positioned absolutely
//     Padding(
//       padding: const EdgeInsets.only(
//           bottom: 20), // Space for time/tick row
//       child: Text(
//         message!,
//         style: const TextStyle(
//           fontSize: 16,
//           color: Colors.white,
//           height: 1.3,
//         ),
//       ),
//     ),

//     // FIX 6: ABSOLUTE POSITIONING - Time/ticks positioned at bottom right
//     Positioned(
//       bottom: 0,
//       right: 0,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             DateFormat.jm().format(createdAt!.toDate()),
//             style: const TextStyle(
//               fontSize: 12,
//               color: Color(0xFFB3B3B3),
//             ),
//           ),
//           if (isShowTick == true) ...[
//             const SizedBox(width: 4),
//             Icon(
//               isSeen == true ? Icons.done_all : Icons.done,
//               color: isSeen == true
//                   ? const Color(0xFF53BDEB)
//                   : const Color(0xFFB3B3B3),
//               size: 16,
//             ),
//           ],
//         ],
//       ),
//     ),
//   ],
// ),


// This is the initial code for the message layout that was commented out.
// This code is not used in the current implementation but can be used later for replacement if needed.
// _messageLayout({
  //   Color? messageBgColor,
  //   Alignment? alignment,
  //   Timestamp? createdAt,
  //   VoidCallback? onSwipe,
  //   // double? rightPadding,
  //   String? message,
  //   bool? isShowTick,
  //   bool? isSeen,
  //   VoidCallback? onLongPress,
  //   required bool isMe,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 5),
  //     child: SwipeTo(
  //         onRightSwipe: onSwipe != null ? (details) => onSwipe() : null,
  //         child: GestureDetector(
  //           onLongPress: onLongPress,
  //           child: Container(
  //             alignment: alignment,
  //             child: Stack(
  //               children: [
  //                 Column(
  //                   children: [
  //                     Container(
  //                       margin: const EdgeInsets.only(top: 10),
  //                       padding: const EdgeInsets.only(
  //                           left: 5, right: 85, top: 5, bottom: 5),
  //                       constraints: BoxConstraints(
  //                         maxWidth: MediaQuery.of(context).size.width * 0.80,
  //                       ),
  //                       decoration: BoxDecoration(
  //                         color: messageBgColor,
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       child: Text(
  //                         "$message",
  //                         style: const TextStyle(
  //                           fontSize: 16,
  //                           color: Colors.white,
  //                         ),
  //                         // textAlign: TextAlign.start,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 3),
  //                   ],
  //                 ),
  //                 Positioned(
  //                     bottom: 4,
  //                     right: 10,
  //                     child: Row(
  //                       children: [
  //                         Text(
  //                           DateFormat.jm().format(createdAt!.toDate()),
  //                           style: const TextStyle(
  //                             fontSize: 12,
  //                             color: greyColor,
  //                           ),
  //                         ),
  //                         const SizedBox(width: 5),
  //                         isShowTick == true
  //                             ? Icon(
  //                                 isSeen == true ? Icons.done_all : Icons.done,
  //                                 color:
  //                                     isSeen == true ? Colors.blue : greyColor,
  //                                 size: 18,
  //                               )
  //                             : const SizedBox.shrink(),
  //                       ],
  //                     ))
  //               ],
  //             ),
  //           ),
  //         )),
  //   );
  // }
