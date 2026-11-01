import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared playback state for the prayer screen and its mute control.
class AdhanService {
  AdhanService._();

  static final AdhanService instance = AdhanService._();

  static const _mutedKey = 'adhan_muted';
  static const _reciterKey = 'adhan_reciter';
  static const reciters = <String, String>{
    'mansour': 'منصور الزهراني',
    'mishary': 'مشاري العفاسي',
  };
  static const _assets = <String, String>{
    'mansour': 'assets/azan_audio/mansour-al-zahrani.mp3',
    'mishary': 'assets/azan_audio/mishary_rashid_alafasy.mp3',
  };

  final AudioPlayer _player = AudioPlayer();
  Future<void>? _initializing;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  bool _muted = false;
  String _reciter = 'mansour';
  bool _playing = false;
  String? _lastPlayedPrayerKey;

  bool get isMuted => _muted;
  bool get isPlaying => _playing;
  String get reciter => _reciter;

  Future<void> initialize() => _initializing ??= _initialize();

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _muted = prefs.getBool(_mutedKey) ?? false;
    final savedReciter = prefs.getString(_reciterKey);
    if (savedReciter != null && _assets.containsKey(savedReciter)) {
      _reciter = savedReciter;
    }
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      _playing = state.playing;
    });
  }

  Future<void> toggleMuted() async {
    await initialize();
    _muted = !_muted;
    if (_muted) await _player.stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mutedKey, _muted);
  }

  Future<void> setReciter(String value) async {
    if (!_assets.containsKey(value)) return;
    _reciter = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reciterKey, value);
  }

  Future<void> playAtPrayer(PrayerKey key) async {
    await initialize();
    if (_muted || _lastPlayedPrayerKey == key.value) return;
    _lastPlayedPrayerKey = key.value;
    try {
      await _player.stop();
      await _player.setAsset(_assets[_reciter]!);
      if (_muted) return;
      await _player.play();
    } catch (error) {
      debugPrint('Unable to play Adhan: $error');
    }
  }

  Future<void> playPreview() async {
    await initialize();
    try {
      await _player.stop();
      await _player.setAsset(_assets[_reciter]!);
      await _player.play();
    } catch (error) {
      debugPrint('Unable to play Adhan preview: $error');
    }
  }

  Future<void> disposePlayer() async {
    await _playerStateSubscription?.cancel();
    await _player.dispose();
  }
}

class PrayerKey {
  const PrayerKey(this.value);
  final String value;
}
