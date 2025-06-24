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

  Map<String, List<Channel>> _getGroupedChannels(List<Channel> channels) {
    var filteredChannels = channels;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredChannels = filteredChannels
          .where((channel) =>
              channel.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              channel.group.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Group channels by category
    Map<String, List<Channel>> groupedChannels = {};

    for (var channel in filteredChannels) {
      String group = channel.group.isEmpty ? 'Other' : channel.group;
      if (!groupedChannels.containsKey(group)) {
        groupedChannels[group] = [];
      }
      groupedChannels[group]!.add(channel);
    }

    // Filter by selected category
    if (_selectedCategory != 'All') {
      groupedChannels = {
        _selectedCategory: groupedChannels[_selectedCategory] ?? []
      };
    }

    // Sort groups alphabetically, but keep "FORMULA 1 + MOTO GP" first if it exists
    var sortedGroups = groupedChannels.keys.toList();
    sortedGroups.sort((a, b) {
      if (a.contains('FORMULA') || a.contains('F1')) return -1;
      if (b.contains('FORMULA') || b.contains('F1')) return 1;
      if (a == 'Other') return 1;
      if (b == 'Other') return -1;
      return a.compareTo(b);
    });

    Map<String, List<Channel>> sortedGroupedChannels = {};
    for (String group in sortedGroups) {
      sortedGroupedChannels[group] = groupedChannels[group]!;
    }

    return sortedGroupedChannels;
  }

  List<String> _getAllCategories(List<Channel> channels) {
    Set<String> categories = {'All'};
    for (var channel in channels) {
      String group = channel.group.isEmpty ? 'Other' : channel.group;
      categories.add(group);
    }

    var sortedCategories = categories.toList();
    sortedCategories.sort((a, b) {
      if (a == 'All') return -1;
      if (b == 'All') return 1;
      if (a.contains('FORMULA') || a.contains('F1')) return -1;
      if (b.contains('FORMULA') || b.contains('F1')) return 1;
      if (a == 'Other') return 1;
      if (b == 'Other') return -1;
      return a.compareTo(b);
    });

    return sortedCategories;
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

          final groupedChannels = _getGroupedChannels(channelProvider.channels);
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
                    final categories =
                        _getAllCategories(channelProvider.channels);
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
          final groupedChannels = _getGroupedChannels(channelProvider.channels);
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
    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Channel Logo/Thumbnail
                Container(
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    border: Border.all(
                        color: Colors.deepPurpleAccent.withOpacity(0.3)),
                  ),
                  child: Stack(
                    children: [
                      // Logo/Icon
                      Center(
                        child: channel.logo.isNotEmpty
                            ? ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: Image.network(
                                  channel.logo,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.deepPurpleAccent),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.tv,
                                      color: Colors.deepPurpleAccent,
                                      size: 32,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.tv,
                                color: Colors.deepPurpleAccent,
                                size: 32,
                              ),
                      ),

                      // // Live Badge
                      // Positioned(
                      //   top: 8,
                      //   right: 8,
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 6, vertical: 2),
                      //     decoration: BoxDecoration(
                      //       color: Colors.deepPurpleAccent,
                      //       borderRadius: BorderRadius.circular(4),
                      //     ),
                      //     child: const Text(
                      //       'LIVE',
                      //       style: TextStyle(
                      //         color: Colors.white,
                      //         fontSize: 8,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      // Play Button Overlay
                      Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Channel Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          channel.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // StreamBuilder(
                        //   stream: Stream.periodic(const Duration(minutes: 1)),
                        //   builder: (context, snapshot) {
                        //     final now = DateTime.now();
                        //     return Text(
                        //       '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                        //       style: TextStyle(
                        //         color: Colors.grey[500],
                        //         fontSize: 10,
                        //         fontFamily: 'monospace',
                        //       ),
                        //     );
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
