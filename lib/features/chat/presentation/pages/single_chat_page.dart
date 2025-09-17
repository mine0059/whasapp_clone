import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp_clone/features/app/const/page_const.dart';
import 'package:whatsapp_clone/features/app/global/widgets/profile_widget.dart';
import 'package:whatsapp_clone/features/app/home/modern_home_page.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:whatsapp_clone/features/chat/domain/entities/message_entity.dart';
import 'package:whatsapp_clone/features/chat/presentation/cubit/message/message_cubit.dart';
import 'package:whatsapp_clone/features/chat/presentation/widgets/chat_text_field.dart';
import 'package:whatsapp_clone/features/chat/presentation/widgets/message_bubble_paint.dart';
import 'package:whatsapp_clone/features/chat/presentation/widgets/message_card.dart';
import 'package:whatsapp_clone/features/chat/presentation/widgets/show_date_card.dart';
import 'package:whatsapp_clone/features/chat/presentation/widgets/yellow_card.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/get_single_user/get_single_user_cubit.dart';

class SingleChatPage extends StatefulWidget {
  const SingleChatPage({
    super.key,
    required this.message,
    this.isFromContacts = false,
  });

  final MessageEntity message;
  final bool isFromContacts;

  @override
  State<SingleChatPage> createState() => _SingleChatPageState();
}

class _SingleChatPageState extends State<SingleChatPage> {
  final ScrollController scrollController = ScrollController();
  final GlobalKey<ChatTextFieldState> chatTextFieldKey =
      GlobalKey<ChatTextFieldState>();

  @override
  void initState() {
    super.initState();
    // Debug prints to understand what's being passed
    print("=== SINGLE CHAT DEBUG INFO ===");
    print("widget.message.senderUid: ${widget.message.senderUid}");
    print("widget.message.recipientUid: ${widget.message.recipientUid}");
    print("widget.message.senderName: ${widget.message.senderName}");
    print("widget.message.recipientName: ${widget.message.recipientName}");
    print("widget.message.uid: ${widget.message.uid}");
    print("===========================");
    BlocProvider.of<GetSingleUserCubit>(context)
        .getSingleUser(uid: widget.message.recipientUid!);

    BlocProvider.of<MessageCubit>(context).getMessages(
        message: MessageEntity(
      senderUid: widget.message.senderUid,
      recipientUid: widget.message.recipientUid,
    ));
  }

  bool _shouldShowNip(List<MessageEntity> messages, int index) {
    if (index == 0) return true;
    if (index == messages.length - 1) return true;

    final currentMessage = messages[index];
    final prevMessage = messages[index - 1];

    // Show nip if sender changes
    return currentMessage.senderUid != prevMessage.senderUid;
  }

  bool _shouldShowDateCard(List<MessageEntity> messages, int index) {
    // Always show for first message
    if (index == 0) return true;

    final currentMessage = messages[index];
    final prevMessage = messages[index - 1];

    // Check if both messages have timestamps
    if (currentMessage.createdAt == null || prevMessage.createdAt == null) {
      return false;
    }

    final currentDate = currentMessage.createdAt!.toDate();
    final prevDate = prevMessage.createdAt!.toDate();

    // Show date card if the day is different
    return !_isSameDay(currentDate, prevDate);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _handleTapOutside() {
    // Close emoji picker and attachment menu when tapping outside
    if (chatTextFieldKey.currentState != null) {
      chatTextFieldKey.currentState!.closeAllMenus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // titleSpacing: 0,
          // leadingWidth: 30,
          leading: InkWell(
            onTap: () {
              if (widget.isFromContacts) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ModernHomePage(
                            uid: widget.message.uid!,
                            index: 0,
                          )),
                  (route) => false, // Remove all previous routes
                );
              } else {
                // We came from chat list, just pop
                Navigator.pop(context);
              }
            },
            child: SizedBox(
              width: 80,
              child: Row(
                children: [
                  const Icon(Icons.arrow_back),
                  Hero(
                    tag: 'profile',
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: profileWidget(
                            imageUrl: widget.message.recipientProfile),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          title: InkWell(
            onTap: () {
              // Todo: name route to profile
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.message.recipientName}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                BlocBuilder<GetSingleUserCubit, GetSingleUserState>(
                    builder: (context, state) {
                  if (state is GetSingleUserLoaded) {
                    return state.singleUser.isOnline == true
                        ? const Text(
                            'Online',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              // fontWeight: FontWeight.w400,
                            ),
                          )
                        : Container();
                    // : Text(
                    //     timeago.format(
                    //       DateTime.now()
                    //           .subtract(const Duration(minutes: 15)),
                    //     ),
                    //     style: const TextStyle(
                    //       color: textColor,
                    //       fontSize: 12,
                    //       // fontWeight: FontWeight.w400,
                    //     ),
                    //   );
                  }

                  return Container();
                })
              ],
            ),
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
        body:
            BlocBuilder<MessageCubit, MessageState>(builder: (context, state) {
          print("BLoC State: $state");
          if (state is MessageLoaded) {
            final messages = state.messages;
            print("Messages loaded: ${messages.length}"); // Debug line
            return GestureDetector(
              onTap: _handleTapOutside,
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
                        child: messages.isEmpty
                            ? _buildEmptyMessagesView()
                            : _buildMessagesListView(messages),
                      ),
                      ChatTextField(
                        message: widget.message,
                        scrollController: scrollController,
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ],
              ),
            );
          } else if (state is MessageLoading) {
            print("Messages loading...");
            return _buildShimmerLoading();
          }
          print("Unknown state: $state");
          return const SizedBox.shrink();
        }));
  }

  Widget _buildEmptyMessagesView() {
    return Column(
      children: [
        // Show today's date card for new conversations
        ShowDateCard(date: DateTime.now()),
        // Always show YellowCard when starting a new conversation
        const YellowCard(),

        // Empty state message
        // Expanded(
        //   child: Center(
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Icon(
        //           Icons.chat_bubble_outline,
        //           size: 64,
        //           color: Colors.grey[400],
        //         ),
        //         const SizedBox(height: 16),
        //         Text(
        //           "Start your conversation with\n${widget.message.recipientName}",
        //           textAlign: TextAlign.center,
        //           style: TextStyle(
        //             fontSize: 16,
        //             color: Colors.grey[400],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildMessagesListView(List<MessageEntity> messages) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderUid == widget.message.senderUid;

        final haveNip = _shouldShowNip(messages, index);
        final isShowDateCard = _shouldShowDateCard(messages, index);

        return Column(
          children: [
            // Show date card when needed
            if (isShowDateCard) ...[
              ShowDateCard(date: message.createdAt!.toDate()),
              const SizedBox(height: 4),
            ],

            // Show YellowCard only for the very first message
            if (index == 0) ...[
              const YellowCard(),
              const SizedBox(height: 8),
            ],

            MessageCard(
              isMe: isMe,
              haveNip: haveNip,
              message: message.message,
              createdAt: message.createdAt,
              isShowTick: true,
              isSeen: message.isSeen,
              onSwipe: () {},
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: 10,
      itemBuilder: (_, index) {
        final isMe = index % 2 == 0;

        return Container(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          margin: EdgeInsets.only(
            top: 6,
            bottom: 6,
            left: isMe ? 80 : 12,
            right: isMe ? 12 : 80,
          ),
          child: ClipPath(
            clipper: UpperNipMessageClipperTwo(
              isMe ? MessageType.send : MessageType.receive,
              nipWidth: 8,
              nipHeight: 10,
              bubbleRadius: 12,
            ),
            child: Shimmer.fromColors(
              baseColor: isMe
                  ? Colors.grey.shade300.withOpacity(.3)
                  : Colors.grey.shade300.withOpacity(.2),
              highlightColor: isMe
                  ? Colors.grey.shade100.withOpacity(.4)
                  : Colors.grey.shade100.withOpacity(.3),
              child: Container(
                height: 40,
                width: 160 + (index % 3) * 20,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
