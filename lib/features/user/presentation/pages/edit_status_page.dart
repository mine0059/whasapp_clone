import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_clone/features/app/const/app_const.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';
import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/user/user_cubit.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/get_single_user/get_single_user_cubit.dart';

class EditStatusPage extends StatefulWidget {
  const EditStatusPage({super.key, required this.currentUser});

  final UserEntity currentUser;

  @override
  State<EditStatusPage> createState() => _EditStatusPageState();
}

class _EditStatusPageState extends State<EditStatusPage> {
  // final TextEditingController _statusController = TextEditingController();
  late TextEditingController _statusController;
  late String currentStatus;
  bool _showEmojiIcon = true;
  final int _maxChars = 138;
  final FocusNode _focusNode =
      FocusNode(); // Dedicated focus node for the TextField

  final List<String> defaultStatuses = [
    "Available",
    "Busy",
    "At the gym",
    "Sleeping",
    "In a meeting",
    "Can't talk, WhatsApp only",
    "At work",
    "Battery about to die",
    "In class",
    "Urgent calls only"
  ];

  final List<String> recentStatus = [];

  @override
  void initState() {
    super.initState();
    _loadRecentStatuses();
    currentStatus = widget.currentUser.status?.trim().isNotEmpty == true
        ? widget.currentUser.status!
        : "Hey there! I am using WhatsApp.";
    _statusController = TextEditingController(text: currentStatus);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmojiIcon) {
        setState(() {
          _showEmojiIcon = false;
        });
      } else if (!_focusNode.hasFocus && !_showEmojiIcon) {
        setState(() {
          _showEmojiIcon = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _statusController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleKeyboardOrEmoji() {
    setState(() {
      _showEmojiIcon = !_showEmojiIcon;
      if (_showEmojiIcon) {
        // if we want to show emoji unfocus to dismiss keyboard
        FocusScope.of(context).unfocus();
      } else {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
    // For actual emoji keyboard, you'd show/hide your custom emoji widget here
    // based on _showEmojiIcon.
  }

  void _selectStatus(String status) {
    if (status == currentStatus) return;

    setState(() {
      currentStatus = status;
      _statusController.text = status;
    });

    Future.microtask(() => _submitStatus());
  }

  Future<void> _loadRecentStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('recent_status_list') ?? [];
    setState(() {
      recentStatus.clear();
      recentStatus.addAll(saved);
    });
  }

  Future<void> _saveRecentStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_status_list', recentStatus);
  }

  @override
  Widget build(BuildContext context) {
    final allStatuses = [...recentStatus, ...defaultStatuses];

    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
        actions: [
          PopupMenuButton(
            icon: const Icon(
              Icons.more_vert,
              color: greyColor,
              size: 28,
            ),
            offset: const Offset(0, 53),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: appBarColor,
            iconSize: 28,
            onSelected: (value) {
              if (value == 'delete_all') {
                setState(() {
                  recentStatus.clear();
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete_all',
                child: Text('Delete all'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 17),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Currently set to",
                  style: TextStyle(
                    color: greyColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 18),
                InkWell(
                  onTap: () {
                    final parentContext = context;
                    _showEditStatusBottomSheet(parentContext);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          currentStatus,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.edit_outlined,
                        color: tabColor,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 7),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select About",
                  style: TextStyle(
                    color: greyColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 18),
                ...allStatuses.map((status) => ListTile(
                      title: Text(status),
                      trailing: status == currentStatus
                          ? const Icon(
                              Icons.check,
                              color: tabColor,
                            )
                          : null,
                      onTap: () => _selectStatus(status),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditStatusBottomSheet(BuildContext parentContext) {
    _statusController.text = currentStatus;
    // Auto-select all text like WhatsApp
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _statusController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _statusController.text.length,
      );
    });
    showModalBottomSheet(
      context: parentContext,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: appBarColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(),
      ),
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Add About",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 13),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _statusController,
                        focusNode: _focusNode,
                        maxLength: _maxChars,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(_maxChars)
                        ],
                        decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: tabColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: tabColor,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: tabColor),
                            ),
                            counterText: ""),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Align(
                      alignment: Alignment.center,
                      child: IconButton(
                        onPressed: _toggleKeyboardOrEmoji,
                        icon: Icon(_showEmojiIcon
                            ? Icons.emoji_emotions_outlined
                            : Icons.keyboard_alt_outlined),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: tabColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _submitStatus();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: tabColor),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitStatus() {
    final editedStatus = _statusController.text.trim();
    if (editedStatus.isNotEmpty) {
      setState(() {
        currentStatus = editedStatus;
        if (!defaultStatuses.contains(currentStatus) &&
            !recentStatus.contains(currentStatus)) {
          recentStatus.insert(0, currentStatus);
          _saveRecentStatuses();
        }
      });
      BlocProvider.of<UserCubit>(context)
          .updateUser(
              user: UserEntity(
        uid: widget.currentUser.uid,
        email: "",
        username: widget.currentUser.username,
        phoneNumber: widget.currentUser.phoneNumber,
        status: currentStatus,
        isOnline: false,
        profileUrl: widget.currentUser.profileUrl,
      ))
          .then((_) {
        // Refresh the single user data to reflect changes
        BlocProvider.of<GetSingleUserCubit>(context)
            .getSingleUser(uid: widget.currentUser.uid!);
        toast("status updated");
      }).catchError((e) {
        toast("Error updating status: $e");
      });
    }
  }
}
