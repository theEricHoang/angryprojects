import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Application name
      title: 'Stateful Widget',
      theme: ThemeData(primarySwatch: Colors.blue),
      // A widget that will be started on the application startup
      home: CounterWidget(),
    );
  }
}

class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  //initial counter value
  int _counter = 0;
  int _customIncrement = 1;
  final int _maxLimit = 100;
  List<int> _history = [];
  final TextEditingController _incrementController = TextEditingController(
    text: '1',
  );
  bool _hasShownTarget50 = false;
  bool _hasShownTarget100 = false;

  @override
  void dispose() {
    _incrementController.dispose();
    super.dispose();
  }

  void _addToHistory() {
    setState(() {
      _history.add(_counter);
    });
  }

  void _incrementCounter() {
    if (_counter + _customIncrement <= _maxLimit) {
      _addToHistory();
      setState(() {
        _counter += _customIncrement;
      });
      _checkTargets();
    }
  }

  void _decrementCounter() {
    if (_counter - _customIncrement >= 0) {
      _addToHistory();
      setState(() {
        _counter -= _customIncrement;
      });
    }
  }

  void _resetCounter() {
    _addToHistory();
    setState(() {
      _counter = 0;
      _hasShownTarget50 = false;
      _hasShownTarget100 = false;
    });
  }

  void _undoCounter() {
    if (_history.isNotEmpty) {
      setState(() {
        _counter = _history.removeLast();
      });
    }
  }

  void _checkTargets() {
    if (_counter >= 100 && !_hasShownTarget100) {
      _hasShownTarget100 = true;
      _showCongratulationsDialog(100);
    } else if (_counter >= 50 && !_hasShownTarget50) {
      _hasShownTarget50 = true;
      _showCongratulationsDialog(50);
    }
  }

  void _showCongratulationsDialog(int target) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You have reached $target!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Color _getCounterColor() {
    if (_counter == 0) {
      return Colors.red;
    } else if (_counter > 50) {
      return Colors.green;
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Counter')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Counter Display
              Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _getCounterColor(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$_counter',
                    style: TextStyle(
                      fontSize: 50.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Maximum Limit Message
              if (_counter >= _maxLimit)
                Text(
                  'Maximum limit reached!',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              SizedBox(height: 20),

              // Slider
              Slider(
                min: 0,
                max: 100,
                value: _counter.toDouble(),
                onChanged: (double value) {
                  int oldValue = _counter;
                  setState(() {
                    _counter = value.toInt();
                  });
                  if (oldValue != _counter) {
                    _addToHistory();
                    _checkTargets();
                  }
                },
                activeColor: Colors.blue,
                inactiveColor: Colors.red,
              ),
              SizedBox(height: 20),

              // Custom Increment Input
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Custom Increment: '),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _incrementController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                      ),
                      onChanged: (value) {
                        int? parsedValue = int.tryParse(value);
                        if (parsedValue != null && parsedValue > 0) {
                          setState(() {
                            _customIncrement = parsedValue;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Buttons Row 1: Increment, Decrement, Reset
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _incrementCounter,
                    child: Text('Increment +$_customIncrement'),
                  ),
                  ElevatedButton(
                    onPressed: _decrementCounter,
                    child: Text('Decrement -$_customIncrement'),
                  ),
                  ElevatedButton(
                    onPressed: _resetCounter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Reset'),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Buttons Row 2: Undo
              ElevatedButton(
                onPressed: _history.isNotEmpty ? _undoCounter : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Undo'),
              ),
              SizedBox(height: 30),

              // History Section
              Text(
                'Counter History:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: _history.isEmpty
                    ? Center(child: Text('No history yet'))
                    : ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            dense: true,
                            title: Text('${index + 1}. ${_history[index]}'),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
