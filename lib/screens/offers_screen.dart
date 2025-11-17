import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/constants.dart';
import '../widget/default_button_widget.dart';
import '../widget/input_text_widget.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});
  @override
  State<OffersScreen> createState() => OffersScreenState();
}
class OffersScreenState extends State<OffersScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _mensagemController = TextEditingController();

  Future<void> _launchUrl(String nome, String mensagem) async {
    String url = "https://wa.me/553532393600?text=Olá, meu nome é $nome, $mensagem";

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

  var maskPhone = new MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: { "#": RegExp(r'[0-9]') },
      type: MaskAutoCompletionType.lazy
  );
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(20),
    child: Center(
    child: Column(
      children: [
        InputTextWidget(
          hintText: 'Digite seu nome',
          icon: Icons.person,
          elevation: 3,
          keyboard: TextInputType.name,
          label: 'Nome',
          inputFormatters: [],
          controller: _nomeController,

        ),
        SizedBox(height: 10,),
        InputTextWidget(
          hintText: 'Digite seu telefone',
          icon: Icons.phone,
          elevation: 3,
          keyboard: TextInputType.number,
          label: 'Telefone',
          inputFormatters: [maskPhone],
          controller: _telefoneController,

        ),
        SizedBox(height: 10,),
        InputTextWidget(
          hintText: 'Digite sua mensagem',
          icon: Icons.message,
          elevation: 3,
          maxLines: 5,
          keyboard: TextInputType.name,
          label: 'Mensagem',
          inputFormatters: [],
          controller: _mensagemController,

        ),
      SizedBox(height: 20,),
        DefaultButtonWidget(text: "Enviar", onTap: (){
          String telefone = _telefoneController.text.replaceAll("(", "").replaceAll(")", "").replaceAll("-","").replaceAll(" ", "").trim();
          print(telefone);
          _launchUrl(_nomeController.text, _mensagemController.text);
        }, loading: false, color: AppConstants.primaryColor)
    ],)));
  }
}