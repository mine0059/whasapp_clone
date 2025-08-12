import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/chat/presentation/widgets/gif_search_bottomsheet.dart';

class EmojiBottomsheet extends StatefulWidget {
  const EmojiBottomsheet({
    super.key,
    required this.onEmojiSelected,
    required this.onBackspace,
    required this.onGifSelected,
    required this.onClose,
  });

  final Function(String) onEmojiSelected;
  final VoidCallback onBackspace;
  final VoidCallback onGifSelected;
  final VoidCallback onClose;

  @override
  State<EmojiBottomsheet> createState() => _EmojiBottomsheetState();
}

class _EmojiBottomsheetState extends State<EmojiBottomsheet>
    with TickerProviderStateMixin {
  String selectedType = 'emoji';
  late TabController _tabController;

  // Dragging properties
  double _currentHeight = 350.0;
  final double _minHeight = 350.0;
  final double _maxHeight = 450.0;
  final double _closeThreshold = 280.0; // Height below which we close
  bool _isDragging = false;

  // Animation controller for smooth teansitions
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  // controller for search animations
  late AnimationController _searchAnimationController;
  late Animation<double> _searchOpacityAnimation;
  late Animation<double> _searchPositionAnimation;

  // Emoji categories with their respective emojis
  final Map<String, List<String>> emojiCategories = {
    'Recent': ['😀', '😂', '❤️', '👍', '😊', '🤔', '😎', '🙄'],
    'Smileys': [
      '😀',
      '😃',
      '😄',
      '😁',
      '😆',
      '😅',
      '🤣',
      '😂',
      '🙂',
      '🙃',
      '😉',
      '😊',
      '😇',
      '🥰',
      '😍',
      '🤩',
      '😘',
      '😗',
      '☺️',
      '😚',
      '😙',
      '🥲',
      '😋',
      '😛',
      '😜',
      '🤪',
      '😝',
      '🤑',
      '🤗',
      '🤭',
      '🤫',
      '🤔',
      '🤐',
      '🤨',
      '😐',
      '😑',
      '😶',
      '😏',
      '😒',
      '🙄',
      '😬',
      '🤥',
      '😔',
      '😪',
      '🤤',
      '😴',
      '😷',
      '🤒',
    ],
    'Animals': [
      '🐶',
      '🐱',
      '🐭',
      '🐹',
      '🐰',
      '🦊',
      '🐻',
      '🐼',
      '🐻‍❄️',
      '🐨',
      '🐯',
      '🦁',
      '🐮',
      '🐷',
      '🐽',
      '🐸',
      '🐵',
      '🙈',
      '🙉',
      '🙊',
      '🐒',
      '🐔',
      '🐧',
      '🐦',
      '🐤',
      '🐣',
      '🐥',
      '🦆',
      '🦅',
      '🦉',
      '🦇',
      '🐺',
      '🐗',
      '🐴',
      '🦄',
      '🐝',
    ],
    'Food': [
      '🍎',
      '🍊',
      '🍋',
      '🍌',
      '🍉',
      '🍇',
      '🍓',
      '🫐',
      '🍈',
      '🍒',
      '🍑',
      '🥭',
      '🍍',
      '🥥',
      '🥝',
      '🍅',
      '🍆',
      '🥑',
      '🥦',
      '🥬',
      '🥒',
      '🌶️',
      '🫑',
      '🌽',
      '🥕',
      '🫒',
      '🧄',
      '🧅',
      '🥔',
      '🍠',
      '🥐',
      '🥖',
      '🍞',
      '🥨',
      '🥯',
      '🧀',
    ],
    'Activities': [
      '⚽',
      '🏀',
      '🏈',
      '⚾',
      '🥎',
      '🎾',
      '🏐',
      '🏉',
      '🥏',
      '🎱',
      '🪀',
      '🏓',
      '🏸',
      '🏒',
      '🏑',
      '🥍',
      '🏏',
      '🪃',
      '🥅',
      '⛳',
      '🪁',
      '🏹',
      '🎣',
      '🤿',
      '🥊',
      '🥋',
      '🎽',
      '🛹',
      '🛷',
      '⛸️',
      '🥌',
      '🎿',
      '⛷️',
      '🏂',
      '🪂',
      '🏋️',
    ],
    'Objects': [
      '⌚',
      '📱',
      '📲',
      '💻',
      '⌨️',
      '🖥️',
      '🖨️',
      '🖱️',
      '🖲️',
      '🕹️',
      '🗜️',
      '💽',
      '💾',
      '💿',
      '📀',
      '📼',
      '📷',
      '📸',
      '📹',
      '🎥',
      '📽️',
      '🎞️',
      '📞',
      '☎️',
      '📟',
      '📠',
      '📺',
      '📻',
      '🎙️',
      '🎚️',
      '🎛️',
      '🧭',
      '⏱️',
      '⏲️',
      '⏰',
      '🕰️',
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: emojiCategories.length, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightAnimation = Tween<double>(begin: _currentHeight, end: _currentHeight)
        .animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Initialize search animation controller
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300), // Match the main duration
      vsync: this,
    );

    // Initialize search animations
    _updateSearchAnimations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  void _showgifSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const GifSearchBottomsheet(),
    );
  }

  void _updateSearchAnimations() {
    final shouldShow = _shouldShowSearchBar;

    _searchOpacityAnimation = Tween<double>(
      begin: shouldShow ? 0.0 : 1.0,
      end: shouldShow ? 1.0 : 0.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeOut,
    ));

    _searchPositionAnimation = Tween<double>(
      begin: shouldShow ? 0.0 : 44.0,
      end: shouldShow ? 44.0 : 0.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeOut,
    ));
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      // Use details.delta.dy instead of details.primaryDelta
      final deltaY = details.delta.dy;

      // Negative because dragging up should increase height
      _currentHeight -= deltaY;
      // Clamp the height between min and max + some extra for overscroll
      _currentHeight =
          _currentHeight.clamp(_closeThreshold - 50, _maxHeight + 50);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;

    // Determine final height based on current position and velocity
    double finalHeight;

    if (_currentHeight < _closeThreshold) {
      // Close the picker
      widget.onClose();
      return;
    } else if (_currentHeight < (_minHeight + _maxHeight) / 2) {
      // snap to minimum height
      finalHeight = _minHeight;
    } else {
      // snap to maximum height
      finalHeight = _maxHeight;
    }

    _animateToHeight(finalHeight);
  }

  void _animateToHeight(double targetHeight) {
    // Start search animation based on target height
    final willShowSearch = targetHeight > _minHeight + 30;
    final currentlyShowingSearch = _shouldShowSearchBar;

    if (willShowSearch != currentlyShowingSearch) {
      _updateSearchAnimations();
      if (willShowSearch) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
      }
    }

    _heightAnimation = Tween<double>(
      begin: _currentHeight,
      end: targetHeight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.reset();
    _animationController.forward().then((_) {
      setState(() {
        _currentHeight = targetHeight;
      });
    });

    // update current height during animation
    _heightAnimation.addListener(() {
      setState(() {
        _currentHeight = _heightAnimation.value;
      });
    });
  }

  bool get _shouldShowSearchBar {
    // Show search bar when height is closer to max height
    return _currentHeight >
        _minHeight + 30; // show when dragged up by at lease 30px
  }

  bool get _hasSearchField {
    // Search field exists for all modes except emoji
    return selectedType != 'emoji';
  }

  Widget _buildHeader() {
    return GestureDetector(
      onPanUpdate: _handleDragUpdate,
      onPanEnd: _handleDragEnd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF1F2C34),
          border: Border(
            bottom: BorderSide(
              color: Color(0xFF2A3942),
              width: 0.5,
            ),
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

            // Header content with layered search field
            ClipRect(
              child: SizedBox(
                height: _hasSearchField && _shouldShowSearchBar
                    ? 88
                    : 44, // Expand when search shows
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Back layer - Search field (slides from behind)
                    if (_hasSearchField)
                      AnimatedBuilder(
                          animation: _searchAnimationController,
                          builder: (context, child) {
                            return Positioned(
                              left: 0,
                              right: 0,
                              top: _searchPositionAnimation.value,
                              // top: _shouldShowSearchBar
                              //     ? 44
                              //     : 0, // Slide down from behind row
                              child: Opacity(
                                opacity: _searchOpacityAnimation.value,
                                child: GestureDetector(
                                  onTap: () {
                                    _showgifSearch(context);
                                  },
                                  child: Container(
                                    height: 44,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2A3942),
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Row(
                                      children: [
                                        const Hero(
                                          tag: 'search_icon',
                                          child: Icon(
                                            Icons.search,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Search ${selectedType.toUpperCase()}s',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    // Feont layer - Icon row (always visible)
                    Container(
                      height: 44,
                      color: const Color(0xFF1F2C34),
                      child: Row(
                        children: [
                          // Search button with smooth opacity transition
                          SizedBox(
                            width: 40,
                            child: AnimatedBuilder(
                                animation: _searchAnimationController,
                                builder: (context, child) {
                                  // invert the opacity for the search icon
                                  final iconOpacity = (!_hasSearchField ||
                                          !_shouldShowSearchBar)
                                      ? 1.0
                                      : 1.0 - _searchOpacityAnimation.value;

                                  return Opacity(
                                    opacity: iconOpacity,
                                    child: Hero(
                                      tag: 'search_icon',
                                      child: GestureDetector(
                                        onTap: () {
                                          if (_currentHeight < _maxHeight) {
                                            _animateToHeight(_maxHeight);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          child: const Icon(
                                            Icons.search,
                                            color: Colors.grey,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          const SizedBox(width: 8),

                          // Segmented buttons
                          Expanded(
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A3942),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  _buildSegmentButton(
                                      'emoji', Icons.emoji_emotions_outlined),
                                  _buildSegmentButton(
                                      'gif', Icons.gif_box_outlined),
                                  _buildSegmentButton(
                                      'avatar', Icons.face_outlined),
                                  _buildSegmentButton(
                                      'sticker', Icons.sticky_note_2_outlined),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),
                          // Backspace button
                          GestureDetector(
                            onTap: widget.onBackspace,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.backspace_outlined,
                                color: Colors.grey,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton(String value, IconData icon) {
    final isSelected = selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedType = value;
          });
        },
        child: Container(
          height: 32,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00A884) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiGrid() {
    return Column(
      children: [
        // Tab bar for emoji categories
        Container(
          height: 50,
          color: const Color(0xFF1F2C34),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: const Color(0xFF00A884),
            indicatorWeight: 3,
            labelColor: const Color(0xFF00A884),
            unselectedLabelColor: Colors.grey,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            dividerColor: Colors.transparent,
            tabs: emojiCategories.keys.map((category) {
              return Tab(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(category),
                ),
              );
            }).toList(),
          ),
        ),

        // Emoji grid
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: emojiCategories.values.map(
              (emojis) {
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: emojis.length,
                  itemBuilder: (context, index) {
                    final emoji = emojis[index];
                    return GestureDetector(
                      onTap: () => widget.onEmojiSelected(emoji),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ).toList(),
          ),
        )
      ],
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
          onTap: () => widget.onGifSelected(),
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

  Widget _buildContent() {
    switch (selectedType) {
      case 'emoji':
        return _buildEmojiGrid();
      case 'gif':
        return _buildGifGrid();
      case 'avatar':
        return _buildAvatarGrid();
      case 'sticker':
        return _buildStickerGrid();
      default:
        return _buildEmojiGrid();
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayHeight = _isDragging ? _currentHeight : _heightAnimation.value;

    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return Container(
          height: displayHeight,
          decoration: const BoxDecoration(
            color: Color(0xFF111B21),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }
}

// Helper function to show the emoji picker
// void showEmojiPicker(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: false,
//     backgroundColor: Colors.transparent,
//     builder: (context) {
//       return const EmojiBottomsheet();
//     },
//   );
// }
