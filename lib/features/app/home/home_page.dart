import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/app/const/page_const.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';
import 'package:whatsapp_clone/features/call/presentation/pages/call_contact_page.dart';
import 'package:whatsapp_clone/features/call/presentation/pages/call_history_page.dart';
import 'package:whatsapp_clone/features/chat/presentation/pages/chat_page.dart';
import 'package:whatsapp_clone/features/status/presentation/pages/status_page.dart';
import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.uid, this.index});

  final String uid;
  final int? index;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TabController? _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);

    _tabController!.addListener(() {
      setState(() {
        _currentIndex = _tabController!.index;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WhatsApp',
          style: TextStyle(
            fontSize: 20,
            color: greyColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  color: greyColor,
                  size: 28,
                ),
                onPressed: () {
                  // Implement search functionality
                },
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: greyColor,
                  size: 28,
                ),
                onPressed: () {
                  // Implement search functionality
                },
              ),
              PopupMenuButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: greyColor,
                  size: 28,
                ),
                color: appBarColor,
                iconSize: 28,
                onSelected: (value) {},
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'settings',
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, PageConst.settingsPage,
                          arguments: ''),
                      child: const Row(
                        children: [
                          Icon(Icons.settings, color: tabColor),
                          SizedBox(width: 10),
                          Text('Settings'),
                        ],
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'new_group',
                    child: Row(
                      children: [
                        Icon(Icons.group, color: tabColor),
                        SizedBox(width: 10),
                        Text('New Group'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'new_broadcast',
                    child: Row(
                      children: [
                        Icon(Icons.broadcast_on_home, color: tabColor),
                        SizedBox(width: 10),
                        Text('New Broadcast'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'linked_devices',
                    child: Row(
                      children: [
                        Icon(Icons.devices, color: tabColor),
                        SizedBox(width: 10),
                        Text('Linked Devices'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'starred_messages',
                    child: Row(
                      children: [
                        Icon(Icons.star, color: tabColor),
                        SizedBox(width: 10),
                        Text('Starred Messages'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: tabColor,
          labelColor: tabColor,
          unselectedLabelColor: greyColor,
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Status'),
            Tab(text: 'Calls'),
          ],
        ),
      ),
      floatingActionButton: switchFloatingActionButtonOnTapIndex(
          _currentIndex,
          const UserEntity(
            uid: '1',
            username: 'Current User',
            phoneNumber: '1234567890',
            profileUrl: '',
          )),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(child: ChatPage()),
          Center(child: StatusPage()),
          Center(
            child: CallHistoryPage(),
          )
        ],
      ),
    );
  }

  switchFloatingActionButtonOnTapIndex(int index, UserEntity currentUser) {
    switch (index) {
      case 0:
        {
          return FloatingActionButton(
            backgroundColor: tabColor,
            onPressed: () {
              Navigator.pushNamed(context, PageConst.contactUsersPage,
                  arguments: '');
            },
            child: const Icon(
              Icons.chat,
              color: Colors.white,
            ),
          );
        }
      case 1:
        {
          return FloatingActionButton(
            backgroundColor: tabColor,
            onPressed: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const StatusPage()));
            },
            child: const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
            ),
          );
        }
      case 2:
        {
          return FloatingActionButton(
            backgroundColor: tabColor,
            onPressed: () {
              Navigator.pushNamed(context, PageConst.callContactPage,
                  arguments: '');
            },
            child: const Icon(
              Icons.add_call,
              color: Colors.white,
            ),
          );
        }
      default:
        {
          return FloatingActionButton(
            backgroundColor: tabColor,
            onPressed: () {},
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          );
        }
    }
  }
}
