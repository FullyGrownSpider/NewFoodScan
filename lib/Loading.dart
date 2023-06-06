import 'dart:io';
import 'package:path_provider/path_provider.dart';

// storeOptions(){
//   var optionsFile = SuperStorage('options');
// }

class SuperStorage {
  final String _fileName;
  static const String _startLine = 'Byrd';
  bool working = false;

  SuperStorage(this._fileName);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName.byd');
  }

  Future<List<String>> readAllData() async {
    await waitTurn();
    working = true;
    var value = await _readAllData();
    working = false;
    return value;
  }

  Future<List<String>> _readAllData() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) return [];
      // Read the file
      var allData = await file.readAsLines();
      allData.removeAt(0);
      return allData;
    } catch (e) {
      // If we encounter an error, return 0
      return [];
    }
  }

  Future<void> _writeStrings(List<String> items) async {
    final file = await _localFile;
    items.insert(0, _startLine);
    await file.writeAsString(items.join('\n'));
  }

  Future<void> addItem(String string) async {
    await waitTurn();
    working = true;
    await _addItem(string);
    working = false;
  }

  Future<void> _addItem(String string) async {
    var values = await _readAllData();
    values.add(string);
    await _writeStrings(values);
  }

  Future<void> update(String newItem, String uniquePart) async {
    await waitTurn();
    working = true;
    await _update(newItem, uniquePart);
    working = false;
  }

  Future<void> _update(String newItem, String uniquePart) async {
    var values = await _readAllData();
    for (int i = 0; i < values.length; i++) {
      if (values[i].contains(uniquePart)) {
        values[i] = newItem;
        await _writeStrings(values);
        return;
      }
    }
    _addItem(newItem);
  }

  Future<void> updateAll(List<String> newItem, List<String> uniquePart) async {
    await waitTurn();
    working = true;
    await _updateAll(newItem, uniquePart);
    working = false;
  }

  Future<void> _updateAll(List<String> newItem, List<String> uniquePart) async {
    var values = await _readAllData();
    for (int i = 0; i < values.length; i++) {
      for (int ii = 0; ii < newItem.length; ii++) {
        if (values[i].contains(uniquePart[ii])) {
          values[i] = newItem[ii];
          break;
        }
      }
    }
    await _writeStrings(values);
  }

  Future<void> delete(String uniquePart) async {
    await waitTurn();
    working = true;
    await _delete(uniquePart);
    working = false;
  }

  Future<void> deleteAll(List<String> uniquePart) async {
    await waitTurn();
    working = true;
    await _deleteAll(uniquePart);
    working = false;
  }

  Future<void> _deleteAll(List<String> uniquePart) async {
    var values = await _readAllData();
    for (int ii = 0; ii < uniquePart.length; ii++) {
      for (int i = 0; i < values.length; i++) {
        if (values[i].contains(uniquePart[ii])) {
          values.removeAt(i);
          break;
        }
      }
    }
    await _writeStrings(values);
  }

  Future<void> _delete(String uniquePart) async {
    var values = await _readAllData();
    for (int i = 0; i < values.length; i++) {
      if (values[i].contains(uniquePart)) {
        values.removeAt(i);
        break;
      }
    }
    await _writeStrings(values);
  }

  Future<void> waitTurn() async {
    while (working) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}