import 'package:audioplayers/audioplayers.dart';

playWinSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource("sounds/win.mp3"),
        mode: PlayerMode.mediaPlayer);
  }

  playCloseSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource("sounds/close.mp3"),
        mode: PlayerMode.mediaPlayer);
  }

  playClickSound() async {
    final player = AudioPlayer();
    await player.play(AssetSource("sounds/click.mp3"),
        mode: PlayerMode.mediaPlayer);
  }