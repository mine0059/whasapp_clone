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
import 'package:whatsapp_clone/features/user/presentation/cubit/user/user_cubit.dart';
import 'package:whatsapp_clone/features/user/presentation/pages/edit_name_page.dart';
import 'package:whatsapp_clone/features/user/presentation/pages/image_preview_page.dart';
import 'package:whatsapp_clone/storage/storage_provider.dart';

class EditProfilePage extends StatefulWidget {
  final UserEntity currentUser;

  const EditProfilePage({super.key, required this.currentUser});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _aboutController = TextEditingController();

  File? _image;
  bool _isProfileUpdating = false;

  Future selectImage() async {
    try {
      final pickedFile = await ImagePicker.platform
          .getImageFromSource(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isProfileUpdating = true;
        });
        submitProfilePhoto();
      } else {
        debugPrint("no image has been selected");
      }
    } catch (e) {
      toast("some error occured $e");
    }
  }

  @override
  void initState() {
    _aboutController = TextEditingController(text: widget.currentUser.status);
    super.initState();
  }

  @override
  void dispose() {
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
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
                      border: Border.all(
                          color: greyColor, width: 2), // Border added here
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
                                  currentUser: widget.currentUser,
                                ),
                              ),
                            );
                          },
                          child: Hero(
                            tag: "profileImage",
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(75),
                              child: profileWidget(
                                imageUrl: widget.currentUser.profileUrl,
                                image: _image,
                              ),
                            ),
                          ),
                        ),
                        if (_isProfileUpdating)
                          const CircularProgressIndicator(
                            color: tabColor,
                            strokeWidth: 3,
                          )
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
              username: widget.currentUser.username,
              icon: Icons.person_2_outlined,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditNamePage(currentUser: widget.currentUser),
                    ));
              },
            ),
            _profileItem(
              title: "About",
              username: widget.currentUser.status,
              icon: Icons.info_outline,
              onTap: () {
                Navigator.pushNamed(context, PageConst.editStatusPage,
                    arguments: widget.currentUser);
              },
            ),
            _profileItem(
              title: "Phone",
              username: widget.currentUser.phoneNumber,
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
          selectImage();
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

  void submitProfilePhoto() {
    if (_image != null) {
      StorageProviderRemoteDatasource.uploadProfileImage(
          file: _image!,
          onComplete: (onProfileUpdateComplete) {
            setState(() {
              _isProfileUpdating = onProfileUpdateComplete;
            });
          }).then((profileImageUrl) {
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
          toast("Profile photo updated");
          setState(() {
            _isProfileUpdating = false; // Stop spinner after update
          });
        }).catchError((e) {
          toast("Error updating profile: $e");
          setState(() {
            _isProfileUpdating = false;
          });
        });
      }).catchError((e) {
        toast("Error uploading Image: $e");
        setState(() {
          _isProfileUpdating = false;
        });
      });
    }
  }
}
