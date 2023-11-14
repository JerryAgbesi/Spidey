import 'dart:io';

void main(List<String> arguments) {
  generateAssetPath();
}

void generateAssetPath() async {
  final String assetPath = 'lib/assets.dart';

  final String pubspecPath = "pubspec.yaml";
  final String pubspecContent = File(pubspecPath).readAsStringSync();

  //find assets in pubspec.yaml
  int assetsStartIndex = pubspecContent.indexOf("assets:");

  if (assetsStartIndex != -1) {
    String assets = pubspecContent.substring(assetsStartIndex + 5);

    int assetsEndIndex = assets.indexOf("\n");

    // if an end index is not found we assume the rest of the file is a list of assets
    if (assetsEndIndex != -1) {
      assetsEndIndex = pubspecContent.length;
    }

    String assetsSection =
        pubspecContent.substring(assetsStartIndex, assetsEndIndex);

    List<String> assetsPaths = assetsSection
        .split("\n")
        .where((line) => line.trim().startsWith("-"))
        .map((line) => line.trim().substring(1).trim())
        .toList();
    final File generatedFile = File(assetPath);

    generatedFile.writeAsStringSync(
        "//THIS IS A GENERATED FILE - DO NOT EDIT BY HAND\n");
    generatedFile.writeAsStringSync("", mode: FileMode.append);

    generatedFile.writeAsStringSync("class Asset{ \n", mode: FileMode.append);
    generatedFile.writeAsStringSync("", mode: FileMode.append);

    for (var path in assetsPaths) {
      final Directory assetDir = Directory(path);

      if (assetDir.existsSync()) {
        final List<FileSystemEntity> dirContent = assetDir.listSync();
        for (var entity in dirContent) {
          if (entity is File) {
            final String fileName = entity.path.split("/").last;
            final String assetName = fileName.split(".").first;
            generatedFile.writeAsStringSync(
                "static const String $assetName = \"${entity.path}\";\n",
                mode: FileMode.append);
          }
        }
      } else {
        print("Directory does not exist");
      }
    }
    generatedFile.writeAsStringSync("}", mode: FileMode.append);
  } else {
    print("assets:not found in pubspec.yaml");
  }
}
