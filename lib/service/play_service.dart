import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class PlayerService {
  PlayerService._();
  static final instance = PlayerService._();

  final AudioPlayer player = AudioPlayer();
  final String streamUrl = "https://stm1.centralcast.com.br:7026/stream";

  // Estado interno
  bool _userPaused = false;
  bool _reconnecting = false;
  int _retryAttempt = 0;
  Timer? _stallTimer;
  Duration _lastPos = Duration.zero;
  StreamSubscription<PlayerState>? _stateSub;

  // ===== Fonte com headers (Shoutcast/Icecast gostam disso) =====
  AudioSource _buildSource() {
    return AudioSource.uri(
      Uri.parse(streamUrl),
      tag: const MediaItem(
        id: 'radio_tres',
        album: 'Radio Três',
        title: 'Ao vivo',
        artUri: null,
      ),
    );
  }

  // ===== Inicialização =====
  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Eventos de interrupção (ligações, navegação com voz, etc)
    session.interruptionEventStream.listen((event) async {
      if (event.begin) {
        // Pausa durante interrupção se estava tocando
        if (player.playing) await player.pause();
      } else {
        if (!_userPaused) {
          await _ensureSource();
          await player.play();
        }
      }
    });

    // Tirou o fone -> pausar (evita tocar no alto-falante sem querer)
    session.becomingNoisyEventStream.listen((_) async {
      if (player.playing) await player.pause();
    });

    await _ensureSource();
    _watchPlayerState();
    _startStallDetector();
  }

  // ===== Público =====
  Future<void> toggle() async {
    if (player.playing) {
      _userPaused = true;
      await player.pause();
    } else {
      _userPaused = false;
      await _ensureSource();
      await player.play();
    }
  }

  Future<void> stop() async {
    _userPaused = true;
    await player.stop();
  }

  Future<void> dispose() async {
    await _stateSub?.cancel();
    _stallTimer?.cancel();
    await player.dispose();
  }

  // ===== Internos =====
  Future<void> _ensureSource() async {
    if (player.audioSource == null) {
      await player.setAudioSource(_buildSource(), preload: true);
    }
  }

  void _watchPlayerState() {
    _stateSub?.cancel();
    _stateSub = player.playerStateStream.listen((state) async {
      final ps = state.processingState;

      // Se deu erro, tentar reconectar (com backoff)
      if (state.playing && ps == ProcessingState.idle) {
        _scheduleReconnect(); return;
      }

      if (ps == ProcessingState.completed) {
        // Alguns servidores fecham após “faixa” -> recomeçar
        if (!_userPaused) _scheduleReconnect();
        return;
      }

      // Buffering muito longo (ex.: > 8s) -> reconectar
      if (ps == ProcessingState.buffering) {
        _stallCheckBuffering();
      } else {
        _clearBufferingTimer();
      }
    });
  }

  Timer? _bufferingTimer;
  void _stallCheckBuffering() {
    _bufferingTimer ??= Timer(const Duration(seconds: 8), () {
      if (player.processingState == ProcessingState.buffering && !_userPaused) {
        _scheduleReconnect();
      }
    });
  }
  void _clearBufferingTimer() {
    _bufferingTimer?.cancel();
    _bufferingTimer = null;
  }

  void _startStallDetector() {
    _stallTimer?.cancel();
    _lastPos = Duration.zero;

    _stallTimer = Timer.periodic(const Duration(seconds: 10), (t) async {
      if (!player.playing || _userPaused) return;
      final now = player.position;
      final advancedMs = now.inMilliseconds - _lastPos.inMilliseconds;
      _lastPos = now;

      // Não avançou ~0.5s em 10s? Provável travamento
      if (advancedMs < 500) {
        _scheduleReconnect();
      }
    });
  }

  void _scheduleReconnect() {
    if (_reconnecting || _userPaused) return;
    _reconnecting = true;

    // Exponential backoff: 1,2,4,8,16,32s (máx 32s)
    final delay = Duration(seconds: 1 << (_retryAttempt.clamp(0, 5)));
    Future<void>(() async {
      try {
        await player.stop();
        await player.setAudioSource(_buildSource(), preload: true);
        if (!_userPaused) await player.play();
        _retryAttempt = 0; // sucesso => zera
      } catch (_) {
        _retryAttempt++;
      } finally {
        _reconnecting = false;
      }
    });

    // Aguarda o delay antes da próxima tentativa, se necessário
    Future.delayed(delay);
  }
}
