import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/app/global/widgets/profile_widget.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';
import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';

class ImagePreviewPage extends StatelessWidget {
  const ImagePreviewPage({
    super.key,
    required this.currentUser,
    this.heroTag = "profileImage",
  });

  final UserEntity currentUser;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Profile Photo",
          style: TextStyle(color: greyColor),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Add edit functionality here
              Navigator.pop(context);
            },
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: greyColor.withOpacity(0.17), // light grey divider line
            height: 1.0,
          ),
        ),
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: Material(
            color: Colors.transparent,
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width, // Make it square
                child: profileWidget(
                  imageUrl: currentUser.profileUrl,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  isCircular: false, // Full rectangular view for preview
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
