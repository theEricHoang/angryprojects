import 'package:flutter/material.dart';

void main() {
  runApp(const RunMyApp());
}

class RunMyApp extends StatefulWidget {
  const RunMyApp({super.key});

  @override
  State<RunMyApp> createState() => _RunMyAppState();
}

class _RunMyAppState extends State<RunMyApp> {
  // Variable to manage the current theme mode
  ThemeMode _themeMode = ThemeMode.system;

  // Method to toggle the theme
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Theme Demo',
      
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[200], // Light mode background
      ),
      darkTheme: ThemeData.dark(), // Dark mode configuration
      
      themeMode: _themeMode, // Connects the state to the app

      home: Scaffold(
        appBar: AppBar(
          title: const Text('Theme Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PART 1 TASK: Container and Text
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 300,
                height: 200,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Mobile App Development Testing',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 20),
              
              Text('Choose the Theme:', style: Theme.of(context).textTheme.bodyMedium),
              
              const SizedBox(height: 10),

              // PART 2 TASK: Switch Widget
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Light'),
                  Switch(
                    value: _themeMode == ThemeMode.dark,
                    onChanged: (bool value) {
                      changeTheme(value ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                  const Text('Dark'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
        