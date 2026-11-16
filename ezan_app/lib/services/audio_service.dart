import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  static Future<void> playEzan(String ezanType) async {
    if (_isPlaying) {
      await stop();
      return;
    }

    try {
      _isPlaying = true;
      final assetPath = 'audio/ezan_$ezanType.mp3';
      await _player.play(AssetSource(assetPath));
      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      _isPlaying = false;
    }
  }

  static Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  static bool get isPlaying => _isPlaying;

  static Stream<Duration> get positionStream =>
      _player.onPositionChanged;

  static void dispose() {
    _player.dispose();
  }
}
