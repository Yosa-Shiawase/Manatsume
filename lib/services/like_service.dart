import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LikeService extends ChangeNotifier {
  LikeService() {
    _ready = _load();
  }

  late final Future<void> _ready;
  SharedPreferences? _prefs;
  final Set<String> _liked = {};

  Set<String> get liked => Set.unmodifiable(_liked);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString('liked_ids');
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _liked.addAll(decoded.map((e) => e.toString()));
      } catch (_) {}
    }
    notifyListeners();
  }

  bool isLiked(String id) => _liked.contains(id);

  Future<void> toggle(String id) async {
    await _ready; // make sure storage is loaded before writing
    if (_liked.contains(id)) {
      _liked.remove(id);
    } else {
      _liked.add(id);
    }
    await _prefs?.setString('liked_ids', jsonEncode(_liked.toList()));
    notifyListeners();
  }

  Future<void> clear() async {
    await _ready;
    _liked.clear();
    await _prefs?.setString('liked_ids', '[]');
    notifyListeners();
  }
}
