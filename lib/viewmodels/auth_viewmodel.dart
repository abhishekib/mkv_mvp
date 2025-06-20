import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/video/playlist_model.dart';

class AuthViewModel with ChangeNotifier {
  final AuthService _authService;
  bool _isLoading = false;
  String? _error;
  Playlist? _playlist;
  String? _lastUpdated;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Playlist? get playlist => _playlist;
  String? get lastUpdated => _lastUpdated;

  AuthViewModel({required AuthService authService})
      : _authService = authService;

  Future<void> fetchPlaylist(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final m3uContent = await _authService.getPlaylist(
        username: username,
        password: password,
      );
      _playlist = Playlist.parseM3u(m3uContent);
      _lastUpdated = DateTime.now().toString();
    } catch (e) {
      _error = e.toString();
      _playlist = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Channel> getChannelsByGroup(String groupTitle) {
    if (_playlist == null) return [];
    return _playlist!.channels
        .where((channel) => channel.groupTitle == groupTitle)
        .toList();
  }

  List<String> getGroupTitles() {
    if (_playlist == null) return [];
    return _playlist!.channels
        .map((channel) => channel.groupTitle)
        .toSet()
        .toList();
  }
}
