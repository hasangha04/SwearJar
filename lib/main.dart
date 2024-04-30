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
        initialRoute: '/',
        routes: {
          '/': (context) => const MyJarPage(title: 'Swear Jar'),
          '/dares': (context) => const DaresPage(title: 'Dares Page'),
          '/stats': (context) => const StatsPage(title: 'Stats Page'),
          '/actsOfKindness': (context) => const ActsOfKindnessPage(title: 'Acts of Kindness Page'),
        }
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
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Image.asset(
                'jar.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Add Swear',
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.whatshot),
                label: 'Dares',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Stats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Acts of Kindness',
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.pushNamed(context, '/dares');
                  break;
                case 1:
                  Navigator.pushNamed(context, '/stats');
                  break;
                case 2:
                  Navigator.pushNamed(context, '/actsOfKindness');
                  break;
              }
            }
        )
    );
  }
}

class DaresPage extends StatelessWidget {
  const DaresPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'Dares Page'),
      ),
      body: Center(
        child: Text('Dares Page Content'),
      ),
    );
  }
}

class StatsPage extends StatelessWidget {
  const StatsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'Stats Page'),
      ),
      body: Center(
        child: Text('Stats Page Content'),
      ),
    );
  }
}

class ActsOfKindnessPage extends StatelessWidget {
  const ActsOfKindnessPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'Acts of Kindness Page'), // Use default value if title is null
      ),
      body: Center(
        child: Text('Acts of Kindness Page Content'),
      ),
    );
  }
}