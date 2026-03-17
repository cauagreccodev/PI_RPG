import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flame/game.dart';
import 'services/geolocation_service.dart';
import 'game/pirpg_game.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GeolocationService(),
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
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
      ),
      home: const GameScreen(),
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

  @override
  void initState() {
    super.initState();
    // We'll initialize the game here. 
    // Since we need geoService from context, we'll do it in didChangeDependencies
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final geoService = Provider.of<GeolocationService>(context, listen: false);
      _game = PIRPGGame(geoService: geoService);
      _initialized = true;
    }
  }

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
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurpleAccent),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("ESTADO DO GPS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                  const SizedBox(height: 4),
                  Text(
                    geoService.currentPosition != null 
                      ? "Lat: ${geoService.currentPosition!.latitude.toStringAsFixed(6)}\nLon: ${geoService.currentPosition!.longitude.toStringAsFixed(6)}"
                      : "Buscando GPS...",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Divider(color: Colors.white24),
                  Row(
                    children: [
                      Icon(
                        geoService.isInsideCampus() ? Icons.check_circle : Icons.error,
                        color: geoService.isInsideCampus() ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        geoService.isInsideCampus() ? "ÁREA DA PUC" : "FORA DA PUC",
                        style: TextStyle(
                          color: geoService.isInsideCampus() ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Bottom Left: Level List (Fases)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              height: 100,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("FASES DISPONÍVEIS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: geoService.levels.length,
                      itemBuilder: (context, index) {
                        final level = geoService.levels[index];
                        final isUnlocked = level['unlocked'] as bool;
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isUnlocked ? Colors.deepPurple.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isUnlocked ? Colors.purpleAccent : Colors.white24),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isUnlocked ? Icons.lock_open : Icons.lock,
                                  color: isUnlocked ? Colors.purpleAccent : Colors.grey,
                                  size: 20,
                                ),
                                Text(
                                  level['name'],
                                  style: TextStyle(
                                    color: isUnlocked ? Colors.white : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
              child: const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, color: Colors.white, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
