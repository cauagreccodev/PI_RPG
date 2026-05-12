import 'package:flutter/material.dart';

/// Classe com geradores de assets visuais simples para testes rápidos
/// Use para prototipagem antes de ter os assets finais
class AssetGenerators {
  /// Gera um fundo futurista simples
  static Widget generateBattleBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[900]!, Colors.blueGrey[800]!, Colors.grey[900]!],
        ),
      ),
      child: CustomPaint(
        painter: BinaryRainPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }

  /// Gera um frame simples para HUD
  static Widget generateHudFrame({
    required Widget child,
    Color borderColor = Colors.cyan,
    double borderWidth = 2,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
        color: Colors.black87,
      ),
      child: child,
    );
  }

  /// Gera um sprite simples do inimigo (círculo com detalhes)
  static Widget generateEnemySprite() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [Colors.red[300]!, Colors.red[900]!]),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.8),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Olhos vermelhos
          Positioned(
            top: 40,
            left: 30,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.red[900],
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 30,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.red[900],
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          // Boca
          Positioned(
            bottom: 40,
            child: Container(
              width: 60,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.red[900],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Gera um sprite simples do jogador (retângulo com detalhes)
  static Widget generatePlayerSprite() {
    return Container(
      width: 100,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.blueGrey[600],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Capacete
          Positioned(
            top: 10,
            child: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blueGrey[400],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          ),
          // Corpo
          Positioned(
            top: 50,
            child: Container(
              width: 70,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red[400],
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          ),
          // Pernas
          Positioned(
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(width: 25, height: 40, color: Colors.blueGrey[600]),
                Container(width: 25, height: 40, color: Colors.blueGrey[600]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Gera um botão com efeito de brilho
  static Widget generateButton({
    required String label,
    required VoidCallback onPressed,
    Color bgColor = Colors.red,
    Color textColor = Colors.white,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: bgColor.withOpacity(0.8), width: 2),
        ),
        elevation: 8,
        shadowColor: bgColor.withOpacity(0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// Custom Painter para desenhar chuva de números binários
class BinaryRainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.3)
      ..strokeWidth = 1.5;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final List<String> binaryChars = ['0', '1'];

    for (int i = 0; i < 50; i++) {
      final x = (i * 30 % size.width).toDouble();
      final y = (i * 15 % size.height).toDouble();
      final char = binaryChars[i % 2];

      textPainter.text = TextSpan(
        text: char,
        style: TextStyle(
          color: Colors.cyan.withOpacity(0.4),
          fontSize: 12,
          fontFamily: 'Courier',
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(BinaryRainPainter oldDelegate) => false;
}
