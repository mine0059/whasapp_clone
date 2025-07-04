import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp_clone/features/app/const/app_const.dart';
import 'package:whatsapp_clone/features/app/global/widgets/profile_widget.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';
import 'package:whatsapp_clone/features/user/domain/entities/contact_entity.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/get_device_number/get_device_number_cubit.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key, required this.uid});

  final String uid;

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage>
    with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();
  TextInputType _keyboardType = TextInputType.text;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    BlocProvider.of<GetDeviceNumberCubit>(context).getDeviceNumber();
    super.initState();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });

    // Only request focus when search is being activated
    if (!_isSearching) {
      _searchController.clear();
      _searchFocusNode.unfocus();
    } else {
      // Wait for animation frame so TextField is mounted
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetDeviceNumberCubit, GetDeviceNumberState>(
        builder: (context, state) {
      if (state is GetDeviceNumberLoaded) {
        final contacts = state.contacts;
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 70,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _isSearching
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: _buildNormalAppBar(contacts),
              secondChild: _buildSearchBar(),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(height: 1.0, color: greyColor.withOpacity(0.15)),
            ),
          ),
          body: SafeArea(
            child: ListView(
              children: [
                const SizedBox(height: 15),
                _buildActionTile(icon: Icons.group, title: "New Group"),
                _buildActionTile(
                    icon: Icons.person_add,
                    title: "New Contact",
                    trailing: IconButton(
                        onPressed: () {}, icon: const Icon(Icons.qr_code))),
                _buildActionTile(
                    icon: Icons.groups_2_outlined, title: "New Community"),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "Contacts on Whatsapp",
                    style: TextStyle(
                      color: greyColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(contacts.length, (index) {
                  final contact = contacts[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.memory(
                            contact.photo ?? Uint8List(0),
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset('assets/profile_default.png');
                            },
                          )),
                    ),
                    title: Text(
                      "${contact.name?.first} ${contact.name?.last}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text("Hey there! i'm using WhatsApp"),
                  );
                }),
              ],
            ),
          ),
        );
      } else if (state is GetDeviceNumberLoading) {
        return const Center(
          child: CircularProgressIndicator(color: tabColor),
        );
      } else if (state is GetDeviceNumberFailure) {
        return const Center(
          child: Text(
            'Failed to load contacts',
            style: TextStyle(color: Colors.red),
          ),
        );
      }

      return const SizedBox(); // default empty state
    });
  }

  Widget _buildNormalAppBar(List<ContactEntity> contacts) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Contact",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                "${contacts.length} contacts",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        if (_isRefreshing)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _toggleSearch,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          offset: const Offset(0, 53),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) async {
            if (value == "refresh") {
              setState(() {
                _isRefreshing = true;
              });
              await BlocProvider.of<GetDeviceNumberCubit>(context)
                  .getDeviceNumber();

              if (mounted) {
                setState(() {
                  _isRefreshing = false;
                });
              }

              if (context.mounted) {
                toast("Your contact list has been updated");
              }
            }
          },
          color: appBarColor,
          itemBuilder: (context) => const [
            PopupMenuItem(value: "invite", child: Text("Invite a friend")),
            PopupMenuItem(value: "contacts", child: Text("Contacts")),
            PopupMenuItem(value: "refresh", child: Text("Refresh")),
            PopupMenuItem(value: "help", child: Text("Help")),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _toggleSearch,
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              autofocus: true,
              keyboardType: _keyboardType,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Search name or number...",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
              icon: Icon(
                _keyboardType == TextInputType.text
                    ? Icons.dialpad
                    : Icons.keyboard_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _keyboardType = _keyboardType == TextInputType.text
                      ? TextInputType.number
                      : TextInputType.text;
                });

                // Unfocus, wait a bit, then refocus to apply the new keyboard
                FocusScope.of(context).unfocus();

                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) {
                    FocusScope.of(context).requestFocus(_searchFocusNode);
                  }
                });
              })
        ],
      ),
    );
  }

  Widget _buildActionTile(
      {required IconData icon,
      required String title,
      Widget? trailing,
      VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: tabColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
