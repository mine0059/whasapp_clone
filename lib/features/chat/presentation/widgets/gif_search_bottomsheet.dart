import 'package:flutter/material.dart';

class GifSearchBottomsheet extends StatefulWidget {
  const GifSearchBottomsheet({super.key});

  @override
  State<GifSearchBottomsheet> createState() => _GifSearchBottomsheetState();
}

class _GifSearchBottomsheetState extends State<GifSearchBottomsheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() {}));

    _searchController.addListener(() {
      setState(() {
        _hasText = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getHintText() {
    switch (_tabController.index) {
      case 0:
        return "Search GIFs";
      case 1:
        return "Search Avatar stickers";
      case 2:
        return "Find new Stickers";
      default:
        return "Search";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
            child: TabBarView(controller: _tabController, children: [
          _buildGifGrid(),
          _buildAvatarGrid(),
          _buildStickerGrid(),
        ]))
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header content with layered search field
          Container(
            margin: const EdgeInsets.only(bottom: 12, top: 5),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2A3942),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.grey),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: _getHintText(),
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_hasText)
                  IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: const Icon(Icons.close, color: Colors.grey),
                  )
              ],
            ),
          ),

          // Segmented buttons
          Container(
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.grey.withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                _buildSegmentButton(0, Icons.gif_box_outlined),
                _divider(),
                _buildSegmentButton(1, Icons.face_outlined),
                _divider(),
                _buildSegmentButton(2, Icons.sticky_note_2_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.grey.withOpacity(0.4),
    );
  }

  Widget _buildSegmentButton(int index, IconData icon) {
    // final isSelected = selectedType == value;
    final isSelected = _tabController.index == index;
    return Expanded(
      child: InkWell(
        onTap: () => _tabController.animateTo(index),
        child: Container(
          height: 32,
          margin: const EdgeInsets.all(2),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildGifGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: 20, // Placeholder count
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A3942),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.gif_box,
                    size: 40,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'GIF',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarGrid() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.face_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Avatar Stickers',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 16,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Handle sticker selection
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A3942),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.sticky_note_2_outlined,
                size: 32,
                color: Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }
}
