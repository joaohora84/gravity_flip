import 'package:flame_audio/flame_audio.dart';

enum Sfx { flip, hit, shieldBlock, point, powerUp, milestone, buttonTap, newBest }

class AudioSystem {
  static const _sfxFiles = {
    Sfx.flip: 'sfx_flip.wav',
    Sfx.hit: 'sfx_hit.wav',
    Sfx.shieldBlock: 'sfx_shield.wav',
    Sfx.point: 'sfx_point.wav',
    Sfx.powerUp: 'sfx_powerup.wav',
    Sfx.milestone: 'sfx_milestone.wav',
    Sfx.buttonTap: 'sfx_button.wav',
    Sfx.newBest: 'sfx_newbest.wav',
  };

  static const _menuTrack = 'bgm_menu.wav';
  static const _gameplayTrack = 'bgm_gameplay.wav';

  static Future<void> preload() async {
    await FlameAudio.audioCache.loadAll([
      ..._sfxFiles.values,
      _menuTrack,
      _gameplayTrack,
    ]);
  }

  static void playSfx(Sfx sfx) {
    FlameAudio.play(_sfxFiles[sfx]!);
  }

  static void playMenuMusic() => FlameAudio.bgm.play(_menuTrack, volume: 0.5);

  static void playGameplayMusic() =>
      FlameAudio.bgm.play(_gameplayTrack, volume: 0.5);

  static void stopMusic() => FlameAudio.bgm.stop();
}
