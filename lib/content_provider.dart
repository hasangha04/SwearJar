import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swear_jar/yaml_reader.dart';
import 'package:swear_jar/models.dart';

class DaresProvider extends StatelessWidget {
  final DaresYamlReader reader;
  final Widget child;

  const DaresProvider({super.key, required this.reader, required this.child});

  @override
  Widget build(BuildContext context) {
    final futureQuizzes = reader.readDares('dares.yaml');
    return FutureBuilder(
      future: futureQuizzes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Provider.value(
              value: snapshot.data!,
              child: child,
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Text('Error loading quizzes: ${snapshot.error}');
          }
        }
        return CircularProgressIndicator();
      },
    );
  }
}