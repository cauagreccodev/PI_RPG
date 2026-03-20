import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import '../services/geolocation_service.dart';
<<<<<<< HEAD
import '../models/player_state_model.dart';
=======
>>>>>>> 79969a30f2756953b3330b4b7e4b7d33d07fad99
import 'player.dart';

class PIRPGGame extends FlameGame with HasGameRef {
  final GeolocationService geoService;
<<<<<<< HEAD
  final PlayerStateModel playerState;
  late Player player;


  PIRPGGame({required this.geoService, required this.playerState});
=======
  late Player player;
  Vector2 _lastPosition = Vector2.zero();
  
  PIRPGGame({required this.geoService});
>>>>>>> 79969a30f2756953b3330b4b7e4b7d33d07fad99

  @override
  Future<void> onLoad() async {
    try {
      final tiledMap = await TiledComponent.load(
<<<<<<< HEAD
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

    await playerState.loadGame();
  }

  @override
  Color backgroundColor() => const Color(0xFF0F172A);
=======
        'map1.tmx', 
        Vector2.all(32), // High-res tiles for better clarity
        prefix: 'assets/tiles/',
      );
      add(tiledMap);
    } catch (e) {
      debugPrint("Could not load Tiled map: $e");
    }

    player = Player(
      position: Vector2(160 * 2, 330 * 2), // Adjusted for 2x tile scale
    );
    add(player);

    camera.follow(player);
    camera.viewfinder.zoom = 2.0; // Balanced zoom for 32px tiles
    camera.viewfinder.anchor = Anchor.center;
  }

  @override
  Color backgroundColor() => const Color(0xFF0F172A); // Very dark slate (premium look)
>>>>>>> 79969a30f2756953b3330b4b7e4b7d33d07fad99

  @override
  void update(double dt) {
    super.update(dt);
    
    if (geoService.currentPosition != null) {
<<<<<<< HEAD
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
=======
      // Map Lat/Long to Game X/Y
      double lonDiff = (geoService.currentPosition!.longitude - geoService.campusCenterLon);
      double latDiff = (geoService.campusCenterLat - geoService.currentPosition!.latitude);
      
      // Scale: 0.008 deg (campus width) -> 672 pixels (336 * 2)
      double scaleX = 672 / 0.008; 
      double scaleY = 1344 / 0.008;

      Vector2 newPosition = Vector2(
        336 + (lonDiff * scaleX), // 168 * 2
        672 + (latDiff * scaleY)  // 336 * 2
      );

      // Calculate velocity for animation
      player.velocity = (newPosition - player.position) / dt;
      player.position = newPosition;

      // Update last position if needed
      _lastPosition = newPosition.clone();

      // Simple visual feedback if near a level
      for (var level in geoService.levels) {
        if (geoService.isNearLevel(level)) {
          // You are at a fase!
>>>>>>> 79969a30f2756953b3330b4b7e4b7d33d07fad99
        }
      }
    }
  }
}
