import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/video/channel_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../video/video_player_screen.dart';

class ChannelListScreen extends StatefulWidget {
  const ChannelListScreen({super.key});

  @override
  State<ChannelListScreen> createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends State<ChannelListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (authViewModel.playlist == null) {
      await authViewModel.fetchPlaylist('b81855cb72', 'be8622a3cb0e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Channel List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChannels,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search channels',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: _buildChannelList(authViewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelList(AuthViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(child: Text('Error: ${viewModel.error}'));
    }

    if (viewModel.playlist == null || viewModel.playlist!.channels.isEmpty) {
      return const Center(child: Text('No channels available'));
    }

    final filteredChannels = viewModel.playlist!.channels.where((channel) {
      return channel.name.toLowerCase().contains(_searchQuery) ||
          channel.groupTitle.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredChannels.isEmpty) {
      return const Center(child: Text('No channels match your search'));
    }

    return ListView.builder(
      itemCount: filteredChannels.length,
      itemBuilder: (context, index) {
        final channel = filteredChannels[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            leading: channel.logo.isNotEmpty
                ? Image.network(
                    channel.logo,
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.tv),
                  )
                : const Icon(Icons.tv),
            title: Text(channel.name),
            subtitle: Text(channel.groupTitle),
            trailing: const Icon(Icons.play_arrow),
            onTap: () {
              debugPrint('---> Video Screen <---');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    videoUrl: channel.url,
                    channelName: channel.name,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
