// lib/game/audio_manager.dart
// Centralized audio and tactile feedback manager.
// Manages BGM and SFX volume toggles, tactile click sounds, and audio playback hooks.

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  AudioManager._();
  static final AudioManager instance = AudioManager._();

  double _bgmVolume = 0.7;
  double _sfxVolume = 0.8;
  bool _isBgmEnabled = true;
  bool _isSfxEnabled = true;
  String? _currentTrack;

  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  bool get isBgmEnabled => _isBgmEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  String? get currentTrack => _currentTrack;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _bgmVolume = prefs.getDouble('audio_bgm_volume') ?? 0.7;
      _sfxVolume = prefs.getDouble('audio_sfx_volume') ?? 0.8;
      _isBgmEnabled = prefs.getBool('audio_bgm_enabled') ?? true;
      _isSfxEnabled = prefs.getBool('audio_sfx_enabled') ?? true;
      _initialized = true;
    } catch (_) {
      _initialized = true;
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('audio_bgm_volume', _bgmVolume);
      await prefs.setDouble('audio_sfx_volume', _sfxVolume);
      await prefs.setBool('audio_bgm_enabled', _isBgmEnabled);
      await prefs.setBool('audio_sfx_enabled', _isSfxEnabled);
    } catch (_) {
      // Ignored in test environment
    }
  }

  void playClick() {
    if (!_isSfxEnabled || _sfxVolume <= 0.0) return;
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  void playImpact({bool heavy = false}) {
    if (!_isSfxEnabled || _sfxVolume <= 0.0) return;
    try {
      if (heavy) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    } catch (_) {}
  }

  void playSfx(String soundName) {
    if (!_isSfxEnabled || _sfxVolume <= 0.0) return;
    switch (soundName) {
      case 'hit':
      case 'strike':
        playImpact(heavy: false);
        break;
      case 'ko':
      case 'heavy_hit':
        playImpact(heavy: true);
        break;
      case 'block':
      case 'salag':
        playImpact(heavy: false);
        break;
      case 'coin':
      case 'pera':
      case 'tap':
      default:
        playClick();
        break;
    }
  }

  void playBgm(String trackName) {
    if (!_isBgmEnabled || _bgmVolume <= 0.0) {
      _currentTrack = trackName;
      return;
    }
    _currentTrack = trackName;
  }

  void stopBgm() {
    _currentTrack = null;
  }

  void setBgmVolume(double val) {
    _bgmVolume = val.clamp(0.0, 1.0);
    _saveSettings();
  }

  void setSfxVolume(double val) {
    _sfxVolume = val.clamp(0.0, 1.0);
    _saveSettings();
  }

  void toggleBgm() {
    _isBgmEnabled = !_isBgmEnabled;
    if (!_isBgmEnabled) {
      stopBgm();
    }
    _saveSettings();
  }

  void toggleSfx() {
    _isSfxEnabled = !_isSfxEnabled;
    _saveSettings();
  }
}
