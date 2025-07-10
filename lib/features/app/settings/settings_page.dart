import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp_clone/features/app/const/page_const.dart';
import 'package:whatsapp_clone/features/app/global/widgets/dialog_widget.dart';
import 'package:whatsapp_clone/features/app/global/widgets/profile_widget.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';
import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/auth/auth_cubit.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/get_single_user/get_single_user_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.uid});

  final String uid;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    BlocProvider.of<GetSingleUserCubit>(context).getSingleUser(uid: widget.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Settings"),
        actions: [
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
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: greyColor.withOpacity(0.15),
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          BlocBuilder<GetSingleUserCubit, GetSingleUserState>(
            builder: (context, state) {
              if (state is GetSingleUserLoaded) {
                final singleUser = state.singleUser;
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      PageConst.editProfilePage,
                      arguments: singleUser,
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: profileWidget(
                                  imageUrl: singleUser.profileUrl)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${singleUser.username}",
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                "${singleUser.status}",
                                style: const TextStyle(color: greyColor),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.qr_code_sharp,
                                color: tabColor,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: tabColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(context, PageConst.editProfilePage,
                      arguments: const UserEntity(
                          username: '',
                          email: '',
                          phoneNumber: '',
                          isOnline: false,
                          uid: '',
                          status: '',
                          profileUrl: ''));
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: profileWidget(),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "...",
                              style: TextStyle(fontSize: 15),
                            ),
                            Text(
                              "...",
                              style: TextStyle(color: greyColor),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.qr_code_sharp,
                              color: tabColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: tabColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Divider(
            color: greyColor.withOpacity(0.17),
          ),
          const SizedBox(height: 10),
          _settingsItemWidget(
            title: "Account",
            description: "Security applications, change number",
            icon: Icons.key,
            onTap: () {},
          ),
          _settingsItemWidget(
            title: "Privacy",
            description: "Block contacts, disappearing messages",
            icon: Icons.lock,
            onTap: () {},
          ),
          _settingsItemWidget(
            title: "Chats",
            description: "Theme, wallpapers, chat history",
            icon: Icons.message,
            onTap: () {},
          ),
          _settingsItemWidget(
            title: "Logout",
            description: "Logout, from WhatsApp Clone",
            icon: Icons.exit_to_app,
            onTap: () {
              displayAlertDialog(
                context,
                onTap: () {
                  BlocProvider.of<AuthCubit>(context).loggedOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, PageConst.welcomePage, (route) => false);
                },
                confirmTitle: "Logout",
                content: "Are you sure you want to logout?",
              );
            },
          ),
        ],
      ),
    );
  }

  _settingsItemWidget(
      {String? title,
      String? description,
      IconData? icon,
      VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Icon(
              icon,
              color: greyColor,
              size: 25,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$title",
                  style: const TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 3),
                Text(
                  "$description",
                  style: const TextStyle(color: greyColor),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
