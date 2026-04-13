import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import '../services/geolocation_service.dart';
import '../models/player_state_model.dart';
import '../services/auth_service.dart';

import 'player.dart';

class PIRPGGame extends FlameGame {
  final GeolocationService geoService;
  final PlayerStateModel playerState;
  final AuthService authService;
  late Player player;


  PIRPGGame({required this.geoService, required this.playerState, required this.authService});



  @override
  Future<void> onLoad() async {
    try {
      final tiledMap = await TiledComponent.load(
        'map1.tmx',
        Vector2.all(32),
        prefix: 'assets/tiles/',
      );
      tiledMap.priority = 0;
      world.add(tiledMap);
    } catch (e) {
      debugPrint("Error loading map: $e");
    }

    player = Player(
      position: Vector2(336, 672), // Centro do mapa 32x32 (672x1344)
    );
    player.priority = 10;
    
    world.add(player);

    camera.viewfinder.zoom = 3.0; // Aumentado de 2.0 para 3.0 para ver melhor o herói
    camera.follow(player);

    await playerState.loadGame(
      token: authService.currentUser?.token,
      baseUrl: authService.baseUrl,
    );
  }

  @override
  Color backgroundColor() => const Color(0xFF0F172A);


  @override
  void update(double dt) {
    super.update(dt);
    
    if (geoService.currentPosition != null) {
      double lonDiff = (geoService.currentPosition!.longitude - geoService.campusCenterLon);
      double latDiff = (geoService.campusCenterLat - geoService.currentPosition!.latitude);

      // Mapa 672x1344 (32x32 tiles)
      double scaleX = 672 / 0.008;
      double scaleY = 1344 / 0.008;

      Vector2 newPosition = Vector2(
        336 + (lonDiff * scaleX),
        672 + (latDiff * scaleY),
      );

      // Clampe para não sumir do mapa
      newPosition.x = newPosition.x.clamp(0.0, 672.0);
      newPosition.y = newPosition.y.clamp(0.0, 1344.0);

      player.velocity = (newPosition - player.position) / dt;
      player.position = newPosition;
      
      for (var level in geoService.levels) {
        if (geoService.isNearLevel(level)) {
          playerState.setPhase(level['name'] as String);

        }
      }
    }
  }
}
