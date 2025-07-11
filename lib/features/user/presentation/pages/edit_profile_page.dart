import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp_clone/features/app/const/app_const.dart';
import 'package:whatsapp_clone/features/app/const/page_const.dart';
import 'package:whatsapp_clone/features/app/global/widgets/dialog_widget.dart';
import 'package:whatsapp_clone/features/app/global/widgets/profile_widget.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';
import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/credential/credential_cubit.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/user/user_cubit.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/get_single_user/get_single_user_cubit.dart';
import 'package:whatsapp_clone/features/user/presentation/pages/edit_name_page.dart';
import 'package:whatsapp_clone/features/user/presentation/pages/image_preview_page.dart';

class EditProfilePage extends StatefulWidget {
  final UserEntity currentUser;

  const EditProfilePage({super.key, required this.currentUser});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _image;
  bool _isProfileUpdating = false;

  Future selectGaleryImage() async {
    try {
      final pickedFile = await ImagePicker.platform
          .getImageFromSource(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isProfileUpdating = true;
        });
        submitNewProfilePhoto();
      } else {
        debugPrint("no image has been selected");
      }
    } catch (e) {
      toast("some error occured $e");
    }
  }

  @override
  void initState() {
    // Initialize the cubit with current user data
    BlocProvider.of<GetSingleUserCubit>(context)
        .getSingleUser(uid: widget.currentUser.uid!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Profile"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: greyColor.withOpacity(0.17), // light grey divider line
            height: 1.0,
          ),
        ),
      ),
      body: BlocBuilder<GetSingleUserCubit, GetSingleUserState>(
        builder: (context, state) {
          // Use updated user data if available, otherwise fallback to widget.currentUser
          final currentUser = state is GetSingleUserLoaded
              ? state.singleUser
              : widget.currentUser;

          return SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 170,
                        height: 170,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: greyColor, width: 2),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ImagePreviewPage(
                                      currentUser: currentUser,
                                      heroTag: "profileImage",
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: "profileImage",
                                child: Material(
                                  color: Colors.transparent,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        85), // Slightly larger than 75 to account for border
                                    child: profileWidget(
                                      imageUrl: currentUser.profileUrl,
                                      image: _image,
                                      width:
                                          166, // Container width minus border (170 - 4)
                                      height:
                                          166, // Container height minus border (170 - 4)
                                      isCircular: true,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_isProfileUpdating)
                              Container(
                                width: 166,
                                height: 166,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: tabColor,
                                    strokeWidth: 3,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          final parentContext = context;
                          _showBottomSheet(parentContext);
                        },
                        child: const Text(
                          "Edit",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: tabColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _profileItem(
                  title: "Name",
                  username: currentUser.username,
                  icon: Icons.person_2_outlined,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditNamePage(currentUser: currentUser),
                        ));
                  },
                ),
                _profileItem(
                  title: "About",
                  username: currentUser.status,
                  icon: Icons.info_outline,
                  onTap: () {
                    Navigator.pushNamed(context, PageConst.editStatusPage,
                        arguments: currentUser);
                  },
                ),
                _profileItem(
                  title: "Phone",
                  username: currentUser.phoneNumber,
                  icon: Icons.phone_outlined,
                  onTap: () {},
                ),
                _profileItem(
                  title: "Links",
                  username: "Add links",
                  icon: Icons.link,
                  onTap: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _profileItem({
    String? title,
    String? username,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
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
                "$username",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: username == "Add links"
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: username == "Add links" ? tabColor : greyColor,
                ),
              )
            ],
          ))
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext parentContext) {
    showModalBottomSheet(
        context: parentContext,
        enableDrag: false,
        showDragHandle: true,
        isScrollControlled: true,
        backgroundColor: appBarColor,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            // constraints: BoxConstraints(
            //   maxHeight:
            //       MediaQuery.of(context).size.height * 0.6, // Limit height
            // ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 25,
                      ),
                    ),
                    const Text(
                      "Profile Photo",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await Future.delayed(
                            const Duration(milliseconds: 300)); // small delay
                        displayAlertDialog(
                          parentContext,
                          onTap: () {},
                          confirmTitle: "Remove",
                          content: "Remove profile photo?",
                        );
                      },
                      icon: const Icon(
                        Icons.delete,
                        size: 25,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    iconCreation(
                      context,
                      Icons.camera_alt_outlined,
                      "Camera",
                    ),
                    const SizedBox(width: 12),
                    iconCreation(
                      context,
                      Icons.image_outlined,
                      "Gallery",
                    ),
                    const SizedBox(width: 12),
                    iconCreation(
                      context,
                      Icons.face,
                      "Avatar",
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        });
  }

  Widget iconCreation(BuildContext context, IconData icon, String text) {
    return InkWell(
      onTap: () {
        // Handle icon tap
        print('$text tapped');
        if (text == "Camera") {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const CameraScreen()),
          // );
        } else if (text == "Gallery") {
          selectGaleryImage();
        } else {
          // Handle other icon taps if needed
        }
      },
      child: Column(
        children: [
          Container(
              width: 90,
              height: 75,
              // padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                // color: appBarColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: greyColor,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: tabColor,
                    size: 30,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }

  void submitNewProfilePhoto() {
    if (_image != null) {
      BlocProvider.of<CredentialCubit>(context)
          .uploadProfileImage(
              file: _image!,
              onComplete: (onProfileUpdateComplete) {
                setState(() {
                  _isProfileUpdating = onProfileUpdateComplete;
                });
              })
          .then((profileImageUrl) {
        BlocProvider.of<UserCubit>(context)
            .updateUser(
                user: UserEntity(
          uid: widget.currentUser.uid,
          email: "",
          username: widget.currentUser.username,
          phoneNumber: widget.currentUser.phoneNumber,
          status: widget.currentUser.status,
          isOnline: false,
          profileUrl: profileImageUrl,
        ))
            .then((_) {
          // Refresh the single user data to reflect changes
          BlocProvider.of<GetSingleUserCubit>(context)
              .getSingleUser(uid: widget.currentUser.uid!);
          toast("Profile photo updated");
          setState(() {
            _isProfileUpdating = false; // Stop spinner after update
          });
        }).catchError((e) {
          toast("Error updating profile: $e");
          setState(() {
            _isProfileUpdating = false;
          });
        }).catchError((e) {
          toast("Error uploading Image: $e");
          setState(() {
            _isProfileUpdating = false;
          });
        });
      });
    }
  }
}
