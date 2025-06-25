import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/channel_model.dart';

class ChannelProvider with ChangeNotifier {
  List<Channel> _channels = [];
  bool _isLoading = false;
  String _error = '';
  String? _lastUpdated;

  List<Channel> get channels => _channels;
  bool get isLoading => _isLoading;
  String get error => _error;
  String? get lastUpdated => _lastUpdated;

  Future<void> fetchChannels() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      const url =
          'http://goodchannel.lol/get.php?username=b81855cb72&password=be8622a3cb0e&type=m3u_plus&output=ts';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        _channels = _parseM3U8(response.body);
        _error = '';
        _lastUpdated = DateTime.now().toString();
      } else {
        _error = 'Failed to load channels: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching channels: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Channel> _parseM3U8(String content) {
    final lines = content.split('\n');
    final channels = <Channel>[];

    for (int i = 0; i < lines.length - 1; i++) {
      final line = lines[i].trim();
      if (line.startsWith('#EXTINF:')) {
        final nextLine = lines[i + 1].trim();
        if (nextLine.isNotEmpty && !nextLine.startsWith('#')) {
          channels.add(Channel.fromM3U8Line(line, nextLine));
        }
      }
    }

    return channels;
  }

  Map<String, List<Channel>> getGroupedChannels(
      String searchQuery, String selectedCategory) {
    var filteredChannels = _channels;

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filteredChannels = filteredChannels
          .where((channel) =>
              channel.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              channel.group.toLowerCase().contains(searchQuery.toLowerCase()))
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
    if (selectedCategory != 'All') {
      groupedChannels = {
        selectedCategory: groupedChannels[selectedCategory] ?? []
      };
    }

    // Sort groups
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

  List<String> getAllCategories() {
    Set<String> categories = {'All'};
    for (var channel in _channels) {
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
}
