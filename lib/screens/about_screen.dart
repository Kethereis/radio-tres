import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AboutScreen extends StatefulWidget {
  final String title;
  const AboutScreen({super.key, required this.title});
  @override
  State<AboutScreen> createState() => AboutScreenState();
}
class AboutScreenState extends State<AboutScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  bool showWebView = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
              showWebView = false; // esconde o WebView no início
            });          },
          onPageFinished: (String url) async {
            // Remove header e footer com JS
            await controller.runJavaScript("""
  (function removeHeaderFooter() {
    const interval = setInterval(() => {
      const header = document.querySelector('.td-header-template-wrap');
      const footer = document.querySelector('.td-footer-template-wrap');
      const breadcrumb = document.querySelector('.td-crumb-container');
      const barraPlayer = document.querySelector('#tdi_96');

      
      if (header) header.remove();
      if (footer) footer.remove();
      if (breadcrumb) breadcrumb.remove();
      if (barraPlayer) barraPlayer.remove();



      // Para o loop quando os dois já foram removidos
      if (!header && !footer && !breadcrumb && !barraPlayer) clearInterval(interval);
    }, 100); // checa a cada 100ms
  })();
""");
            setState(() {
              isLoading = false;
              showWebView = true; // mostra WebView somente depois de remover
            });          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://radiotropical.net/sobre/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://radiotropical.net/sobre/'));
  }
  @override
  Widget build(BuildContext context) {
    return showWebView ? WebViewWidget(controller: controller):_shimmer();
  }
  Widget _shimmer(){
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              children: [
                SizedBox(height: 20,),
                Container(
                    width: double.infinity,
                    height: 350,
                    color: Colors.white,
                    child: Column(
                      children: [
                        Spacer(),
                        Container(
                          width: 100,
                          height: 30,
                          color: Colors.grey,
                        ),
                        Container(
                          width: 300,
                          height: 30,
                          color: Colors.grey,
                        ),
                      ],
                    )
                ),
                SizedBox(height: 5),
                SingleChildScrollView(
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          height: 150,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5,),
                        Container(
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          height: 150,
                          color: Colors.white,
                        ),

                      ],
                    )),
                SingleChildScrollView(
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          height: 150,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5,),
                        Container(
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          height: 150,
                          color: Colors.white,
                        ),

                      ],
                    )),
                SingleChildScrollView(
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          height: 150,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5,),
                        Container(
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          height: 150,
                          color: Colors.white,
                        ),

                      ],
                    )),

              ],
            )
        );
      },
    );

  }

}