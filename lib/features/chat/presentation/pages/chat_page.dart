import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/features/app/const/page_const.dart';
import 'package:whatsapp_clone/features/app/global/widgets/profile_widget.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';
import 'package:whatsapp_clone/features/chat/domain/entities/chat_entity.dart';
import 'package:whatsapp_clone/features/chat/domain/entities/message_entity.dart';
import 'package:whatsapp_clone/features/chat/presentation/cubit/chat/chat_cubit.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.uid});
  final String uid;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _selectedChatFilter = 0;

  // Mock data for counts - replace with actual data
  final Map<String, int> _filterCounts = {
    'all': 15,
    'unread': 3,
    'favorites': 5,
    'groups': 8,
  };

  final List<String> _filterTabs = ['All', 'Unread', 'Favorites', 'Groups'];

  @override
  void initState() {
    BlocProvider.of<ChatCubit>(context)
        .getMyChat(chat: ChatEntity(senderUid: widget.uid));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocBuilder<ChatCubit, ChatState>(builder: (context, state) {
      if (state is ChatLoaded) {
        final myChat = state.chatContacts;

        if (myChat.isEmpty) {
          return const Center(
            child: Text("No Conversation Yet"),
          );
        }

        return ListView(
          // padding: const EdgeInsets.only(top: 20),
          children: [
            _buildSearchTextField(),
            _buildFilterTabs(),
            _buildArchivedSection(),

            // Chat list section
            ...List.generate(myChat.length, (index) {
              final chat = myChat[index];

              // Debug prints to understand the data structure
              debugPrint("=== CHAT DEBUG INFO ===");
              debugPrint("Current user UID: ${widget.uid}");
              debugPrint("Chat senderUid: ${chat.senderUid}");
              debugPrint("Chat recipientUid: ${chat.recipientUid}");
              debugPrint("Chat senderName: ${chat.senderName}");
              debugPrint("Chat recipientName: ${chat.recipientName}");
              debugPrint("========================");

              return GestureDetector(
                onTap: () {
                  // Determine who is the "other person" based on current user UID
                  String otherPersonUid;
                  String otherPersonName;
                  String otherPersonProfile;
                  String currentUserName;
                  String currentUserProfile;

                  if (chat.senderUid == widget.uid) {
                    // Current user is the sender in this chat record
                    otherPersonUid = chat.recipientUid!;
                    otherPersonName = chat.recipientName!;
                    otherPersonProfile = chat.recipientProfile!;
                    currentUserName = chat.senderName!;
                    currentUserProfile = chat.senderProfile!;
                  } else {
                    // Current user is the recipient in this chat record
                    otherPersonUid = chat.senderUid!;
                    otherPersonName = chat.senderName!;
                    otherPersonProfile = chat.senderProfile!;
                    currentUserName = chat.recipientName!;
                    currentUserProfile = chat.recipientProfile!;
                  }

                  print("=== NAVIGATION DEBUG ===");
                  print("Other person: $otherPersonName ($otherPersonUid)");
                  print("Current user: $currentUserName (${widget.uid})");
                  print("========================");

                  Navigator.pushNamed(
                    context,
                    PageConst.singleChatPage,
                    arguments: {
                      'message': MessageEntity(
                        senderUid: widget.uid, // Current user
                        recipientUid: otherPersonUid, // The other person
                        senderName: currentUserName, // Current user's name
                        recipientName:
                            otherPersonName, // The other person's name
                        senderProfile:
                            currentUserProfile, // Current user's profile
                        recipientProfile:
                            otherPersonProfile, // The other person's profile
                        uid: widget.uid,
                      ),
                      'isFromContacts': false,
                    },
                  );
                },
                child: ListTile(
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: profileWidget(
                          imageUrl: chat.senderUid == widget.uid
                              ? chat
                                  .recipientProfile // Show other person's profile
                              : chat
                                  .senderProfile // Show other person's profile
                          ),
                    ),
                  ),
                  title: Text(
                    chat.senderUid == widget.uid
                        ? "${chat.recipientName}" // Show other person's name
                        : "${chat.senderName}", // Show other person's name
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    "${chat.recentTextMessage}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  trailing: Text(
                    DateFormat.jm().format(chat.createdAt!.toDate()),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }
      return const Center(
        child: CircularProgressIndicator(
          color: tabColor,
        ),
      );
    }));
  }

  Widget _buildSearchTextField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: const TextStyle(color: greyColor),
          filled: true,
          fillColor: chatBarMessageColor,
          isDense: true,
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              style: BorderStyle.none,
              width: 0,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          prefixIcon: const Material(
            color: Colors.transparent,
            child: Icon(
              Icons.search,
              color: greyColor,
              size: 23,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 35,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterTabs.length + 1,
        itemBuilder: (context, index) {
          // Build add button at the end
          if (index == _filterTabs.length) {
            return _buildAddButton();
          }

          final isSelected = _selectedChatFilter == index;
          final count = _getCountForFilter(index);

          return GestureDetector(
            onTap: () => setState(() => _selectedChatFilter = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isSelected ? tabColor.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? tabColor : Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _filterTabs[index],
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF25D366).withOpacity(0.85)
                          : Colors.grey[300],
                      // color: isSelected ? tabColor : Colors.grey[300],
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      count.toString(),
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF25D366).withOpacity(0.85)
                            : Colors.grey[300],
                        // color: greyColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.add,
          size: 18,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  int _getCountForFilter(int filterIndex) {
    switch (filterIndex) {
      case 0:
        return _filterCounts['all'] ?? 0;
      case 1:
        return _filterCounts['unread'] ?? 0;
      case 2:
        return _filterCounts['favorites'] ?? 0;
      case 3:
        return _filterCounts['groups'] ?? 0;
      default:
        return 0;
    }
  }

  Widget _buildArchivedSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // Navigate to archived messages
        },
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Icon(
                Icons.archive_outlined,
                color: greyColor,
                size: 23,
              ),
              SizedBox(width: 16),
              Text(
                'Archived',
                style: TextStyle(
                  color: greyColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
