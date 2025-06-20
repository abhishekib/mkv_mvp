import 'package:flutter/material.dart';
import 'package:goodchannel/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class ChannelListScreen extends StatelessWidget {
  const ChannelListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Channels')),
      body: _buildBody(authViewModel),
    );
  }

  Widget _buildBody(AuthViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(child: Text('Error: ${viewModel.error}'));
    }

    if (viewModel.playlist == null) {
      return Center(
          child: ElevatedButton(
        onPressed: () {
          // Replace with actual credentials or get them from user input
          viewModel.fetchPlaylist('b81855cb72', 'be8622a3cb0e');
        },
        child: const Text('Load Channels'),
      ));
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
          onTap: () {
            // Navigate to player screen with channel.url
          },
        );
      },
    );
  }
}
