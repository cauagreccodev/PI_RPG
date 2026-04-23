import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../constants/asset_paths.dart';
import '../models/player_state_model.dart';
import '../utils/asset_generators.dart';

class BattleScreen extends StatefulWidget {
  final String? phaseId;

  const BattleScreen({Key? key, this.phaseId}) : super(key: key);

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with TickerProviderStateMixin {
  final Random _rng = Random();

  // Estado da batalha
  int playerHp = 100;
  int playerMaxHp = 100;
  int enemyHp = 80;
  int enemyMaxHp = 80;
  bool isPlayerTurn = true;
  String battleLog =
      'O NÚCLEO DE LÓGICA X selvagem apareceu! Vá, SOLDADO!';
  bool isAnimating = false;
  int playerLevel = 50;
  int healKits = 2;
  int skillCooldown = 0;
  bool _didInitializeFromPlayerState = false;

  // Animação
  late AnimationController _damageController;
  late Animation<Offset> _damageAnimation;
  bool _enemyHitFlash = false;

  @override
  void initState() {
    super.initState();
    _damageController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _damageAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(6, -8),
        ).animate(
          CurvedAnimation(parent: _damageController, curve: Curves.easeOut),
        );

    _damageController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _damageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitializeFromPlayerState) return;

    final playerState = Provider.of<PlayerStateModel>(context, listen: false);
    playerMaxHp = playerState.maxHp;
    playerHp = playerState.hp.clamp(1, playerMaxHp);
    _didInitializeFromPlayerState = true;
  }

  void _playerAttack() {
    if (isAnimating || !isPlayerTurn) return;

    final damage = 10 + _rng.nextInt(16);
    _executePlayerAction(
      damage: damage,
      logText: 'SOLDADO usou Luta!',
    );
  }

  void _useAbility() {
    if (isAnimating || !isPlayerTurn) return;
    if (skillCooldown > 0) {
      _showToast('Habilidade em recarga por $skillCooldown turno(s)');
      return;
    }

    final damage = 18 + _rng.nextInt(15);
    _executePlayerAction(
      damage: damage,
      logText: 'SOLDADO usou Pulso Quântico!',
      nextSkillCooldown: 2,
    );
  }

  void _executePlayerAction({
    required int damage,
    required String logText,
    int nextSkillCooldown = 0,
  }) {
    if (enemyHp <= 0 || playerHp <= 0) return;

    setState(() {
      isAnimating = true;
      isPlayerTurn = false;
      _enemyHitFlash = true;
      if (nextSkillCooldown > 0) {
        skillCooldown = nextSkillCooldown;
      }
      enemyHp = (enemyHp - damage).clamp(0, enemyMaxHp);
      battleLog = '$logText\n$damage de dano no inimigo!';
    });

    _damageController.forward().then((_) {
      if (!mounted) return;
      _damageController.reset();
      setState(() => _enemyHitFlash = false);

      if (enemyHp <= 0) {
        setState(() {
          battleLog = '✓ VITÓRIA! Você venceu o NÚCLEO DE LÓGICA X!';
          isAnimating = false;
        });
        return;
      }

      _enemyAttack();
    });
  }

  void _enemyAttack() {
    if (enemyHp <= 0) {
      setState(() {
        battleLog = '✓ VITÓRIA! Você venceu o NÚCLEO DE LÓGICA X!';
        isAnimating = false;
      });
      return;
    }

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      final damage = 6 + _rng.nextInt(10);
      setState(() {
        playerHp = (playerHp - damage).clamp(0, playerMaxHp);
        battleLog = 'NÚCLEO usou Raio Lógico!\n$damage de dano!';
        isAnimating = false;
        isPlayerTurn = playerHp > 0;
        if (skillCooldown > 0) {
          skillCooldown = (skillCooldown - 1).clamp(0, 99);
        }
      });

      if (playerHp <= 0) {
        setState(() {
          battleLog = '✗ DERROTA! Você foi derrotado...';
          isPlayerTurn = false;
        });
      }
    });
  }

  void _openBackpack() {
    if (isAnimating || !isPlayerTurn) return;
    if (healKits <= 0) {
      _showToast('Mochila vazia: sem kit de reparo.');
      return;
    }
    if (playerHp >= playerMaxHp) {
      _showToast('HP já está cheio.');
      return;
    }

    final heal = 20 + _rng.nextInt(11);
    setState(() {
      healKits -= 1;
      playerHp = (playerHp + heal).clamp(0, playerMaxHp);
      battleLog = 'SOLDADO usou Kit de Reparo!\n+$heal HP restaurado.';
      isPlayerTurn = false;
      isAnimating = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => isAnimating = false);
      _enemyAttack();
    });
  }

  void _attemptRun() {
    if (isAnimating || !isPlayerTurn) return;
    final escaped = _rng.nextDouble() < 0.35;
    if (escaped) {
      Navigator.pop(context, false);
      return;
    }

    setState(() {
      battleLog = 'Tentativa de fuga falhou!';
      isPlayerTurn = false;
      isAnimating = true;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => isAnimating = false);
      _enemyAttack();
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 1)));
  }

  void _closeGame() {
    // Se a batalha não terminou, fecha normalmente
    if (playerHp > 0 && enemyHp > 0) {
      Navigator.pop(context);
      return;
    }

    // Se terminou, retorna o resultado (true = vitória, false = derrota)
    bool isVictory = enemyHp <= 0 && playerHp > 0;
    Navigator.pop(context, isVictory);
  }

  @override
  Widget build(BuildContext context) {
    final isGameOver = playerHp <= 0 || enemyHp <= 0;
    const imageWidth = 572.0;
    const imageHeight = 991.0;
    const imageRatio = imageWidth / imageHeight;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableW = constraints.maxWidth;
            final availableH = constraints.maxHeight;
            final availableRatio = availableW / availableH;

            double renderW;
            double renderH;
            if (availableRatio > imageRatio) {
              renderH = availableH;
              renderW = renderH * imageRatio;
            } else {
              renderW = availableW;
              renderH = renderW / imageRatio;
            }

            final left = (availableW - renderW) / 2;
            final top = (availableH - renderH) / 2;

            Rect hitbox(double x, double y, double w, double h) => Rect.fromLTWH(
              left + renderW * x,
              top + renderH * y,
              renderW * w,
              renderH * h,
            );

            final combatButton = hitbox(0.07, 0.85, 0.36, 0.12);
            final bagButton = hitbox(0.57, 0.85, 0.36, 0.12);
            final closeButton = hitbox(0.91, 0.01, 0.08, 0.06);
            final dialogArea = hitbox(0.08, 0.69, 0.84, 0.11);

            return Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: SizedBox(
                      width: renderW,
                      height: renderH,
                      child: Image.asset(AssetPaths.battleBackground, fit: BoxFit.fill),
                    ),
                  ),
                ),

                // Área de texto dinâmica sobre a caixa de diálogo da arte
                Positioned.fromRect(
                  rect: dialogArea,
                  child: IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        battleLog,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),

                // Hitbox: COMBATE
                if (!isGameOver)
                  Positioned.fromRect(
                    rect: combatButton,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _playerAttack,
                        borderRadius: BorderRadius.circular(16),
                        splashColor: Colors.white24,
                        highlightColor: Colors.transparent,
                      ),
                    ),
                  ),

                // Hitbox: MOCHILA
                if (!isGameOver)
                  Positioned.fromRect(
                    rect: bagButton,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _openBackpack,
                        borderRadius: BorderRadius.circular(16),
                        splashColor: Colors.white24,
                        highlightColor: Colors.transparent,
                      ),
                    ),
                  ),

                // Hitbox: fechar
                Positioned.fromRect(
                  rect: closeButton,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _closeGame,
                      borderRadius: BorderRadius.circular(40),
                      splashColor: Colors.red.withValues(alpha: 0.2),
                    ),
                  ),
                ),

                if (isGameOver)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _closeGame,
                          child: Text(enemyHp <= 0 ? 'Vitória - Voltar' : 'Derrota - Voltar'),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Image.asset(
      AssetPaths.battleBackground,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[900]!,
                Colors.blueGrey[800]!,
                Colors.grey[900]!,
              ],
            ),
          ),
          child: CustomPaint(
            painter: BinaryRainPainter(),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }

  Widget _buildEnemySprite() {
    return Container(
      width: 150,
      height: 150,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              _enemyHitFlash ? Colors.orange[200]! : Colors.red[300]!,
              _enemyHitFlash ? Colors.red[700]! : Colors.red[900]!,
            ],
          ),
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
          // Telas vermelhas (efeito de acesso negado)
          Positioned(
            top: 30,
            left: 30,
            child: Container(
              width: 50,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red[900],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red[400]!, width: 2),
              ),
              child: const Center(
                child: Text(
                  'X',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 30,
            child: Container(
              width: 50,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red[900],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red[400]!, width: 2),
              ),
              child: const Center(
                child: Text(
                  'X',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// Widget HUD do Inimigo
class EnemyHUD extends StatelessWidget {
  final int hp;
  final int maxHp;

  const EnemyHUD({Key? key, required this.hp, required this.maxHp})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    double healthPercent = hp / maxHp;

    return AssetGenerators.generateHudFrame(
      borderColor: Colors.cyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NÚCLEO DE LÓGICA X',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'VER: ALPHA',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 12),
          // Info de HP
          Text(
            'HP: $hp/$maxHp',
            style: const TextStyle(
              color: Colors.cyan,
              fontSize: 11,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 8),
          // Barra de vida do inimigo
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: healthPercent,
              minHeight: 20,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(
                healthPercent > 0.5
                    ? Colors.red
                    : healthPercent > 0.25
                    ? Colors.orange
                    : Colors.red[900]!,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget HUD do Jogador
class PlayerHUD extends StatelessWidget {
  final int hp;
  final int maxHp;
  final int level;

  const PlayerHUD({
    Key? key,
    required this.hp,
    required this.maxHp,
    required this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double healthPercent = hp / maxHp;
    double shieldPercent = 0.6; // Escudo fixo por enquanto

    return AssetGenerators.generateHudFrame(
      borderColor: Colors.lightBlue,
      child: SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome e Nível
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SOLDADO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Lv $level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // HP
            Text(
              'HP: $hp/$maxHp',
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: healthPercent,
                minHeight: 16,
                backgroundColor: Colors.grey[700],
                valueColor: AlwaysStoppedAnimation<Color>(
                  healthPercent > 0.5
                      ? Colors.green
                      : healthPercent > 0.25
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Escudo
            Text(
              'Escudo: ${(shieldPercent * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.lightBlue, fontSize: 10),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: shieldPercent,
                minHeight: 12,
                backgroundColor: Colors.grey[700],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.lightBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget de Botões de Ação
class ActionButtons extends StatelessWidget {
  final VoidCallback onFight;
  final VoidCallback onAbility;
  final VoidCallback onBackpack;
  final VoidCallback onRun;
  final bool isPlayerTurn;
  final bool isBusy;
  final int healKits;
  final int skillCooldown;

  const ActionButtons({
    Key? key,
    required this.onFight,
    required this.onAbility,
    required this.onBackpack,
    required this.onRun,
    required this.isPlayerTurn,
    required this.isBusy,
    required this.healKits,
    required this.skillCooldown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final enabled = isPlayerTurn && !isBusy;

    return Container(
      width: 215,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Luta',
                  enabled: enabled,
                  onTap: onFight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: skillCooldown == 0 ? 'Habilidade' : 'Recarga $skillCooldown',
                  enabled: enabled && skillCooldown == 0,
                  onTap: onAbility,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Mochila ($healKits)',
                  enabled: enabled && healKits > 0,
                  onTap: onBackpack,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: 'Fugir',
                  enabled: enabled,
                  onTap: onRun,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled
                ? Colors.black.withValues(alpha: 0.28)
                : Colors.black.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled
                  ? Colors.white.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: enabled
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.55),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Widget Caixa de Diálogo
class DialogBoxWidget extends StatelessWidget {
  final String text;

  const DialogBoxWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AssetGenerators.generateHudFrame(
      borderColor: Colors.amber,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 100),
        child: SingleChildScrollView(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontFamily: 'Courier',
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class BinaryRainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
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
