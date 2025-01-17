import 'package:nextbigthing/constants/globals/globals.dart';
import 'package:nextbigthing/constants/globals/paths/tileMaps.dart';

enum LevelOption {

  level1('world_1_1_map.tmx', '1-1');

  const LevelOption(this.pathName, this.name);
  final String pathName;
  final String name;
}