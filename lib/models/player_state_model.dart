import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameItem {
  final String id;
  final String name;
  final String description;
  final String icon; // emoji ou nome do asset

  GameItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
      };

  factory GameItem.fromJson(Map<String, dynamic> json) => GameItem(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        icon: json['icon'],
      );
}

class PlayerStateModel extends ChangeNotifier {
  int _lives;
  int _maxLives;
  String _currentPhase;
  List<GameItem> _inventory;

  PlayerStateModel({
    int lives = 3,
    int maxLives = 5,
    String currentPhase = 'Início',
    List<GameItem>? inventory,
  })  : _lives = lives,
        _maxLives = maxLives,
        _currentPhase = currentPhase,
        _inventory = inventory ?? [];

  int get lives => _lives;
  int get maxLives => _maxLives;
  String get currentPhase => _currentPhase;
  List<GameItem> get inventory => List.unmodifiable(_inventory);

  void setPhase(String phase) {
    _currentPhase = phase;
    notifyListeners();
  }

  void takeDamage() {
    if (_lives > 0) {
      _lives--;
      notifyListeners();
    }
  }

  void heal() {
    if (_lives < _maxLives) {
      _lives++;
      notifyListeners();
    }
  }

  void addItem(GameItem item) {
    _inventory.add(item);
    notifyListeners();
  }

  void removeItem(String itemId) {
    _inventory.removeWhere((i) => i.id == itemId);
    notifyListeners();
  }

  Future<void> saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lives', _lives);
    await prefs.setInt('maxLives', _maxLives);
    await prefs.setString('currentPhase', _currentPhase);
    final itemsJson = _inventory.map((i) => jsonEncode(i.toJson())).toList();
    await prefs.setStringList('inventory', itemsJson);
  }

  Future<void> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    _lives = prefs.getInt('lives') ?? 3;
    _maxLives = prefs.getInt('maxLives') ?? 5;
    _currentPhase = prefs.getString('currentPhase') ?? 'Início';
    final itemsJson = prefs.getStringList('inventory') ?? [];
    _inventory = itemsJson
        .map((s) => GameItem.fromJson(jsonDecode(s)))
        .toList();
    notifyListeners();
  }
}
