import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:provider/provider.dart';
import 'package:flame/game.dart';
import 'services/auth_service.dart';
import 'services/geolocation_service.dart';
import 'game/pirpg_game.dart';
import 'models/player_state_model.dart';
import 'ui/login_screen.dart';
import 'ui/profile_overlay.dart';
import 'ui/pause_overlay.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => GeolocationService()),
        ChangeNotifierProvider(create: (_) => PlayerStateModel()),
      ],
=======
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:flame/game.dart';
import 'services/geolocation_service.dart';
import 'game/pirpg_game.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GeolocationService(),
>>>>>>> 79969a30f2756953b3330b4b7e4b7d33d07fad99
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIRPG',
<<<<<<< HEAD
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.brown,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF4F4F4F),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF8B4513), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF8B4513), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFF0E68C), width: 2),
          ),
        ),
      ),
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: Color(0xFFF0E68C))),
            );
          }
          return auth.isAuthenticated ? const GameScreen() : const LoginScreen();
        },
      ),
=======
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
      ),
      home: const GameScreen(),
>>>>>>> 79969a30f2756953b3330b4b7e4b7d33d07fad99
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final PIRPGGame _game;
<<<<<<< HEAD
=======

  @override
  void initState() {
    super.initState();
    // We'll initialize the game here. 
    // Since we need geoService from context, we'll do it in didChangeDependencies
  }

>>>>>>> 79969a30f2756953b3330b4b7e4b7d33d07fad99
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final geoService = Provider.of<GeolocationService>(context, listen: false);
<<<<<<< HEAD
      final playerState = Provider.of<PlayerStateModel>(context, listen: false);
      _game = PIRPGGame(geoService: geoService, playerState: playerState);
=======
      _game = PIRPGGame(geoService: geoService);
>>>>>>> 79969a30f2756953b3330b4b7e4b7d33d07fad99
      _initialized = true;
    }
  }

<<<<<<< HEAD
  void _openProfile() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar Perfil',
      barrierColor: Colors.black.withAlpha(120),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const ProfileOverlay(),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  void _openPause() {
    _game.pauseEngine();
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Pause',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) => PauseOverlay(game: _game),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final geoService = Provider.of<GeolocationService>(context);
    final playerState = Provider.of<PlayerStateModel>(context);

    final locationName = geoService.isInsideCampus() ? 'REINO DA PUC' : 'TERRAS SELVAGENS';
    final locationColor = geoService.isInsideCampus() ? MedievalColors.emeraldLight : MedievalColors.crimsonLight;

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),

          // HUD - Top Left
          Positioned(
            top: 40,
            left: 16,
            child: _MedievalBadge(
              icon: Icons.map_rounded,
              label: locationName,
              color: locationColor,
            ),
          ),

          // HUD - Top Center
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _TavernButton(onTap: _openPause),
            ),
          ),

          // HUD - Top Right
          Positioned(
            top: 40,
            right: 16,
            child: _CompactProfile(
              onTap: _openProfile,
              lives: playerState.lives,
              maxLives: playerState.maxLives,
            ),
          ),

          // HUD - Bottom
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _HorizontalMapScroll(levels: geoService.levels),
          ),
        ],
      ),
    );
  }
}

// ── Components ─────────────────────────────────────────────────────────────

class _MedievalBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MedievalBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xCC1A0A00),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(150), width: 1.5),
        boxShadow: [BoxShadow(color: color.withAlpha(30), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: MedievalColors.parchment,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TavernButton extends StatelessWidget {
  final VoidCallback onTap;
  const _TavernButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(colors: [Color(0xFF5A3A00), Color(0xFF2A1500)]),
          border: Border.all(color: MedievalColors.gold, width: 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10)],
        ),
        child: const Center(child: Text('⚔', style: TextStyle(fontSize: 18))),
      ),
    );
  }
}

class _CompactProfile extends StatelessWidget {
  final VoidCallback onTap;
  final int lives;
  final int maxLives;

  const _CompactProfile({required this.onTap, required this.lives, required this.maxLives});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: List.generate(
                  maxLives.clamp(0, 3),
                  (i) => Icon(
                    i < lives ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: i < lives ? MedievalColors.crimsonLight : Colors.grey.withAlpha(100),
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              const Text('PERFIL', style: TextStyle(color: MedievalColors.gold, fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: MedievalColors.gold, width: 1.5),
              color: const Color(0xFF2A1500),
            ),
            child: const Icon(Icons.person, color: MedievalColors.parchment, size: 24),
=======
  @override
  Widget build(BuildContext context) {
    final geoService = Provider.of<GeolocationService>(context);
    
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: _game,
          ),
          // Top Left: Coordinates and Campus Status
          Positioned(
            top: 40,
            left: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "ESTADO DO GPS",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        geoService.currentPosition != null 
                          ? "Lat: ${geoService.currentPosition!.latitude.toStringAsFixed(6)}\nLon: ${geoService.currentPosition!.longitude.toStringAsFixed(6)}"
                          : "Buscando satélites...",
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: geoService.isInsideCampus() 
                              ? [Colors.green.withOpacity(0.3), Colors.green.withOpacity(0.1)]
                              : [Colors.red.withOpacity(0.3), Colors.red.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: geoService.isInsideCampus() ? Colors.greenAccent : Colors.redAccent,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              geoService.isInsideCampus() ? Icons.gps_fixed : Icons.gps_off,
                              color: geoService.isInsideCampus() ? Colors.greenAccent : Colors.redAccent,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              geoService.isInsideCampus() ? "ÁREA DA PUC" : "FORA DA ÁREA",
                              style: TextStyle(
                                color: geoService.isInsideCampus() ? Colors.greenAccent : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom Left: Level List (Fases)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  height: 110, // Reduced from 120 to fix overflow
                  padding: const EdgeInsets.all(12), // Reduced padding
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "FASES DISPONÍVEIS",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          Icon(Icons.map_outlined, color: Colors.white.withOpacity(0.4), size: 14),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: geoService.levels.length,
                          itemBuilder: (context, index) {
                            final level = geoService.levels[index];
                            final isUnlocked = level['unlocked'] as bool;
                            return Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(vertical: 4), // Added inner padding
                              decoration: BoxDecoration(
                                gradient: isUnlocked 
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Colors.deepPurple.withOpacity(0.5), Colors.purpleAccent.withOpacity(0.3)],
                                    )
                                  : null,
                                color: isUnlocked ? null : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isUnlocked ? Colors.purpleAccent.withOpacity(0.6) : Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isUnlocked ? Icons.explore : Icons.lock_outline,
                                          color: isUnlocked ? Colors.purpleAccent : Colors.white24,
                                          size: 24,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          level['name'],
                                          style: TextStyle(
                                            color: isUnlocked ? Colors.white : Colors.white38,
                                            fontSize: 12,
                                            fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isUnlocked)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.greenAccent,
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 4)],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // User profile overlay
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                // Open Profile
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.deepPurpleAccent,
                  child: Icon(Icons.person_rounded, color: Colors.white, size: 32),
                ),
              ),
            ),
>>>>>>> 79969a30f2756953b3330b4b7e4b7d33d07fad99
          ),
        ],
      ),
    );
  }
}
<<<<<<< HEAD

class _HorizontalMapScroll extends StatelessWidget {
  final List<dynamic> levels;
  const _HorizontalMapScroll({required this.levels});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0x99000000),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MedievalColors.gold.withAlpha(50)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          final isUnlocked = level['unlocked'] as bool;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: Text(
              level['name'],
              style: TextStyle(
                color: isUnlocked ? MedievalColors.parchment : MedievalColors.textMuted.withAlpha(100),
                fontSize: 11,
                fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}
=======
>>>>>>> 79969a30f2756953b3330b4b7e4b7d33d07fad99
