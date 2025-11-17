import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:radio_tres/service/play_service.dart';
import '../utils/constants.dart';

class RadioBottomPlayer extends StatefulWidget {
  const RadioBottomPlayer({super.key});

  @override
  State<RadioBottomPlayer> createState() => _RadioBottomPlayerState();
}

class _RadioBottomPlayerState extends State<RadioBottomPlayer> {
  final _svc = PlayerService.instance;

  @override
  void initState() {
    super.initState();
    _svc.init(); // garante que a URL foi carregada ao menos uma vez
  }

  @override
  Widget build(BuildContext context) {
    final player = _svc.player;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: double.infinity,
        color: AppConstants.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // ... sua capa como já estava ...
            Expanded(
              child: StreamBuilder<PlayerState>(
                stream: player.playerStateStream,
                builder: (context, snap) {
                  final state = snap.data;
                  final processing = state?.processingState;
                  final playing = state?.playing ?? false;

                  // Aqui você mostra o título que você já busca via HTTP do jeito que preferir.
                  return Row(children: [
                    Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white
                      ),
                      child: Image.asset("assets/icon_app.png"),
                    ),
                    Text(
                      // use seu currentSong (pode mover essa lógica p/ outro serviço se quiser)
                      "A PRIMEIRA NO CORAÇÃO",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],);
                },
              ),
            ),
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snap) {
                final playing = snap.data?.playing ?? false;
                return IconButton(
                  icon: Icon(
                    playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: Colors.white, size: 40,
                  ),
                  onPressed: _svc.toggle,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
