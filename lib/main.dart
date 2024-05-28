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
      await FirebaseService.initializeUserData(currentUser);
      return currentUser;
    }

    UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
    User? user = userCredential.user;
    if (user != null) {
      await FirebaseService.initializeUserData(user);
    }
    return user;
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
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
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
  String? _gameId;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final userData = await FirebaseService.getUserJarData();
    if (userData != null) {
      setState(() {
        _counter = userData['counter'] ?? 0;
        _moneyInCents = userData['moneyInCents'] ?? 0;
      });
    }

    // Check if user already has a game ID
    String? gameId = await FirebaseService.getUserGameId();
    setState(() {
      _gameId = gameId;
    });

    if (gameId == null) {
      // Create a new game if no game ID exists
      await FirebaseService.createGame();
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

  void _decrementCounter() async {
    setState(() {
      if (_counter > 0) {
        _counter--;
        if (_counter > 30) {
          _moneyInCents -= 25;
        } else if (_counter > 20) {
          _moneyInCents -= 10;
        } else if (_counter > 10) {
          _moneyInCents -= 5;
        } else {
          _moneyInCents -= 1;
        }
      }
    });

    await FirebaseService.updateUserJarData(_counter, _moneyInCents);
  }

  void _resetCounter() async {
    setState(() {
      _counter = 0;
      _moneyInCents = 0;
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

  void _showDecrementDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Swear'),
          content: const Text('Would you like to remove one swear or reset the jar?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _decrementCounter();
                Navigator.of(context).pop();
              },
              child: const Text('Remove 1'),
            ),
            TextButton(
              onPressed: () {
                _resetCounter();
                Navigator.of(context).pop();
              },
              child: const Text('Reset All'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSetNameDialog() async {
    String displayName = '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Display Name'),
          content: TextField(
            onChanged: (value) {
              displayName = value;
            },
            decoration: InputDecoration(labelText: 'Display Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (displayName.isNotEmpty) {
                  await FirebaseService.updateUserDisplayName(displayName);
                  Navigator.of(context).pop();
                  _showJoinGameDialog(); // Show the next dialog for joining a game
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showJoinGameDialog() async {
    String gameId = '';
    String? currentGameId = await FirebaseService.getUserGameId();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Join Game'),
          content: TextField(
            onChanged: (value) {
              gameId = value;
            },
            decoration: InputDecoration(
              labelText: 'Game ID',
              hintText: 'Enter a Game ID to join',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (gameId.isNotEmpty) {
                  try {
                    await FirebaseService.joinGame(gameId);
                    print('Joined game with ID: $gameId');
                  } catch (e) {
                    print('Failed to join game: $e');
                  }
                }
                Navigator.of(context).pop();
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double moneyInDollars = _moneyInCents / 100.0;

    void _showSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Swear Jar'),
        flexibleSpace: FlexibleSpaceBar(
          title: Text(
            _gameId != null ? 'Game ID: $_gameId' : '',
            style: TextStyle(fontSize: 16),
          ),
          centerTitle: true,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: _showSetNameDialog,
            child: Text('Join Game'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Push the add or subtract button to add or remove money from the swear jar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Text(
                'Money in Jar: \$${moneyInDollars.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Builder(
              builder: (context) {
                return FloatingActionButton(
                  onPressed: _showDecrementDialog,
                  tooltip: 'Remove Swear',
                  child: const Icon(Icons.remove),
                  heroTag: 'removeButton',
                );
              },
            ),
            Builder(
              builder: (context) {
                return FloatingActionButton(
                  onPressed: _incrementCounter,
                  tooltip: 'Add Swear',
                  child: const Icon(Icons.add),
                  heroTag: 'addButton',
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: _selectedIndex),
    );
  }
}

// dares page, shows dares
class DaresPage extends StatelessWidget {
  const DaresPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('dares')
              .where('gameId', isEqualTo: FirebaseService.getUserGameId())
              .snapshots(),
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
                return Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text(dare['dare'] ?? ''),
                    subtitle: Text('Severity: ${dare['severity']}'),
                  ),
                );
              },
            );
          },
        ),
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int _totalSwears = 0;
  int _totalMoney = 0;
  String _displayName = '';

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final userData = await FirebaseService.getUserJarData();
      if (userData != null) {
        setState(() {
          _displayName = userData['displayName'] ?? 'Anonymous';
          _totalSwears = userData['counter'] ?? 0;
          _totalMoney = userData['moneyInCents'] ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: $_displayName',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Total Swears: $_totalSwears',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Total Money: \$${(_totalMoney / 100).toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 2),
    );
  }
}

// acts of kindness page
class ActsOfKindnessPage extends StatelessWidget {
  const ActsOfKindnessPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
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
                return Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text(act['act'] ?? ''),
                    subtitle: Text('Severity: ${act['severity']}'),
                  ),
                );
              },
            );
          },
        ),
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
