import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:swear_jar/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? user = FirebaseAuth.instance.currentUser;
  user ??= await signInAnonymously();

  if (user == null) {
    print('Failed to sign in anonymously');
    return;
  }

  runApp(const MyApp());
}

Future<User?> signInAnonymously() async {
  try {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      print('User is already signed in: ${currentUser.uid}');
      return currentUser;
    }

    UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
    return userCredential.user;
  } catch (e) {
    print('Failed to sign in anonymously: $e');
    return null;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/actsOfKindness': (context) =>
        const ActsOfKindnessPage(title: 'Acts of Kindness Page'),
      },
    );
  }
}

// home page, shows swear jar
class MyJarPage extends StatefulWidget {
  const MyJarPage({super.key, required this.title});

  final String title;

  @override
  State<MyJarPage> createState() => _MyJarPageState();
}

class _MyJarPageState extends State<MyJarPage> {
  int _counter = 0;
  int _moneyInCents = 0;
  final int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await FirebaseService.getUserJarData();
    if (userData != null) {
      setState(() {
        _counter = userData['counter'] ?? 0;
        _moneyInCents = userData['moneyInCents'] ?? 0;
      });
    }
  }

  void _incrementCounter() async {
    setState(() {
      _counter++;
      if (_counter > 30) {
        _moneyInCents += 25;
      } else if (_counter > 20) {
        _moneyInCents += 10;
      } else if (_counter > 10) {
        _moneyInCents += 5;
      } else {
        _moneyInCents += 1;
      }
    });

    await FirebaseService.updateUserJarData(_counter, _moneyInCents);
  }

  String _getJarImagePath() {
    if (_moneyInCents < 10) {
      return 'jar_1.png';
    } else if (_moneyInCents < 50) {
      return 'jar_2.png';
    } else if (_moneyInCents < 150) {
      return 'jar_3.png';
    } else {
      return 'jar_4.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    double moneyInDollars = _moneyInCents / 100.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Swear Jar'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Push button to add money to the swear jar',
            ),
            Text(
              'Money in Jar: \$${moneyInDollars.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 20),
            Image.asset(
              _getJarImagePath(),
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
      bottomNavigationBar: BottomNavBar(selectedIndex: _selectedIndex),
    );
  }
}

// dares page, shows dares
class DaresPage extends StatelessWidget {
  const DaresPage({super.key, required this.title});

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
          }).toList();

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
            MaterialPageRoute(builder: (context) => const AddDarePage()),
          );
        },
        tooltip: 'Add Dare',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
    );
  }
}

// page to add dares
class AddDarePage extends StatefulWidget {
  const AddDarePage({super.key});

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
        title: const Text('Add Dare'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                newDareText = value;
              },
              decoration: const InputDecoration(
                labelText: 'Enter dare',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                newDareSeverity = int.tryParse(value) ?? 1;
              },
              decoration: const InputDecoration(
                labelText: 'Enter severity (1-4)',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add the new dare to Firebase
                FirebaseService.addDare(newDareText, newDareSeverity);
                // Navigate back to the previous page
                Navigator.pop(context);
              },
              child: const Text('Add Dare'),
            ),
          ],
        ),
      ),
    );
  }
}

// stats page
class StatsPage extends StatelessWidget {
  const StatsPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats Page'),
      ),
      body: const Center(
        child: Text('Stats Page Content'),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 2),
    );
  }
}

// acts of kindness page
class ActsOfKindnessPage extends StatelessWidget {
  const ActsOfKindnessPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('acts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final acts = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data == null
                ? {'act': '', 'severity': 0}
                : {
              'act': data['act'] ?? '',
              'severity': data['severity'] ?? 0,
            };
          }).toList();

          return ListView.builder(
            itemCount: acts.length,
            itemBuilder: (context, index) {
              final act = acts[index];
              return ListTile(
                title: Text(act['act'] ?? ''),
                subtitle: Text('Severity: ${act['severity']}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to a page where users can add an act of kindness
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddActPage()),
          );
        },
        tooltip: 'Add Act',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 3),
    );
  }
}

// add an act of kindness
class AddActPage extends StatefulWidget {
  const AddActPage({super.key});

  @override
  _AddActPageState createState() => _AddActPageState();
}

class _AddActPageState extends State<AddActPage> {
  String newActText = ''; // Store the text of the new act
  int newActSeverity = 1; // Store the severity of the new act, default to 1

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Act'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                newActText = value;
              },
              decoration: const InputDecoration(
                labelText: 'Enter act',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                newActSeverity = int.tryParse(value) ?? 1;
              },
              decoration: const InputDecoration(
                labelText: 'Enter severity (1-4)',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add the new dare to Firebase
                FirebaseService.addAct(newActText, newActSeverity);
                // Navigate back to the previous page
                Navigator.pop(context);
              },
              child: const Text('Add Act'),
            ),
          ],
        ),
      ),
    );
  }
}

// bottom nav bar used on each page
class BottomNavBar extends StatefulWidget {
  final int selectedIndex;

  const BottomNavBar({super.key, required this.selectedIndex});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
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
        setState(() {
          _selectedIndex = index;
        });
        switch (index) {
          case 0:
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            break;
          case 1:
            Navigator.pushNamedAndRemoveUntil(
                context, '/dares', (route) => false);
            break;
          case 2:
            Navigator.pushNamedAndRemoveUntil(
                context, '/stats', (route) => false);
            break;
          case 3:
            Navigator.pushNamedAndRemoveUntil(context, '/actsOfKindness',
                    (route) => false);
            break;
        }
      },
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
    );
  }
}
