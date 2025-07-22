import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:whatsapp_clone/features/app/global/widgets/whatsapp_image_picker.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';

class ChatTextField extends StatefulWidget {
  const ChatTextField({super.key, required this.receiverId});

  final String receiverId;

  @override
  State<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  late TextEditingController messageController;

  bool isMessageIconEnabled = false;
  double cardHeight = 0;

  void sendImageMessageFromGallery() async {
    // Close the attach menu first
    setState(() {
      cardHeight = 0;
    });

    showWhatsAppImagePicker(
      context,
      mode: PickerMode.chat,
      onImagesSelected: (List<SelectedImage> selectedImages) {
        // Handle multiple selected images
        print('Selected ${selectedImages.length} images');
        for (var selectedImage in selectedImages) {
          print('Image: ${selectedImage.asset.id}');
          print('Size: ${selectedImage.imageData.length} bytes');
          print('Selection order: ${selectedImage.selectionOrder}');

          // TODO: Send each image message
          // sendImageMessage(selectedImage.imageData, selectedImage.asset);
        }
      },
      onImageSelected: (Uint8List imageData, AssetEntity asset) {
        // Handle the selected image here
        print('Selected image: ${asset.id}');
        print('Image size: ${imageData.length} bytes');

        // TODO: Send the image message
        // You can call your send image message function here
        // sendImageMessage(imageData, asset);
      },
    );
    // final image = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => const ImagePickerWidget(),
    //   ),
    // );
  }

  @override
  void initState() {
    messageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: cardHeight,
          width: double.maxFinite,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: blackColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      _attachWindowItem(
                        icon: Icons.photo_outlined,
                        label: "Gallery",
                        color: Colors.indigo,
                        onTap: sendImageMessageFromGallery,
                      ),
                      _attachWindowItem(
                        icon: Icons.camera_alt_outlined,
                        label: "Camera",
                        color: Colors.redAccent,
                        onTap: () {},
                      ),
                      _attachWindowItem(
                        icon: Icons.location_on,
                        label: "Location",
                        color: Colors.greenAccent,
                        onTap: () {},
                      ),
                      _attachWindowItem(
                        icon: Icons.person,
                        label: "Contact",
                        color: const Color.fromARGB(255, 57, 162, 241),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _attachWindowItem(
                        icon: Icons.insert_drive_file_outlined,
                        label: "Document",
                        color: Colors.purple,
                        onTap: () {},
                      ),
                      _attachWindowItem(
                        icon: Icons.headphones,
                        label: "Audio",
                        color: const Color.fromARGB(255, 255, 124, 64),
                        onTap: () {},
                      ),
                      _attachWindowItem(
                        icon: Icons.poll_outlined,
                        label: "Poll",
                        color: Colors.yellow,
                        onTap: () {},
                      ),
                      _attachWindowItem(
                        icon: Icons.event_outlined,
                        label: "Event",
                        color: const Color.fromARGB(255, 233, 52, 52),
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: messageController,
                  maxLines: 4,
                  minLines: 1,
                  onChanged: (value) {
                    value.isEmpty
                        ? setState(() => isMessageIconEnabled = false)
                        : setState(() => isMessageIconEnabled = true);
                  },
                  decoration: InputDecoration(
                      hintText: 'Message',
                      hintStyle: const TextStyle(color: greyColor),
                      filled: true,
                      fillColor: chatBarMessageColor,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          style: BorderStyle.none,
                          width: 0,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      prefixIcon: Material(
                        color: Colors.transparent,
                        child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.emoji_emotions_outlined,
                              color: greyColor,
                              size: 23,
                            )),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  cardHeight == 0
                                      ? cardHeight = 220
                                      : cardHeight = 0;
                                });
                              },
                              icon: const Icon(
                                Icons.attach_file,
                                color: greyColor,
                                size: 23,
                              )),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                color: greyColor,
                                size: 23,
                              )),
                        ],
                      )),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: tabColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      isMessageIconEnabled ? Icons.send : Icons.mic_outlined,
                      // size: 28,
                      color: Colors.white,
                    )),
              )
            ],
          ),
        ),
      ],
    );
  }

  _attachWindowItem({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF1E272C),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF2A3942),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: greyColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
