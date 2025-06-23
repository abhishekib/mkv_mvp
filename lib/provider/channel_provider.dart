import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/channel_model.dart';

class ChannelProvider with ChangeNotifier {
  List<Channel> _channels = [];
  bool _isLoading = false;
  String _error = '';

  List<Channel> get channels => _channels;
  bool get isLoading => _isLoading;
  String get error => _error;

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
      } else {
        _error = 'Failed to load channels: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching channels: $e';
    }

    _isLoading = false;
    notifyListeners();
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
}
