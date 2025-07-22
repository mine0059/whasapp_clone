import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:whatsapp_clone/features/app/theme/styles.dart';

enum MediaType { recent, camera, videos, screenshots, whatsapp }

enum PickerMode { chat, status }

class WhatsappImagePicker extends StatefulWidget {
  const WhatsappImagePicker({
    super.key,
    this.onImageSelected,
    this.onImagesSelected, // For multiple selection (chat mode)
    this.scrollController,
    this.mode = PickerMode.chat,
  });

  final Function(Uint8List imageData, AssetEntity assets)? onImageSelected;
  final Function(List<SelectedImage> selectedImage)? onImagesSelected;
  final ScrollController? scrollController;
  final PickerMode mode;

  @override
  State<WhatsappImagePicker> createState() => _WhatsappImagePickerState();
}

class _WhatsappImagePickerState extends State<WhatsappImagePicker> {
  List<AssetEntity> mediaAssets = []; // Store assets
  Map<String, Uint8List?> imageCache = {}; // Cache loaded images
  List<AssetPathEntity> albums = [];
  Map<String, Uint8List?> albumThumbnails = {};
  Map<String, int> albumCounts = {};
  AssetPathEntity? selectedAlbum; // Track currently selected album
  bool isHDEnabled = false;
  int currentPage = 0;
  int? lastPage;
  bool isLoading = false;

  // selection state for chat mode
  List<SelectedImage> selectedImages = [];
  Map<String, int> selectedImageIds = {}; // asset.id -> selection order
  TextEditingController captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAllMedia();
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  handleScrollEvent(ScrollNotification scroll) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent <= 0.8) return;
    if (currentPage == lastPage) return;
    if (isLoading) return;
    fetchAllMedia();
  }

  fetchAllMedia() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    lastPage = currentPage;
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      PhotoManager.openSetting();
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Get all image albums on first load
    if (currentPage == 0) {
      albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: false, // Get all albums, not just "Recent"
      );

      // Set the first album (usually "Recent" or "All Photos") as selected
      if (albums.isNotEmpty) {
        selectedAlbum = albums[0];
      }

      // Load album thumbnails and counts
      await _loadAlbumThumbnails();
    }

    if (albums.isEmpty || selectedAlbum == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Get media from the currently selected album
    List<AssetEntity> media = await selectedAlbum!.getAssetListPaged(
      page: currentPage,
      size: 24,
    );

    if (media.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // preload thumbnails for better performance
    for (var asset in media) {
      if (!imageCache.containsKey(asset.id)) {
        try {
          final thumbnailData = await asset.thumbnailDataWithSize(
            const ThumbnailSize(200, 200),
          );
          imageCache[asset.id] = thumbnailData;
        } catch (e) {
          imageCache[asset.id] = null;
        }
      }
    }

    setState(() {
      if (currentPage == 0) {
        mediaAssets = media;
      } else {
        mediaAssets.addAll(media);
      }
      currentPage++;
      isLoading = false;
    });
  }

  // load thumbnails and counts for all albums
  Future<void> _loadAlbumThumbnails() async {
    for (var album in albums) {
      // Get album count
      final assetCount = await album.assetCountAsync;
      albumCounts[album.id] = assetCount;

      // Get first image as thumbnail (only if album has images)
      if (assetCount > 0) {
        try {
          final assets = await album.getAssetListPaged(page: 0, size: 1);
          if (assets.isNotEmpty) {
            final thumbnailData = await assets[0].thumbnailDataWithSize(
              const ThumbnailSize(50, 50),
            );
            albumThumbnails[album.id] = thumbnailData;
          }
        } catch (e) {
          albumThumbnails[album.id] = null;
        }
      } else {
        albumThumbnails[album.id] = null;
      }
    }
  }

  void _toggleImageSelection(AssetEntity asset, Uint8List imageData) {
    setState(() {
      if (selectedImageIds.containsKey(asset.id)) {
        // remove from selection
        final removedOrder = selectedImageIds[asset.id]!;
        selectedImageIds.remove(asset.id);
        selectedImages.removeWhere((img) => img.asset.id == asset.id);

        // update selected orders for remaining images
        for (var i = 0; i < selectedImages.length; i++) {
          if (selectedImages[i].selectionOrder > removedOrder) {
            selectedImageIds[selectedImages[i].asset.id] =
                selectedImages[i].selectionOrder - 1;
            selectedImages[i] = SelectedImage(
              asset: selectedImages[i].asset,
              imageData: selectedImages[i].imageData,
              selectionOrder: selectedImages[i].selectionOrder - 1,
            );
          }
        }
      } else {
        // Add to selection
        final selectionOrder = selectedImages.length + 1;
        selectedImageIds[asset.id] = selectionOrder;
        selectedImages.add(SelectedImage(
          asset: asset,
          imageData: imageData,
          selectionOrder: selectionOrder,
        ));
      }
    });
  }

  void _handleImageTap(AssetEntity asset, Uint8List imageData) {
    debugPrint('Image taped');
    if (widget.mode == PickerMode.chat) {
      _toggleImageSelection(asset, imageData);
    } else {
      // Status mode - single selection and immediate callback
      if (widget.onImageSelected != null) {
        widget.onImageSelected!(imageData, asset);
      }
      Navigator.pop(context, {'data': imageData, 'asset': asset});
    }
  }

  void _sendSelectedImages() {
    if (selectedImages.isNotEmpty) {
      if (widget.onImagesSelected != null) {
        widget.onImagesSelected!(selectedImages);
      }
      Navigator.pop(context, {
        'selectedImages': selectedImages,
        'caption': captionController.text,
      });
    }
  }

  Widget _buildMediaItem(AssetEntity asset, Uint8List imageData) {
    final isSelected = selectedImageIds.containsKey(asset.id);
    final selectionOrder = selectedImageIds[asset.id];

    return GestureDetector(
      onTap: () => _handleImageTap(asset, imageData),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Main image
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: MemoryImage(imageData),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Overlay for selected image in chat mode
            if (isSelected && widget.mode == PickerMode.chat)
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white
                      .withOpacity(0.4), // Changed to white with opacity
                ),
              ),
            // Video duration indicator for videos
            if (asset.type == AssetType.video)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatDuration(asset.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            // Selection indicator
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: isSelected
                    ? BoxDecoration(
                        color: isSelected
                            ? Colors.green
                            : Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      )
                    : null,
                child: isSelected
                    ? Center(
                        child: Text(
                          selectionOrder.toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Load media from a specific album
  Future<void> _loadMediaFromAlbum(AssetPathEntity album) async {
    setState(() {
      isLoading = true;
      selectedAlbum = album;
      mediaAssets.clear();
      imageCache.clear(); // Clear cache when switching albums
      // mediaList.clear();
      currentPage = 0;
      lastPage = null;
    });

    List<AssetEntity> media = await album.getAssetListPaged(
      page: 0,
      size: 24,
    );

    if (media.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Preload thumbnails
    for (var asset in media) {
      try {
        final thumbnailData = await asset.thumbnailDataWithSize(
          const ThumbnailSize(200, 200),
        );
        imageCache[asset.id] = thumbnailData;
      } catch (e) {
        imageCache[asset.id] = null;
      }
    }

    setState(() {
      mediaAssets = media;
      currentPage = 1;
      isLoading = false;
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Build album dropdown item with thumbnail, name, count, and selection indicator
  Widget _buildAlbumItem(AssetPathEntity album, bool isSelected) {
    final thumbnail = albumThumbnails[album.id];
    final count = albumCounts[album.id] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Album thumbnail or placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[300],
            ),
            child: thumbnail != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      thumbnail,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.folder_outlined,
                    color: Colors.grey[600],
                    size: 20,
                  ),
          ),
          const SizedBox(width: 12),
          // Album name and count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  album.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count items',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Selection indicator
          if (isSelected)
            const Icon(
              Icons.check,
              color: Colors.green,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildBottomSelectionBar() {
    if (widget.mode != PickerMode.chat || selectedImages.isEmpty) {
      return const SizedBox.shrink();
    }

    final latestImage = selectedImages.last;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // selected Image preview with edit icon
          GestureDetector(
            onTap: () {
              // Todo: Open image editor
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: MemoryImage(latestImage.imageData),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withOpacity(0.3),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Caption text Field
          Expanded(
            child: TextField(
              controller: captionController,
              decoration: InputDecoration(
                hintText: 'Add a caption...',
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 12),
          // send button with const
          GestureDetector(
            onTap: _sendSelectedImages,
            child: Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: tabColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
                if (selectedImages.length > 1)
                  Positioned(
                    top: -5,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: tabColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Text(
                        selectedImages.length.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Custom drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header content
          Row(
            children: [
              // Close button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.close,
                  color: Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Media type dropdown - centered
              Expanded(
                child: Center(
                  child: PopupMenuButton<AssetPathEntity>(
                    // color: appBarColor,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    // Add offset to move popup menu down
                    offset: const Offset(0, 48), // This moves the menu down
                    elevation: 5, // Add elevation for modern shadow
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ),
                    onSelected: (AssetPathEntity? album) {
                      if (album != null) {
                        // Handle album selection
                        setState(() {
                          mediaAssets.clear();
                          currentPage = 0;
                          lastPage = null;
                        });
                        // Load media from selected album
                        _loadMediaFromAlbum(album);
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedAlbum?.name ?? 'Recents',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                        ),
                      ],
                    ),
                    itemBuilder: (context) => [
                      ...albums.map((album) => PopupMenuItem(
                            value: album,
                            child:
                                _buildAlbumItem(album, album == selectedAlbum),
                          )),
                      PopupMenuItem(
                        value: null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: appBarColor
                                    // color: Colors.grey[300],
                                    ),
                                child: const Icon(
                                  Icons.folder_copy,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(child: Text('See more'))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // HD toggle
              GestureDetector(
                onTap: () {
                  setState(() {
                    isHDEnabled = !isHDEnabled;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isHDEnabled ? Colors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isHDEnabled ? Colors.green : Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'HD',
                    style: TextStyle(
                      color: isHDEnabled ? Colors.white : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        // color: Colors.red,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          // Media grid
          Expanded(
            child: mediaAssets.isEmpty && isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: tabColor),
                  )
                : mediaAssets.isEmpty
                    ? const Center(
                        child: Text(
                          'No images found',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          handleScrollEvent(scrollInfo);
                          return false;
                        },
                        child: GridView.builder(
                          controller: widget.scrollController,
                          padding: const EdgeInsets.all(4),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                          itemCount: mediaAssets.length,
                          itemBuilder: (context, index) {
                            final asset = mediaAssets[index];
                            final imageData = imageCache[asset.id];

                            if (imageData == null) {
                              return Container(
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey),
                                  ),
                                ),
                              );
                            }

                            return _buildMediaItem(asset, imageData);
                          },
                        ),
                      ),
          ),
          // only shows for chat mode with selections
          _buildBottomSelectionBar(),
        ],
      ),
    );
  }
}

// Helper function to show the picker
void showWhatsAppImagePicker(
  BuildContext context, {
  Function(Uint8List imageData, AssetEntity asset)? onImageSelected,
  Function(List<SelectedImage> selectedImages)? onImagesSelected,
  PickerMode mode = PickerMode.chat,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => WhatsappImagePicker(
        onImageSelected: onImageSelected,
        onImagesSelected: onImagesSelected,
        scrollController: scrollController,
        mode: mode,
      ),
    ),
  );
}

class SelectedImage {
  final AssetEntity asset;
  final Uint8List imageData;
  final int selectionOrder;

  SelectedImage({
    required this.asset,
    required this.imageData,
    required this.selectionOrder,
  });
}
