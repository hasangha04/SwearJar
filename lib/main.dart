import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swear Jar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyJarPage(title: 'Swear Jar'),
    );
  }
}

class MyJarPage extends StatefulWidget {
  const MyJarPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyJarPage> createState() => _MyJarPageState();
}

class _MyJarPageState extends State<MyJarPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title ?? 'Swear Jar'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Push button to add a swear to the jar',
            ),
            Text(
              'Swears in Jar: $_counter',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Add Swear',
        child: const Icon(Icons.add),
      ),
    );
  }
}
