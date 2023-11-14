import 'dart:io';

void main(List<String> arguments) {
  generateAssetPath();
}

void generateAssetPath() async {
  final String assetPath = 'lib/assets.dart';
  final Directory assetDir = Directory("assets/");

  final File generatedFile = File(assetPath);

generatedFile
      .writeAsStringSync("//THIS IS A GENERATED FILE - DO NOT EDIT BY HAND\n");
  generatedFile.writeAsStringSync("",mode: FileMode.append);

  generatedFile.writeAsStringSync("class Asset{ \n",mode: FileMode.append);
  generatedFile.writeAsStringSync("",mode: FileMode.append);

  final List<FileSystemEntity> dirContent = assetDir.listSync();

  for (var entity in dirContent) {
    if (entity is File) {
    final String fileName = entity.path.split("/").last;
    final String assetName = fileName.split(".").first;
    generatedFile.writeAsStringSync("static const String $assetName = \"${entity.path}\";\n",mode: FileMode.append);
      
    }
  }
  generatedFile.writeAsStringSync("}",mode: FileMode.append);
}
