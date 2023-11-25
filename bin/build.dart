import 'dart:io';

void main(List<String> arguments) {
  generateAssetPath();
}

void generateAssetPath() async {
  final String assetPath = 'lib/assets.dart';

  final List<String> pubspecContent = File("pubspec.yaml").readAsLinesSync();

  //find assets in pubspec.yaml
  int assetsStartIndex =
      pubspecContent.indexWhere((line) => line.trim().startsWith("assets:")) +
          1;

  if (assetsStartIndex != -1) {
    //End index is the next ":" after the assets: keyword
    int assetsEndIndex = pubspecContent.indexWhere(
        (line) => line.trim().contains(":"), assetsStartIndex + 1);

    if (assetsEndIndex == -1) {
      assetsEndIndex = pubspecContent.length;
    }

    List assetsSection =
        pubspecContent.sublist(assetsStartIndex, assetsEndIndex - 1);

    List<dynamic> assetsPaths = assetsSection
        .map((item) => item.split("-").last.trim())
        .where((item) => item.isNotEmpty) // Remove empty lines
        .toList();

    final File generatedFile = File(assetPath);

    stdout.writeln("[INFO] Generating assets.dart file");

    generatedFile.writeAsStringSync(
        "//THIS IS A GENERATED FILE - DO NOT EDIT BY HAND\n");
    generatedFile.writeAsStringSync("", mode: FileMode.append);

    generatedFile.writeAsStringSync("class Asset{ \n", mode: FileMode.append);
    generatedFile.writeAsStringSync("Asset._(); \n", mode: FileMode.append);
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

    stdout.writeln("[INFO] Formatting generated file");
    await Process.run("dart", ["format", assetPath]);
  } else {
    stdout.writeln("[ERROR] assets:not found in pubspec.yaml");
  }
}
