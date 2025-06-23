import 'package:flutter/material.dart';
import 'package:goodchannel/models/channel_model.dart';
import 'package:goodchannel/provider/channel_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChannelProvider>().fetchChannels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Channels'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Consumer<ChannelProvider>(
        builder: (context, channelProvider, child) {
          if (channelProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading channels...'),
                ],
              ),
            );
          }

          if (channelProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${channelProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ChannelProvider().fetchChannels(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (channelProvider.channels.isEmpty) {
            return const Center(
              child: Text('No channels available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => channelProvider.fetchChannels(),
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

  void _navigateToPlayer(BuildContext context, Channel channel) {
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
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple[100],
          backgroundImage:
              channel.logo.isNotEmpty ? NetworkImage(channel.logo) : null,
          child: channel.logo.isEmpty
              ? Icon(Icons.tv, color: Colors.deepPurple)
              : null,
        ),
        title: Text(
          channel.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          channel.group.isNotEmpty ? channel.group : 'Live TV',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.play_circle_fill, color: Colors.deepPurple),
        onTap: onTap,
      ),
    );
  }
}
