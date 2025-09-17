import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp_clone/features/app/const/app_const.dart';
import 'package:whatsapp_clone/features/app/const/page_const.dart';
import 'package:whatsapp_clone/features/app/global/widgets/profile_widget.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';
import 'package:whatsapp_clone/features/chat/domain/entities/message_entity.dart';
import 'package:whatsapp_clone/features/user/domain/entities/contact_entity.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/get_device_number/get_device_number_cubit.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/get_single_user/get_single_user_cubit.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/user/user_cubit.dart';

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
    BlocProvider.of<UserCubit>(context).getAllUsers();
    BlocProvider.of<GetSingleUserCubit>(context).getSingleUser(uid: widget.uid);
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

  // Helper method to normalize phone number (remove spaces, dashes, etc.)
  String _normalizePhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
  }

  // Helper method to find contact name by phone number
  String? _getContactNameByPhone(
      List<ContactEntity> contacts, String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return null;

    final normalizedTargetNumber = _normalizePhoneNumber(phoneNumber);

    for (final contact in contacts) {
      if (contact.phones != null && contact.phones!.isNotEmpty) {
        for (var phone in contact.phones!) {
          final normalizedContactNumber = _normalizePhoneNumber(phone.number);
          // Check if the numbers match (considering different formats)
          if (normalizedContactNumber.endsWith(normalizedTargetNumber) ||
              normalizedTargetNumber.endsWith(normalizedContactNumber)) {
            return contact.displayName ??
                "${contact.name?.first ?? ''} ${contact.name?.last ?? ''}"
                    .trim();
          }
        }
      }
    }
    return null;
  }

  // Helper method to check if a user is in contacts
  bool _isUserInContacts(List<ContactEntity> contacts, String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return false;
    final normalizedTargetNumber = _normalizePhoneNumber(phoneNumber);

    return contacts.any((contact) {
      if (contact.phones != null && contact.phones!.isNotEmpty) {
        return contact.phones!.any((phone) {
          final normalizedContactNumber = _normalizePhoneNumber(phone.number);
          return normalizedContactNumber.endsWith(normalizedTargetNumber) ||
              normalizedTargetNumber.endsWith(normalizedContactNumber);
        });
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocBuilder<GetDeviceNumberCubit, GetDeviceNumberState>(
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
                  child: Container(
                      height: 1.0, color: greyColor.withOpacity(0.15)),
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

                    // WhatsApp Clone Users Section
                    _buildWhatsAppCloneUsersSection(contacts),

                    const SizedBox(height: 20),

                    // Device Contacts Section
                    _buildDeviceContactsSection(contacts),
                  ],
                ),
              ),
              floatingActionButton: null, // Prevent hero tag conflicts
            );
          } else if (state is GetDeviceNumberLoading) {
            return Scaffold(
              backgroundColor: backgroundColor,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                title: const Text("Loading Contacts..."),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: tabColor),
                    SizedBox(height: 16),
                    Text(
                      "Loading your contacts...",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              floatingActionButton: null, // Prevent hero tag conflicts
            );
          } else if (state is GetDeviceNumberFailure) {
            return Scaffold(
              backgroundColor: backgroundColor,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                title: const Text("Error"),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load contacts',
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        BlocProvider.of<GetDeviceNumberCubit>(context)
                            .getDeviceNumber();
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
              floatingActionButton: null, // Prevent hero tag conflicts
            );
          }

          // Initial state - show loading
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: const Text("Contacts"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(color: tabColor),
            ),
            floatingActionButton: null, // Prevent hero tag conflicts
          );
        },
      ),
    );
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

  // Widget _buildWhatappCloneUserSection(List<ContactEntity> contacts) {
  //   return BlocBuilder<GetSingleUserCubit, GetSingleUserState>(
  //       builder: (context, singleUserState) {
  //     if (singleUserState is GetSingleUserLoaded) {
  //       final currentUser = singleUserState.singleUser;

  //       return BlocBuilder<UserCubit, UserState>(
  //         builder: (context, userState) {
  //           if (userState is UserLoaded) {
  //             // Get all users except current user
  //             final whatsappUsers = userState.users
  //                 .where((user) => user.uid != widget.uid)
  //                 .toList();

  //             if (whatsappUsers.isEmpty) {
  //               return const SizedBox(); // Don't show section if no users
  //             }

  //             return ListView.builder(
  //                 itemCount: whatsappUsers.length,
  //                 itemBuilder: (context, index) {
  //                   final contact = whatsappUsers[index];
  //                   // Check if this user is in the device contacts
  //                   final contactName =
  //                       _getContactNameByPhone(contacts, contact.phoneNumber);
  //                   final displayName =
  //                       contactName ?? contact.username ?? "Unknown User";

  //                   return ListTile(
  //                     onTap: () {
  //                       Navigator.pushNamed(
  //                         context,
  //                         PageConst.singleChatPage,
  //                         arguments: MessageEntity(
  //                             senderUid: currentUser.uid,
  //                             recipientUid: contact.uid,
  //                             senderName: currentUser.username,
  //                             recipientName: contact.username,
  //                             senderProfile: currentUser.profileUrl,
  //                             recipientProfile: contact.profileUrl,
  //                             uid: widget.uid),
  //                       );
  //                     },
  //                     leading: SizedBox(
  //                       width: 50,
  //                       height: 50,
  //                       child: ClipRRect(
  //                           borderRadius: BorderRadius.circular(25),
  //                           child: profileWidget(imageUrl: contact.profileUrl)),
  //                     ),
  //                     title: Text(displayName),
  //                     subtitle: Text(
  //                       contact.status ?? "Hey there! I'm using WhatsApp Clone",
  //                       style: const TextStyle(fontSize: 14),
  //                     ),
  //                   );
  //                 });
  //           }
  //           return const SizedBox();
  //         },
  //       );
  //     }
  //     return const SizedBox();
  //   });
  // }

  Widget _buildWhatsAppCloneUsersSection(List<ContactEntity> contacts) {
    return BlocBuilder<GetSingleUserCubit, GetSingleUserState>(
      builder: (context, singleUserState) {
        if (singleUserState is GetSingleUserLoaded) {
          final currentUser = singleUserState.singleUser;

          return BlocBuilder<UserCubit, UserState>(
            builder: (context, userState) {
              if (userState is UserLoaded) {
                // Get all users except current user
                final whatsappUsers = userState.users
                    .where((user) => user.uid != widget.uid)
                    .toList();

                if (whatsappUsers.isEmpty) {
                  return const SizedBox(); // Don't show section if no users
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "On WhatsApp Clone",
                        style: TextStyle(
                          color: greyColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    ...whatsappUsers.map((user) {
                      // Check if this user is in the device contacts
                      final contactName =
                          _getContactNameByPhone(contacts, user.phoneNumber);
                      final displayName =
                          contactName ?? user.username ?? "Unknown User";

                      return ListTile(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              context, PageConst.singleChatPage,
                              arguments: {
                                'message': MessageEntity(
                                  senderUid: currentUser.uid,  // Current user is sender
                                  recipientUid: user.uid,      // Selected user is recipient
                                  senderName: currentUser.username,   // Current user's name
                                  recipientName: user.username,       // Selected user's name
                                  senderProfile: currentUser.profileUrl,  // Current user's profile
                                  recipientProfile: user.profileUrl,      // Selected user's profile
                                  uid: widget.uid,
                                ),
                                'isFromContacts': true,
                              });
                        },
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: profileWidget(imageUrl: user.profileUrl),
                          ),
                        ),
                        title: Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          user.status ?? "Hey there! I'm using WhatsApp Clone",
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                  ],
                );
              }
              return const SizedBox(); // Loading handled at parent level
            },
          );
        }
        return const SizedBox(); // Loading handled at parent level
      },
    );
  }

  Widget _buildDeviceContactsSection(List<ContactEntity> contacts) {
    return BlocBuilder<UserCubit, UserState>(builder: (context, UserState) {
      // Get phone numbers of users in the system for filtering
      final systemPhoneNumbers = <String>{};
      if (UserState is UserLoaded) {
        systemPhoneNumbers.addAll(UserState.users
            .where((user) => user.phoneNumber != null)
            .map((user) => user.phoneNumber!));
      }

      // Filter contacts to show only those Not in the whatsApp clone system
      final deviceOnlyContacts = contacts.where((contact) {
        return contact.phones != null &&
            !systemPhoneNumbers.contains(contact.phones);
      }).toList();

      if (deviceOnlyContacts.isEmpty) {
        return const SizedBox(); // Don't show section if no contacts
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              "Invite to WhatsApp Clone",
              style: TextStyle(
                color: greyColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 2),
          ...deviceOnlyContacts.map((contact) {
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: contact.photo != null && contact.photo!.isNotEmpty
                      ? Image.memory(
                          contact.photo!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/profile_default.png');
                          },
                        )
                      : Image.asset('assets/profile_default.png'),
                ),
              ),
              title: Text(
                "${contact.name?.first ?? ''} ${contact.name?.last ?? ''}"
                    .trim(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                contact.phones?.isNotEmpty == true
                    ? contact.phones!.first.number
                    : "No phone number",
                style: const TextStyle(fontSize: 14),
              ),
              trailing: const Text(
                "Invite",
                style: TextStyle(
                  color: tabColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                _showInviteDialog(contact);
              },
            );
          }),
        ],
      );
    });
  }

  void _showInviteDialog(ContactEntity contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Invite Contact"),
        content: Text(
          "Would you like to invite ${contact.displayName ?? "${contact.name?.first} ${contact.name?.last}"} to join WhatsApp Clone?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement invite functionality
              _inviteContact(contact);
            },
            child: const Text("Invite"),
          ),
        ],
      ),
    );
  }

  void _inviteContact(ContactEntity contact) {
    // Implement your invite logic here
    // This could involve sending an SMS, sharing app link, etc.
    final contactName =
        contact.displayName ?? "${contact.name?.first} ${contact.name?.last}";
    toast("Invitation sent to $contactName");
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
