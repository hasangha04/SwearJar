import 'package:swear_jar/main.dart';
import 'package:yaml/yaml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:swear_jar/Models.dart';

class DaresYamlReader {
  Future<List<Dare>> readDares (String fileName) async {
    String fileContents = await rootBundle.loadString(fileName);
    YamlList data = loadYaml(fileContents);
    List<Dare> daresList = [];

    for (var daresData in data) {
      var dare = daresData['dare'];
      var severity = daresData['severity'];

      Dare dares = Dare(
        dare: dare,
        severity: severity,
      );

      daresList.add(dares);
    }

    return daresList;
  }
}

class ActsYamlReader {
  Future<List<ActOfKindness>> readActs (String fileName) async {
    String fileContents = await rootBundle.loadString(fileName);
    YamlList data = loadYaml(fileContents);
    List<ActOfKindness> ActsList = [];

    for (var actsData in data) {
      var act = actsData['act'];
      var severity = actsData['severity'];

      ActOfKindness acts = ActOfKindness(
        act: act,
        severity: severity,
      );

      ActsList.add(acts);
    }

    return ActsList;
  }
}

