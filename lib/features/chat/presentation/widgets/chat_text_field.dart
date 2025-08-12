import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:whatsapp_clone/features/app/const/message_type_const.dart';
import 'package:whatsapp_clone/features/app/global/widgets/whatsapp_image_picker.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';
import 'package:whatsapp_clone/features/chat/domain/entities/message_entity.dart';
import 'package:whatsapp_clone/features/chat/domain/entities/message_reply_entity.dart';
import 'package:whatsapp_clone/features/chat/presentation/cubit/message/message_cubit.dart';
import 'package:whatsapp_clone/features/chat/presentation/widgets/chat_utils.dart';

import 'emoji_bottomSheet.dart';

class ChatTextField extends StatefulWidget {
  const ChatTextField({
    super.key,
    required this.message,
    required this.scrollController,
  });

  final MessageEntity message;
  final ScrollController scrollController;

  @override
  State<ChatTextField> createState() => ChatTextFieldState();
}

class ChatTextFieldState extends State<ChatTextField> {
  late TextEditingController messageController;

  bool isMessageIconEnabled = false;
  double cardHeight = 0;
  bool isShowEmojiKeyboard = false;
  FocusNode focusNode = FocusNode();

  // Method to close all menus (called from parent)
  void closeAllMenus() {
    setState(() {
      cardHeight = 0;
      isShowEmojiKeyboard = false;
    });
    _hideKeyboard();
  }

  @override
  void initState() {
    messageController = TextEditingController();
    super.initState();

    // Listen to focus changes to handle keyboard/emoji toggle
    focusNode.addListener(() {
      if (focusNode.hasFocus && isShowEmojiKeyboard) {
        setState(() {
          isShowEmojiKeyboard = false;
        });
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _hideEmojiContainer() {
    setState(() {
      isShowEmojiKeyboard = false;
    });
  }

  void _showEmojiContainer() {
    setState(() {
      isShowEmojiKeyboard = true;
    });
  }

  void _showKeyboard() => focusNode.requestFocus();
  void _hideKeyboard() => focusNode.unfocus();

  void toggleEmojiKeyboard() {
    if (isShowEmojiKeyboard) {
      _showKeyboard();
      _hideEmojiContainer();
    } else {
      // showEmojiPicker(context);
      _hideKeyboard();
      _showEmojiContainer();
    }
  }

  Future<void> _scrollToBottom() async {
    if (widget.scrollController.hasClients) {
      await Future.delayed(const Duration(milliseconds: 100));
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onEmojiSelected(String emoji) {
    final currentPosition = messageController.selection.base.offset;
    final currentText = messageController.text;

    final newText = currentText.substring(0, currentPosition) +
        emoji +
        currentText.substring(currentPosition);

    messageController.text = newText;
    messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: currentPosition + emoji.length),
    );

    // update message icon state
    setState(() {
      isMessageIconEnabled = messageController.text.isNotEmpty;
    });
  }

  void _onBackspacePressed() {
    final currentPosition = messageController.selection.base.offset;
    if (currentPosition > 0) {
      final currentText = messageController.text;
      final newText = currentText.substring(0, currentPosition - 1) +
          currentText.substring(currentPosition);

      messageController.text = newText;
      messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: currentPosition - 1),
      );

      setState(() {
        isMessageIconEnabled = messageController.text.isNotEmpty;
      });
    }
  }

  void _onGifSelected() {
    // Handle GIF selection
    _hideEmojiContainer(); // Close emoji picker
    // TODO: Implement GIF sending logic
    print('GIF selected');
  }

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
                  focusNode: focusNode,
                  onTap: () {
                    setState(() {
                      cardHeight = 0;
                    });
                  },
                  controller: messageController,
                  maxLines: 4,
                  minLines: 1,
                  onChanged: (value) {
                    // value.isEmpty
                    //     ? setState(() => isMessageIconEnabled = false)
                    //     : setState(() => isMessageIconEnabled = true);
                    setState(() {
                      isMessageIconEnabled = value.isNotEmpty;
                    });
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
                            onPressed: toggleEmojiKeyboard,
                            icon: Icon(
                              isShowEmojiKeyboard == false
                                  ? Icons.emoji_emotions_outlined
                                  : Icons.keyboard_outlined,
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
                                  if (cardHeight == 0) {
                                    cardHeight = 220;
                                    // Hide emoji keyboard when showing attachments
                                    isShowEmojiKeyboard = false;
                                    _hideKeyboard();
                                  } else {
                                    cardHeight = 0;
                                  }
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
                  onPressed: _sendTextMessage,
                  icon: Icon(
                    isMessageIconEnabled ? Icons.send : Icons.mic_outlined,
                    // size: 28,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),

        // Emoji picker = This replaces the modal bottom sheet approach
        if (isShowEmojiKeyboard)
          EmojiBottomsheet(
            onEmojiSelected: _onEmojiSelected,
            onBackspace: _onBackspacePressed,
            onGifSelected: _onGifSelected,
            onClose: () {
              setState(() {
                isShowEmojiKeyboard = false;
              });
            },
          )
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

  _sendTextMessage() async {
    final provider = BlocProvider.of<MessageCubit>(context);

    if (isMessageIconEnabled || messageController.text.isNotEmpty) {
      if (provider.messageReplay.message != null) {
        _sendMessage(
          message: messageController.text,
          type: MessageTypeConst.textMessage,
          repliedMessage: provider.messageReplay.message,
          repliedTo: provider.messageReplay.username,
          repliedMessageType: provider.messageReplay.messageType,
        );
      } else {
        _sendMessage(
          message: messageController.text,
          type: MessageTypeConst.textMessage,
        );
      }

      provider.setMessageReplay = MessageReplayEntity();
      setState(() {
        messageController.clear();
      });
    }
  }

  void _sendMessage(
      {required String message,
      required String type,
      String? repliedMessage,
      String? repliedTo,
      String? repliedMessageType}) {
    _scrollToBottom();
    ChatUtils.sendMessage(context,
            messageEntity: widget.message,
            message: message,
            type: type,
            repliedTo: repliedTo,
            repliedMessageType: repliedMessageType,
            repliedMessage: repliedMessage)
        .then((value) {
      _scrollToBottom();
    });
  }
}
