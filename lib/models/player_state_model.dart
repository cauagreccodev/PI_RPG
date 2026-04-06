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
  int _hp;
  int _maxHp;
  String _currentPhase;
  List<GameItem> _inventory;
  List<String> _defeatedPhases;

  PlayerStateModel({
    int hp = 100,
    int maxHp = 100,
    String currentPhase = 'Início',
    List<GameItem>? inventory,
    List<String>? defeatedPhases,
  })  : _hp = hp,
        _maxHp = maxHp,
        _currentPhase = currentPhase,
        _inventory = inventory ?? [],
        _defeatedPhases = defeatedPhases ?? [];

  int get hp => _hp;
  int get maxHp => _maxHp;
  String get currentPhase => _currentPhase;
  List<GameItem> get inventory => List.unmodifiable(_inventory);

  bool isPhaseDefeated(String phaseId) => _defeatedPhases.contains(phaseId);

  void markPhaseDefeated(String phaseId) {
    if (!_defeatedPhases.contains(phaseId)) {
      _defeatedPhases.add(phaseId);
      notifyListeners();
    }
  }

  void setPhase(String phase) {
    _currentPhase = phase;
    notifyListeners();
  }

  void takeDamage(int amount) {
    if (_hp > 0) {
      _hp -= amount;
      if (_hp < 0) _hp = 0;
      notifyListeners();
    }
  }

  void heal(int amount) {
    if (_hp < _maxHp) {
      _hp += amount;
      if (_hp > _maxHp) _hp = _maxHp;
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
    await prefs.setInt('hp', _hp);
    await prefs.setInt('maxHp', _maxHp);
    await prefs.setString('currentPhase', _currentPhase);
    final itemsJson = _inventory.map((i) => jsonEncode(i.toJson())).toList();
    await prefs.setStringList('inventory', itemsJson);
    await prefs.setStringList('defeatedPhases', _defeatedPhases);
  }

  Future<void> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    _hp = prefs.getInt('hp') ?? 100;
    _maxHp = prefs.getInt('maxHp') ?? 100;
    _currentPhase = prefs.getString('currentPhase') ?? 'Início';
    final itemsJson = prefs.getStringList('inventory') ?? [];
    _inventory = itemsJson
        .map((s) => GameItem.fromJson(jsonDecode(s)))
        .toList();
    _defeatedPhases = prefs.getStringList('defeatedPhases') ?? [];
    notifyListeners();
  }
}
