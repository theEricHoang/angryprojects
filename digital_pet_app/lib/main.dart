import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: DigitalPetApp()));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  int _energyLevel = 100;

  final TextEditingController _nameController = TextEditingController();
  Timer? _hungerTimer;
  DateTime? _happyStartTime;
  bool _gameOver = false;
  bool _gameWon = false;

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  void _startHungerTimer() {
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        hungerLevel = (hungerLevel + 5).clamp(0, 100);
        _checkWinLossConditions();
      });
    });
  }

  void _checkWinLossConditions() {
    // Loss condition: hunger reaches 100 AND happiness drops to 10
    if (hungerLevel >= 100 && happinessLevel <= 10) {
      _gameOver = true;
      _hungerTimer?.cancel();
      return;
    }

    // Win condition: happiness > 80 for 3 minutes
    if (happinessLevel > 80) {
      _happyStartTime ??= DateTime.now();
      if (DateTime.now().difference(_happyStartTime!).inMinutes >= 3) {
        _gameWon = true;
        _hungerTimer?.cancel();
      }
    } else {
      _happyStartTime = null;
    }
  }

  void _playWithPet() {
    if (_gameOver || _gameWon) return;
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _energyLevel = (_energyLevel - 10).clamp(0, 100);
      _updateHunger();
      _checkWinLossConditions();
    });
  }

  void _feedPet() {
    if (_gameOver || _gameWon) return;
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _energyLevel = (_energyLevel - 5).clamp(0, 100);
      _updateHappiness();
      _checkWinLossConditions();
    });
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
  }

  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
  }

  Color _getPetColor() {
    if (happinessLevel > 70) return Colors.green;
    if (happinessLevel >= 30) return Colors.yellow;
    return Colors.red;
  }

  String _getMoodText() {
    if (happinessLevel > 70) return "Happy 😊";
    if (happinessLevel >= 30) return "Neutral 😐";
    return "Unhappy 😢";
  }

  void _setCustomName() {
    if (_nameController.text.trim().isNotEmpty) {
      setState(() {
        petName = _nameController.text.trim();
      });
      _nameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Digital Pet')),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Pet Name Customization (TextField + Button)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Enter pet name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: _setCustomName,
                      child: Text('Set Name'),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),

                // Pet Name Display
                Text('Name: $petName', style: TextStyle(fontSize: 20.0)),
                SizedBox(height: 16.0),

                // Pet Image with Dynamic Color Change
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _getPetColor(),
                    BlendMode.modulate,
                  ),
                  child: Image.asset(
                    'assets/pet_image.png',
                    height: 200,
                    width: 200,
                  ),
                ),
                SizedBox(height: 8.0),

                // Mood Indicator
                Text(_getMoodText(), style: TextStyle(fontSize: 20.0)),
                SizedBox(height: 16.0),

                // Happiness and Hunger Levels
                Text(
                  'Happiness Level: $happinessLevel',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Hunger Level: $hungerLevel',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(height: 16.0),

                // Energy Bar
                Text(
                  'Energy Level: $_energyLevel',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(height: 8.0),
                LinearProgressIndicator(
                  value: _energyLevel / 100,
                  backgroundColor: Colors.grey[300],
                  color: _energyLevel > 50
                      ? Colors.green
                      : _energyLevel > 20
                      ? Colors.orange
                      : Colors.red,
                  minHeight: 16.0,
                ),
                SizedBox(height: 32.0),

                // Action Buttons
                ElevatedButton(
                  onPressed: (_gameOver || _gameWon) ? null : _playWithPet,
                  child: Text('Play with Your Pet'),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: (_gameOver || _gameWon) ? null : _feedPet,
                  child: Text('Feed Your Pet'),
                ),
                SizedBox(height: 16.0),

                // Game Over Message
                if (_gameOver)
                  Text(
                    'Game Over!',
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                // Win Message
                if (_gameWon)
                  Text(
                    'You Win! 🎉',
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
