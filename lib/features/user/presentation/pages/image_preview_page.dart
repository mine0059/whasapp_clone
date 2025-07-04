import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/app/global/widgets/profile_widget.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';
import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';

class ImagePreviewPage extends StatelessWidget {
  const ImagePreviewPage({super.key, required this.currentUser});

  final UserEntity currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Profile photo"),
        actions: [
          IconButton(
            onPressed: () {
              // Handle edit icon tap
              // _showBottomSheet(context);
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: greyColor.withOpacity(0.15), // light grey divider line
            height: 1.0,
          ),
        ),
      ),
      body: Center(
        child: Hero(
            tag: "profileImage",
            child: InteractiveViewer(
              child: profileWidget(imageUrl: currentUser.profileUrl),
            )),
      ),
    );
  }
}
