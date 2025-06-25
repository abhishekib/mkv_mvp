import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodchannel/models/channel_model.dart';
import 'package:goodchannel/provider/channel_provider.dart';
import 'package:goodchannel/provider/player_provider.dart';
import 'package:provider/provider.dart';
import 'player_screen.dart';

class ChannelListScreen extends StatefulWidget {
  const ChannelListScreen({super.key});

  @override
  State<ChannelListScreen> createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends State<ChannelListScreen> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  bool _isSearching = false;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Hide system UI overlays for fullscreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });
    Future.microtask(() => context.read<ChannelProvider>().fetchChannels());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshChannels() async {
    await context.read<ChannelProvider>().fetchChannels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: _isSearching
            ? TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search channels or categories...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Center(
                child: SizedBox(
                  width: 200,
                  height: 80,
                  child: Image.asset(
                    'assets/text_icon.png',
                    width: 200,
                    height: 110,
                  ),
                ),
              ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _refreshChannels,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<ChannelProvider>(
        builder: (context, channelProvider, child) {
          if (channelProvider.isLoading && channelProvider.channels.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
              ),
            );
          }

          if (channelProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.deepPurpleAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    channelProvider.error,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshChannels,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final groupedChannels = channelProvider.getGroupedChannels(
            _searchQuery,
            _selectedCategory,
          );
          final totalChannels = groupedChannels.values
              .fold(0, (sum, channels) => sum + channels.length);

          return Column(
            children: [
              // Total channels count
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '$totalChannels channels in ${groupedChannels.length} categories',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (channelProvider.isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              // Filter Button for Channel
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Consumer<ChannelProvider>(
                  builder: (context, channelProvider, child) {
                    final categories = channelProvider.getAllCategories();
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(
                              category,
                              style: TextStyle(
                                color: _selectedCategory == category
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: 14,
                                fontWeight: _selectedCategory == category
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            selected: _selectedCategory == category,
                            selectedColor: Colors.deepPurple[700],
                            backgroundColor:
                                Colors.deepPurple[400]?.withOpacity(0.6),
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? category : 'All';
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // Slightly rounded corners
                              side: BorderSide(
                                color: _selectedCategory == category
                                    ? Colors.deepPurpleAccent
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            showCheckmark: false,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Category sections
              Expanded(
                child: groupedChannels.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty
                                  ? Icons.search_off
                                  : Icons.tv_off,
                              color: Colors.grey[600],
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No channels found for "$_searchQuery"'
                                  : 'No channels available',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshChannels,
                        color: Colors.deepPurpleAccent,
                        backgroundColor: Colors.white,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: groupedChannels.length,
                          itemBuilder: (context, index) {
                            final group = groupedChannels.keys.elementAt(index);
                            final channels = groupedChannels[group]!;

                            return CategorySection(
                              title: group,
                              channels: channels,
                              onChannelTap: (channel) =>
                                  _navigateToPlayer(context, channel),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<ChannelProvider>(
        builder: (context, channelProvider, child) {
          final groupedChannels = channelProvider.getGroupedChannels(
              _searchQuery, _selectedCategory);
          return groupedChannels.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  backgroundColor: Colors.deepPurpleAccent,
                  child:
                      const Icon(Icons.keyboard_arrow_up, color: Colors.white),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }

  void _navigateToPlayer(BuildContext context, Channel channel) async {
    final playerProvider = context.read<PlayerProvider>();
    await playerProvider.safeDispose();

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(channel: channel),
        ),
      );
    }
  }
}

class CategorySection extends StatelessWidget {
  final String title;
  final List<Channel> channels;
  final Function(Channel) onChannelTap;

  const CategorySection({
    super.key,
    required this.title,
    required this.channels,
    required this.onChannelTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    left: 30,
                    right: 12,
                    top: 6,
                    bottom: 6,
                  ),
                  decoration: BoxDecoration(
                    /* gradient: const LinearGradient(
                      colors: [
                        Colors.deepPurpleAccent,
                        Colors.deepPurpleAccent
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ), */
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${channels.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal Channel List
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 50),
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                return HorizontalChannelTile(
                  channel: channel,
                  onTap: () => onChannelTap(channel),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HorizontalChannelTile extends StatelessWidget {
  final Channel channel;
  final VoidCallback onTap;

  const HorizontalChannelTile({
    super.key,
    required this.channel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
              4), // Slightly rounded corners for the container
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Channel Image (now rectangular)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: channel.logo.isNotEmpty
                  ? Image.network(
                      channel.logo,
                      fit: BoxFit.fitWidth,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.deepPurpleAccent),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(
                              Icons.tv,
                              color: Colors.deepPurpleAccent,
                              size: 32,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(
                          Icons.tv,
                          color: Colors.deepPurpleAccent,
                          size: 32,
                        ),
                      ),
                    ),
            ),

            // Gradient Overlay at bottom for text
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Channel Name Text
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                channel.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Play Button in center
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.play_circle_filled,
                  color: Colors.white.withOpacity(0.8),
                  size: 48,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
