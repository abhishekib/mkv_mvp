import 'package:flutter/material.dart';
import 'package:goodchannel/models/channel_model.dart';
import 'package:goodchannel/provider/channel_provider.dart';
import 'package:goodchannel/provider/player_provider.dart';
import 'package:provider/provider.dart';
import 'player_screen.dart';

class ChannelListScreen extends StatefulWidget {
  const ChannelListScreen({Key? key}) : super(key: key);

  @override
  State<ChannelListScreen> createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends State<ChannelListScreen> {
  @override
  void initState() {
    super.initState();
    // Load channels after the widget is initialized
    Future.microtask(() => context.read<ChannelProvider>().fetchChannels());
  }

  Future<void> _refreshChannels() async {
    await context.read<ChannelProvider>().fetchChannels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Channels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshChannels,
          ),
        ],
      ),
      body: Consumer<ChannelProvider>(
        builder: (context, channelProvider, child) {
          if (channelProvider.isLoading && channelProvider.channels.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (channelProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    channelProvider.error,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshChannels,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshChannels,
            child: ListView.builder(
              itemCount: channelProvider.channels.length,
              itemBuilder: (context, index) {
                final channel = channelProvider.channels[index];
                return ChannelTile(
                  channel: channel,
                  onTap: () => _navigateToPlayer(context, channel),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToPlayer(BuildContext context, Channel channel) async {
    // First pause any currently playing video
    final playerProvider = context.read<PlayerProvider>();
    await playerProvider.safeDispose();
    // Then navigate to the new player screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(channel: channel),
      ),
    );
  }
}

class ChannelTile extends StatelessWidget {
  final Channel channel;
  final VoidCallback onTap;

  const ChannelTile({
    Key? key,
    required this.channel,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.deepPurple[100],
                backgroundImage:
                    channel.logo.isNotEmpty ? NetworkImage(channel.logo) : null,
                child: channel.logo.isEmpty
                    ? const Icon(Icons.tv, color: Colors.deepPurple)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (channel.group.isNotEmpty)
                      Text(
                        channel.group,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_fill, color: Colors.deepPurple),
            ],
          ),
        ),
      ),
    );
  }
}
