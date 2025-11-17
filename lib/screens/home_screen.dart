import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pulsator/pulsator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:just_audio/just_audio.dart';

import '../service/play_service.dart';

class HomeScreen extends StatefulWidget {
  final String title;
  const HomeScreen({super.key, required this.title});
  @override
  State<HomeScreen> createState() => HomeScreenState();
}
class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin{
  final _player = AudioPlayer();
  final _svc = PlayerService.instance;

  //bool isPlaying = false;
  String currentSong = "Conectando...";
  String currentCover = "";
  final AudioPlayer _playerNew = AudioPlayer();
  String? _nowPlaying;
  // Stream e API
  final String streamUrl = "https://player.centralcast.com.br/proxy/7026";
  final String apiUrl = "https://player.centralcast.com.br/proxy/7026/currentsong?sid=1";
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  List<String> titulos = [];

  int currentIndex = 0;
  PageController pageController = PageController();
  int currentIndexEmissora = 0;

  PageController pageControllerEmissora = PageController();

  List<Map<String, dynamic>> anuncios = [];
  List<Map<String, dynamic>> anunciosEmissora = [];

  Future<void> fetchNoticias() async {
    final url = Uri.parse("https://radiotropical.net/category/noticias/");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);

      // pega só o container do seu trecho
      final container = document.querySelector("#tdi_72");

      if (container != null) {
        // dentro dele, pega todos os h3.entry-title > a
        final elements = container.querySelectorAll("h3.entry-title a");

        // pega só os 3 primeiros títulos
        final ultimosTitulos =
        elements.take(2).map((e) => e.text.trim()).toList();

        setState(() {
          titulos = ultimosTitulos;
          print(titulos);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _svc.init();
    //fetchNoticias();
    carregarAnuncios();
    carregarAnunciosEmissora();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ensureNotifPermission(); // chama só depois do primeiro frame
    });
    _fetchNowPlaying();
    // Atualiza a cada 20s
    Future.delayed(Duration.zero, () async {
      while (mounted) {
        await Future.delayed(const Duration(seconds: 20));
        _fetchNowPlaying();
      }
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.blueAccent,
    ).animate(_controller);
  }

  Future<void> ensureNotifPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<void> _fetchNowPlaying() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          currentSong = response.body.toString();

        });
        // final data = jsonDecode(response.body);
        // final current = data["current"];
        //
        // setState(() {
        //   currentSong = "${current["artist"]} - ${current["title"]}";
        //   currentCover = current["cover"] ?? "";
        // });
      } else {
        setState(() {
          currentSong = "Erro ao carregar música";
        });
      }
    } catch (e) {
      setState(() {
        currentSong = "Falha na conexão";
      });
    }
  }

  // void _togglePlayPause() async {
  //   try {
  //     if (!_player.playing && _player.processingState == ProcessingState.idle) {
  //       // Carrega a URL apenas se ainda não foi carregada
  //       await _player.setUrl(streamUrl);
  //     }
  //
  //     if (_player.playing) {
  //       setState(() {
  //         isPlaying = false;
  //       });
  //       await _player.pause();
  //
  //     } else {
  //       setState(() {
  //         isPlaying = true;
  //       });
  //       await _player.play();
  //
  //     }
  //
  //
  //   } catch (e) {
  //     debugPrint("Erro ao reproduzir: $e");
  //   }
  // }

  Future<void> _launchUrl(String url) async {
    if (kIsWeb) {
      // Abre na mesma aba
    } else {
      // Mobile/Desktop
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Não foi possível abrir $url';
      }
    }
  }
  Future<void> carregarAnuncios() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('publicidade').get();

    setState(() {
      anuncios = snapshot.docs.map((doc) => doc.data()).toList();
      print(anuncios);
    });

    if (anuncios.isNotEmpty) {
      rodarCarrossel();
    }
  }

  Future<void> carregarAnunciosEmissora() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('publicidade_emissora').get();

    setState(() {
      anunciosEmissora = snapshot.docs.map((doc) => doc.data()).toList();
      print(anunciosEmissora);
    });

    if (anunciosEmissora.isNotEmpty) {
      rodarCarrosselEmissora();
    }
  }
  void rodarCarrossel() async {
    while (mounted && anuncios.isNotEmpty) {
      await Future.delayed(
        Duration(seconds: anuncios[currentIndex]['tempo_duracao'] ?? 5),
      );

      if (!mounted) return;

      setState(() {
        currentIndex = (currentIndex + 1) % anuncios.length;
        pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void rodarCarrosselEmissora() async {
    while (mounted && anunciosEmissora.isNotEmpty) {
      await Future.delayed(
        Duration(seconds: anunciosEmissora[currentIndexEmissora]['tempo_duracao'] ?? 5),
      );

      if (!mounted) return;

      setState(() {
        currentIndexEmissora = (currentIndexEmissora + 1) % anunciosEmissora.length;
        pageControllerEmissora.animateToPage(
          currentIndexEmissora,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  // void abrirLink(String? link) async {
  //   if (link != null && link.isNotEmpty) {
  //     final uri = Uri.parse(link);
  //     if (await canLaunchUrl(uri)) {
  //       await launchUrl(uri, mode: LaunchMode.externalApplication);
  //     }
  //   }
  // }
  Future<void> abrirLink(String? url) async {

    if (url == null || url.isEmpty  ) {
      return;
    } else {
      // Mobile/Desktop
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Não foi possível abrir $url';
      }
    }
  }


  @override
  void dispose() {
    // _controller.dispose();
    // _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = _svc.player;

    return  Center(
        child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/logo-radio-tres.png",  width: MediaQuery.sizeOf(context).width * 0.8),
    //   GestureDetector(
    //     onTap: () => _launchUrl("https://radiotropical.net/"),
    //     child: Row(
    //     children: [
    //       Expanded(
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             const Padding(
    //               padding: EdgeInsets.symmetric(horizontal: 10),
    //                 child: Text(
    //               "Últimas Notícias",
    //               style: TextStyle(
    //                 fontSize: 22,
    //                 fontWeight: FontWeight.bold,
    //                 color: Color(0xff052562),
    //               ),
    //             )),
    //             const SizedBox(height: 10),
    //             ...titulos.take(3).map((titulo) => Padding(
    // padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
    // child:Text(titulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16,color: Colors.white),))),
    //           ],
    //         ),
    //       ),
    //     ],
    //   )),
      SizedBox(height: 10,),
          Container(
            width: MediaQuery.sizeOf(context).width * 0.7,
            height: MediaQuery.sizeOf(context).height * 0.15,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: anunciosEmissora.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: PageView.builder(
                controller: pageControllerEmissora,
                itemCount: anunciosEmissora.length,
                itemBuilder: (context, index) {
                  final anuncio = anunciosEmissora[index];
                  return GestureDetector(
                    onTap: () => abrirLink(anuncio['link']),
                    child: Image.network(
                      anuncio['imagem'],
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(
            height: 130,
            child: StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snap) {
                final playing = snap.data?.playing ?? false;
                return IconButton(
                  icon: Icon(
                    playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    size: 70,
                    color: Colors.white,
                  ),
                  onPressed: _svc.toggle, // mesmo método do BottomPlayer
                );
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // WhatsApp
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                  size: 35,
                ),
                onPressed: (){
                  _launchUrl("https://api.whatsapp.com/send/?phone=553532393607&text&type=phone_number&app_absent=0");
                },
              ),
              // WhatsApp
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.facebook,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: (){
                  _launchUrl("https://www.facebook.com/share/17HMpzMS9e/");
                },
              ),
              // WhatsApp
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.instagram,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: (){
                  _launchUrl("https://www.instagram.com/radiotrestc?igsh=Nm03NDEzYWVqODZn");
                },
              ),

            ],
          ),
          SizedBox(height: 10,),

          Container(
            width: MediaQuery.sizeOf(context).width * 0.7,
            height: MediaQuery.sizeOf(context).height * 0.15,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: anuncios.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: PageView.builder(
                controller: pageController,
                itemCount: anuncios.length,
                itemBuilder: (context, index) {
                  final anuncio = anuncios[index];
                  return GestureDetector(
                    onTap: () => abrirLink(anuncio['link']),
                    child: Image.network(
                      anuncio['imagem'],
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
          )


        ],
      ),
    ));
  }


}