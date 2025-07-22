import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp_clone/features/app/const/page_const.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';
import 'package:whatsapp_clone/features/call/presentation/pages/call_history_page.dart';
import 'package:whatsapp_clone/features/chat/presentation/pages/chat_page.dart';
import 'package:whatsapp_clone/features/status/presentation/pages/status_page.dart';
import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/get_single_user/get_single_user_cubit.dart';

class ModernHomePage extends StatefulWidget {
  const ModernHomePage({
    super.key,
    required this.uid,
    this.index,
  });

  final String uid;
  final int? index;

  @override
  State<ModernHomePage> createState() => _ModernHomePageState();
}

class _ModernHomePageState extends State<ModernHomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late PageController _pageController;
  int _currentBottomIndex = 0;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<GetSingleUserCubit>(context).getSingleUser(uid: widget.uid);
    WidgetsBinding.instance.addObserver(this);

    _pageController = PageController(initialPage: widget.index ?? 0);

    if (widget.index != null) {
      _currentBottomIndex = widget.index!;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetSingleUserCubit, GetSingleUserState>(
        builder: (context, state) {
      if (state is GetSingleUserLoaded) {
        final currentUser = state.singleUser;
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: _buildAppBar(),
          body: _buildSwipeableBody(currentUser),
          bottomNavigationBar: _buildBottomNav(),
          floatingActionButton: _buildFABStack(),
        );
      }
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: tabColor,
          ),
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        _getAppBarTitle(),
        style: const TextStyle(
          fontSize: 22,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        if (_currentBottomIndex == 0)
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined,
                color: Colors.white, size: 22),
            onPressed: () {},
          ),
        if (_currentBottomIndex == 1 || _currentBottomIndex == 3)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 22),
            onPressed: () {},
          ),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
          offset: const Offset(0, 50),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onSelected: (value) {
            switch (value) {
              case 'settings':
                _handleNavigateToSettings();
                break;
            }
          },
          color: appBarColor,
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'settings',
              child: Text('Settings'),
            ),
            const PopupMenuItem<String>(
              value: 'new_group',
              child: Text('New group'),
            ),
            const PopupMenuItem<String>(
              value: 'new_broadcast',
              child: Text('New broadcast'),
            ),
            const PopupMenuItem<String>(
              value: 'linked_device',
              child: Text('Linked device'),
            ),
            const PopupMenuItem<String>(
              value: 'starred_messages',
              child: Text('Starred messages'),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _handleNavigateToSettings() {
    Navigator.pushNamed(context, PageConst.settingsPage, arguments: widget.uid);
  }

  Widget _buildSwipeableBody(UserEntity currentUser) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentBottomIndex = index;
        });
      },
      children: [
        _buildChatsView(),
        _buildUpdatesView(),
        _buildCommunitiesView(),
        _buildCallsView(),
      ],
    );
  }

  String _getAppBarTitle() {
    switch (_currentBottomIndex) {
      case 0:
        return 'WhatsApp';
      case 1:
        return 'Updates';
      case 2:
        return 'Communities';
      case 3:
        return 'Calls';
      default:
        return 'WhatsApp';
    }
  }

  Widget _buildChatsView() {
    return Column(
      children: [
        // Chat List
        Expanded(
          child: _buildChatList(),
        ),
      ],
    );
  }

  Widget _buildChatList() {
    return const ChatPage();
  }

  Widget _buildUpdatesView() {
    return const StatusPage();
  }

  Widget _buildCommunitiesView() {
    return const Center(
      child: Text(
        'Communities',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildCallsView() {
    return const CallHistoryPage();
  }

  Widget _buildBottomNav() {
    return NavigationBar(
        height: 80,
        selectedIndex: _currentBottomIndex,
        backgroundColor: Colors.transparent,
        indicatorColor: tabColor.withOpacity(0.3),
        onDestinationSelected: (index) => {
              setState(() => _currentBottomIndex = index),
              // Animate to the selected page when bottom nav is tapped
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              )
            },
        destinations: [
          NavigationDestination(
            icon: _buildNavIcon(Icons.chat_bubble_outline, 0),
            selectedIcon: _buildNavIcon(Icons.chat_bubble, 0, isActive: true),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: _buildNavIcon(Icons.update, 1),
            selectedIcon: _buildNavIcon(Icons.update, 1, isActive: true),
            label: 'Updates',
          ),
          NavigationDestination(
            icon: _buildNavIcon(Icons.groups_outlined, 2),
            selectedIcon: _buildNavIcon(Icons.groups, 2, isActive: true),
            label: 'Communities',
          ),
          NavigationDestination(
            icon: _buildNavIcon(Icons.call_outlined, 3),
            selectedIcon: _buildNavIcon(Icons.call, 3, isActive: true),
            label: 'Calls',
          ),
        ]);
  }

  Widget _buildNavIcon(IconData icon, int index, {bool isActive = false}) {
    // Add notification badges here if needed
    return Stack(
      children: [
        Icon(
          icon,
          size: 24,
          color: isActive ? const Color(0xFF25D366).withOpacity(0.85) : null,
        ),
        // Add notification dot if needed
        if (_hasNotification(index))
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: tabColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget? _buildFABStack() {
    switch (_currentBottomIndex) {
      case 0: // Chats
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Meta AI FAB
            FloatingActionButton.small(
              backgroundColor: Colors.blue,
              heroTag: "meta_ai_fab",
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Meta AI pressed!')),
                );
              },
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            ),
            const SizedBox(height: 10),
            // Main Chat FAB
            FloatingActionButton(
              backgroundColor: tabColor,
              heroTag: "main_chat_fab",
              onPressed: () => Navigator.pushNamed(
                context,
                PageConst.contactUsersPage,
                arguments: '',
              ),
              child: const Icon(Icons.add_comment, color: Colors.black),
            ),
          ],
        );

      case 1: // Updates
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text Status FAB
            FloatingActionButton.small(
              backgroundColor: const Color(0xFF2A2A2A),
              heroTag: "text_status_fab",
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Text status pressed!')),
                );
              },
              child: const Icon(Icons.edit, color: Colors.white),
            ),
            const SizedBox(height: 10),
            // Camera FAB
            FloatingActionButton(
              backgroundColor: tabColor,
              heroTag: "main_camera_fab",
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera pressed!')),
                );
              },
              child: const Icon(Icons.camera_alt, color: Colors.black),
            ),
          ],
        );

      case 3: // Calls
        return FloatingActionButton(
          backgroundColor: tabColor,
          heroTag: "call_fab",
          onPressed: () => Navigator.pushNamed(
            context,
            PageConst.callContactPage,
            arguments: '',
          ),
          child: const Icon(Icons.add_call, color: Colors.black),
        );

      default:
        return null;
    }
  }

  bool _hasNotification(int navIndex) {
    // Implement your notification logic here
    // For example, check if there are unread messages, calls, etc.
    switch (navIndex) {
      case 0:
        // return _filterCounts['unread']! > 0; // Chats
        return false; // Chats
      case 1:
        return false; // Updates
      case 2:
        return false; // Communities
      case 3:
        return false; // Calls
      default:
        return false;
    }
  }
}
