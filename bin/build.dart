import 'dart:io';

void main(List<String> arguments) {
  generateAssetPath();
}

void generateAssetPath() async {
  final String assetPath = 'lib/assets.dart';

  final String pubspecContent = File("pubspec.yaml").readAsStringSync();

  //find assets in pubspec.yaml
  int assetsStartIndex = pubspecContent.indexOf("assets:");

  if (assetsStartIndex != -1) {
    int assetsEndIndex = pubspecContent.indexOf("\n", assetsStartIndex);

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
  } else {
    print("assets:not found in pubspec.yaml");
  }

  stdout.writeln("[INFO] Formatting generated file");
  await Process.run("dart", ["format", assetPath]);
}
