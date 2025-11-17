import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:radio_tres/screens/about_screen.dart';
import 'package:radio_tres/screens/home_screen.dart';
import 'package:radio_tres/screens/offers_screen.dart';
import 'package:radio_tres/screens/schedule_screen.dart';
import 'package:radio_tres/screens/snake_screen.dart';
import 'package:radio_tres/service/radio_service.dart';
import 'package:radio_tres/utils/constants.dart';
import 'package:radio_tres/widget/programacao_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Mens"
      "agem recebida em background: ${message.messageId}");
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'br.app.radio_tres',
    androidNotificationChannelName: AppConstants.appName,
    androidNotificationOngoing: true, // mantém notificação enquanto tocar
    androidShowNotificationBadge: true,
  );

  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
  const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  void _initNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Pede permissão no iOS
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("Permissão de notificação: ${settings.authorizationStatus}");

    // Pega o token do dispositivo
    String? token = await messaging.getToken();
    print("TOKEN DO DISPOSITIVO: $token");

    // Foreground (quando o app está aberto)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Mensagem em primeiro plano: ${message.notification?.title}");
    });

    // Quando o usuário clica na notificação e abre o app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Usuário clicou na notificação: ${message.data}");
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white), // 👈 cor global do Drawer e back button
          )),
      home: const ResponsiveScaffold(),
    );
  }
}

/// Página de conteúdo reutilizável
class ContentPage extends StatelessWidget {
  final String title;
  final Color color;
  const ContentPage({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(fontSize: 28),
      ),
    );
  }
}

/// Scaffold responsivo que mostra Drawer (mobile) ou NavigationRail (desktop)
class ResponsiveScaffold extends StatefulWidget {
  final int initialIndex;
  const ResponsiveScaffold({super.key, this.initialIndex = 0});

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  late int _selectedIndex;
  bool _showAbout = false;

  

  final List<_NavItem> _items = [
    _NavItem(label: 'Início', icon: Icons.home, route: '/home'),
    _NavItem(label: 'Estúdio', icon: Icons.online_prediction, route: '/studio'),
    _NavItem(label: 'Jogos', icon: Icons.videogame_asset, route: '/game'),
    //_NavItem(label: 'Grade de Programação', icon: Icons.live_tv_outlined, route: '/schedule'),
    _NavItem(label: 'Promoções', icon: Icons.local_offer_outlined, route: '/offers'),
    _NavItem(label: 'Sobre', icon: Icons.info, route: '/about'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onSelectIndex(int index) {
    setState(() {
      // Se for o item "Sobre", ativa o bool
      if (_items[index].route == '/about') {
        _showAbout = true;
      } else {
        _selectedIndex = index;

        _showAbout = false;
        Navigator.of(context).pop();
      }
    });

     // fecha o Drawer no mobile
  }

  Widget _getPage(String route) {
    switch (route) {
      case '/home':
        return HomeScreen(title: 'Início');
      case '/studio':
        return ContentPage(title: 'Estúdio', color: Colors.blueGrey);
      case '/game':
        return SnakeGame();
      case '/schedule':
        return ScheduleScreen();
      case '/offers':
        return OffersScreen();
      case '/about':
        return AboutScreen(title: 'Sobre');
      default:
        return const Center(child: Text("Página não encontrada"));
    }
  }
  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 700;
    final page = _getPage(_items[_selectedIndex].route);


    return Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage("assets/fundo-tela.jpeg"),
    fit: BoxFit.cover,
    ),
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      drawer: isWide ? null : _buildDrawer(context), // Drawer só em telas pequenas
      body: Row(
        children: [
          if (isWide) _buildRail(), // NavigationRail em telas largas
          // Área principal: conteúdo da página
          Expanded(child: page),

        ],
      ),
      bottomNavigationBar: _selectedIndex == 0 ? null : const RadioBottomPlayer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    ));
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xff001f4d),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical:40),
        child: SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // UserAccountsDrawerHeader(
          //   margin: EdgeInsets.symmetric(horizontal: 10),
          //   accountName: null,
          //   accountEmail: null,
          //   // decoration: const BoxDecoration(
          //   //     color: Color(0xffffffff),
          //   //     image: DecorationImage(image: AssetImage("assets/logo_app.png",))),
          // ),
          ...List.generate(_items.length, (i) {
            final item = _items[i];
            return ListTile(
              leading: Icon(item.icon, color: Colors.white,),
              selectedColor: Colors.blue,
              title: Text(item.label, style: TextStyle(color: Colors.white),),
              selected: i == _selectedIndex,
              onTap: () => _onSelectIndex(i),
            );
          }),
          //const Spacer(),
          const Divider(),
          _showAbout ? _aboutItem(context) : _programacao(),

          // ListTile(
          //   leading: const Icon(Icons.exit_to_app),
          //   title: const Text('Sair'),
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('Logout (exemplo)')),
          //     );
          //   },
          // ),
        ],
      )),
    ));
  }

  NavigationRail _buildRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => _onSelectIndex(i),
      labelType: NavigationRailLabelType.all,
      leading: Column(
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: CircleAvatar(child: Text('G')),
          ),
          SizedBox(height: 6),
        ],
      ),
      destinations: _items
          .map((e) => NavigationRailDestination(
        icon: Icon(e.icon),
        selectedIcon: Icon(e.icon),
        label: Text(e.label),
      ))
          .toList(),
    );
  }


  Widget _aboutItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;

          // Breakpoints simples
          final bool isMobile = w < 480;
          final bool isTablet = w >= 480 && w < 900;

          // Tamanhos responsivos
          final double titleSize = isMobile ? 16 : (isTablet ? 18 : 20);
          final double bodySize  = isMobile ? 13.5 : (isTablet ? 14.5 : 16);
          final double iconSize  = isMobile ? 18 : (isTablet ? 20 : 22);
          final double vGap      = isMobile ? 8 : 10;
          final double hGap      = isMobile ? 6 : 8;

          // (Opcional) limitar largura máxima do bloco para leitura confortável em desktop
          final double maxContentWidth = 720;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sobre:",
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: vGap),
                  Text(
                    "Uma emissora de rádio de música sertaneja, da cidade Três Corações.",
                    style: TextStyle(color: Colors.white, fontSize: bodySize),
                    softWrap: true,
                  ),
                  SizedBox(height: vGap),

                  // Endereço
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_rounded, color: Colors.white, size: iconSize),
                      SizedBox(width: hGap),
                      Expanded(
                        child: Text(
                          "Rádio Três -  A primeira no coração.\nRua Casimiro Avelar filho, 143 - Centro\nTrês Corações - Minas Gerais",
                          style: TextStyle(color: Colors.white, fontSize: bodySize),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: vGap),

                  // Telefone
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.phone, color: Colors.white, size: iconSize),
                      SizedBox(width: hGap),
                      Expanded(
                        child: Text(
                          "Telefone: 35 3239-3600",
                          style: TextStyle(color: Colors.white, fontSize: bodySize),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: vGap),

                  // Email
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.email, color: Colors.white, size: iconSize),
                      SizedBox(width: hGap),
                      Expanded(
                        child: Text(
                          "Email: comercial@radiotropical.net",
                          style: TextStyle(color: Colors.white, fontSize: bodySize),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _programacao(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Padding(padding: EdgeInsets.symmetric(horizontal: 10),
          child:Text("Programação", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),)),
      SizedBox(height: 15,),
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("programação")
              .doc("tres_coracoes")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("Nenhuma programação encontrada"));
            }

            // Recupera o array "tabela"
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final List<dynamic> tabela = data["tabela"] ?? [];

            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: tabela.length,
              itemBuilder: (context, index) {
                final item = tabela[index] as Map<String, dynamic>;

                return ProgramacaoItem(
                  titulo: item["titulo"] ?? "",
                  horario: item["horario"] ?? "",
                  dias: item["dias"] ?? "",
                  apresentador: item["apresentador"] ?? "",
                  imagem: item["imagem"] ?? "",
                );
              },
            );
          },
        )
    ],);
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  _NavItem({required this.label, required this.icon, required this.route});
}
