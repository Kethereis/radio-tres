import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ProgramacaoItem extends StatelessWidget {
  final String titulo;
  final String horario;
  final String dias;
  final String apresentador;
  final String imagem;

  const ProgramacaoItem({
    super.key,
    required this.titulo,
    required this.horario,
    required this.dias,
    required this.apresentador,
    required this.imagem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Largura máxima da imagem = min(24% do card, 140px)
          final maxImgWidth = constraints.maxWidth * 0.24;
          final imgWidth = maxImgWidth.clamp(72.0, 140.0);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Texto ocupa o espaço flexível
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$horario ($dias)",
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Locutor(a): $apresentador",
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Imagem com limites responsivos
              ConstrainedBox(
                constraints: BoxConstraints(
                  // largura responsiva (com mínimo e máximo)
                  maxWidth: imgWidth,
                ),
                child: AspectRatio(
                  // ajuste a proporção conforme suas imagens
                  aspectRatio: 1, // quadrada; experimente 16/9 se for banner
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      "assets/$imagem",
                      fit: BoxFit.contain, // use .contain se for logo com fundo
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
