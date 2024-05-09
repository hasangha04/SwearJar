import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:swear_jar/firebaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
          title: Text('Swear Jar'),
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
        title: Text(title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('dares').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final dares = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data == null
                ? {'dare': '', 'severity': 0}
                : {
              'dare': data['dare'] ?? '',
              'severity': data['severity'] ?? 0,
            };
          }).toList().reversed.toList();

          return ListView.builder(
            itemCount: dares.length,
            itemBuilder: (context, index) {
              final dare = dares[index];
              return ListTile(
                title: Text(dare['dare'] ?? ''),
                subtitle: Text('Severity: ${dare['severity']}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to a page where users can add a dare
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDarePage()),
          );
        },
        tooltip: 'Add Dare',
        child: Icon(Icons.add),
      ),
    );
  }
}

// Create a new page for adding dares
class AddDarePage extends StatefulWidget {
  @override
  _AddDarePageState createState() => _AddDarePageState();
}

class _AddDarePageState extends State<AddDarePage> {
  String newDareText = ''; // Store the text of the new dare
  int newDareSeverity = 1; // Store the severity of the new dare, default to 1

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Dare'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                newDareText = value;
              },
              decoration: InputDecoration(
                labelText: 'Enter dare',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                newDareSeverity = int.tryParse(value) ?? 1;
              },
              decoration: InputDecoration(
                labelText: 'Enter severity (1-4)',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add the new dare to Firebase
                FirebaseService.addDare(newDareText, newDareSeverity);
                // Navigate back to the previous page
                Navigator.pop(context);
              },
              child: Text('Add Dare'),
            ),
          ],
        ),
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
        title: Text('Stats Page'),
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
        title: Text('Acts of Kindness Page'),
      ),
      body: Center(
        child: Text('Acts of Kindness Page Content'),
      ),
    );
  }
}

