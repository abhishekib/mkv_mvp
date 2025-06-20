import 'package:flutter/material.dart';
import 'package:goodchannel/viewmodels/video_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import 'video_player_screen.dart'; // Make sure this import is correct

class ChannelListScreen extends StatelessWidget {
  const ChannelListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Channels')),
      body: _buildBody(context, authViewModel),
    );
  }

  Widget _buildBody(BuildContext context, AuthViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(child: Text('Error: ${viewModel.error}'));
    }

    if (viewModel.playlist == null || viewModel.playlist!.channels.isEmpty) {
      return Center(
        child: ElevatedButton(
          onPressed: () =>
              viewModel.fetchPlaylist('b81855cb72', 'be8622a3cb0e'),
          child: const Text('Load Channels'),
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.playlist!.channels.length,
      itemBuilder: (context, index) {
        final channel = viewModel.playlist!.channels[index];
        return ListTile(
          leading: channel.logo.isNotEmpty
              ? Image.network(channel.logo, width: 40, height: 40)
              : const Icon(Icons.tv),
          title: Text(channel.name),
          subtitle: Text(channel.groupTitle),
          onTap: () async {
            try {
              final vm = context.read<VideoPlayerViewModel>();
              vm.initializePlayer(channel.url).then((_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(
                      videoUrl: channel.url,
                      channelName: channel.name,
                    ),
                  ),
                );
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}')),
              );
            }
          },
        );
      },
    );
  }
}
