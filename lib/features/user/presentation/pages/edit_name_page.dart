import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp_clone/features/app/const/app_const.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';
import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/user/user_cubit.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/get_single_user/get_single_user_cubit.dart';

class EditNamePage extends StatefulWidget {
  const EditNamePage({super.key, required this.currentUser});

  final UserEntity currentUser;

  @override
  State<EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends State<EditNamePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  bool _showEmojiIcon = true;
  final int _maxChars = 25;

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.currentUser.username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _toggleKeyboardOrEmoji() {
    setState(() {
      _showEmojiIcon = !_showEmojiIcon;
      // You can trigger custom emoji keyboard logic here.
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Name"),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(18.0, 0.0, 18.0, 26.0),
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 24.0),
                    TextFormField(
                      controller: _usernameController,
                      maxLength: _maxChars,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(_maxChars)
                      ],
                      decoration: InputDecoration(
                        labelText: 'Your name',
                        suffixIcon: IconButton(
                          onPressed: _toggleKeyboardOrEmoji,
                          icon: Icon(_showEmojiIcon
                              ? Icons.emoji_emotions_outlined
                              : Icons.keyboard_alt_outlined),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: tabColor),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: tabColor,
                          ),
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: tabColor),
                        ),
                      ),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "People will see this name if you interact with them and they dont't have you saved as a contact.",
                      style: TextStyle(fontSize: 15, color: greyColor),
                    ),
                  ],
                ))),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(18.0, 0.0, 18.0, 20.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: tabColor,
                foregroundColor: blackColor,
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  _submitUsername();
                }
              },
              child: const Text("Save")),
        ),
      ),
    );
  }

  void _submitUsername() {
    if (_usernameController.text.isNotEmpty) {
      BlocProvider.of<UserCubit>(context)
          .updateUser(
              user: UserEntity(
        uid: widget.currentUser.uid,
        email: "",
        username: _usernameController.text,
        phoneNumber: widget.currentUser.phoneNumber,
        status: widget.currentUser.status,
        isOnline: false,
        profileUrl: widget.currentUser.profileUrl,
      ))
          .then((_) {
        // Refresh the single user data to reflect changes
        BlocProvider.of<GetSingleUserCubit>(context)
            .getSingleUser(uid: widget.currentUser.uid!);
        toast("username updated");
      }).catchError((e) {
        toast("Error updating username: $e");
      });
    }
  }
}
