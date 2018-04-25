/*-----------------------------------------------


Simple note app that keeps track of your notes
can add, delete and rename the notes

Adding multilangauge Support


-----------------------------------------------*/
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';

import 'Localizations.dart';

void main() {
  runApp(
    new MaterialApp(
      onGenerateTitle: (BuildContext context) =>
          DemoLocalizations.of(context).titleNote,
      localizationsDelegates: [
        const DemoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('es', ''),
      ],
      home: new Notes(),
    ),
  );
}

var noteList = new List();

final NoteStorage storage = new NoteStorage();
String fileName = "";

class NoteStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    noteList = directory.listSync();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return new File('$path/$fileName.txt');
  }

  Future<String> readData() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      // If we encounter an error, return ''
      return '';
    }
  }

  Future<File> writeData(String note) async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString('$note');
  }

  Future<File> deleteData() async {
    final file = await _localFile;
    print("Deleting" + file.path);
    print("Old ${noteList.length}");
    // Write the file
    return file.delete();
  }

  Future<File> renameData(String name) async {
    final oldFile = await _localFile;
    final newFile = await _localPath;
    print("Renaming" + oldFile.toString() + " to $newFile/$name.txt");
    // Write the file
    return oldFile.rename("$newFile/$name.txt");
  }
  
}

class Notes extends StatefulWidget {
  Notes({Key key}) : super(key: key);

  @override
  _NotesState createState() => new _NotesState();
}

class _NotesState extends State<Notes> {
  _loadData() async {
    final directory = await getApplicationDocumentsDirectory();
    var temp = directory.listSync();
    temp.sort((a, b) =>
        a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
    setState(() {
      noteList = temp;
    });
  }

  Future<Null> _reloadData() async {
    final directory = await getApplicationDocumentsDirectory();
    var temp = directory.listSync();
    temp.sort((a, b) =>
        a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
    setState(() {
      noteList = temp;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.yellow[100],
        appBar: new AppBar(
          title: new Text(DemoLocalizations.of(context).titleNote),
          // title: new Text('Notes'),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.add),
              // onPressed: () => _openNotes("New Note"),
              onPressed: () =>
                  _openNotes(DemoLocalizations.of(context).newNote.toString()),
            )
          ],
        ),
        body: new RefreshIndicator(
          child:
              // body:
              new ListView.builder(
            itemCount: noteList.length,
            itemBuilder: (BuildContext context, int pos) {
              return _buildRow(pos, context);
            },
          ),
          onRefresh: _reloadData,
        ));
  }

  Widget _buildRow(int i, BuildContext context) {
    var t = noteList[i].toString().split('/');
    var noteName = t[t.length - 1];
    var newName = noteName.substring(0, noteName.length - 5);
    return new Dismissible(
        background: new Opacity(
          child: new Container(color: Colors.red),
          opacity: 0.5,
        ),
        child: new Container(
            height: 75.0,
            decoration: (i + 1) == noteList.length
                ? null
                : const BoxDecoration(
                    border: const Border(
                      bottom: const BorderSide(width: 1.0, color: Colors.black),
                    ),
                  ),
            child: new ListTile(
              title: new Text(newName),
              onTap: () {
                _openNotes(newName);
              },
            )),
        key: new Key(newName),
        onDismissed: (direction) {
          noteList.removeAt(i);
          _prepareDelete(newName);
          Scaffold.of(context).showSnackBar(
              new SnackBar(content: new Text("$newName was deleted"),));
        });
  }

  Future _prepareDelete(String name) async {
    setState(() {
      fileName = name;
    });
    storage.deleteData().then((_) => _reloadData());
  }

  Future _openNotes(String name) async {
    setState(() {
      fileName = name;
    });
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new NotesDemo()),
    );
  }
}

class NotesDemo extends StatefulWidget {
  NotesDemo({Key key}) : super(key: key);

  @override
  _NotesDemoState createState() => new _NotesDemoState();
}

class _NotesDemoState extends State<NotesDemo> {
  TextEditingController _controller = new TextEditingController();
  TextEditingController _controller2 = new TextEditingController();
  String result = "";
  String title = "";

  @override
  void initState() {
    super.initState();
      storage.readData().then((String value) {
        setState(() {
          _controller.text = value;
          _controller2.text = fileName;
        });
      }).then((_) => _saveDataStart());
    // }
  }

  Future<File> _saveDataStart() async {
    if (fileName == DemoLocalizations.of(context).newNote.toString()) {
      setState(() {
      _controller2.text = fileName;
    });
    // write the variable as a string to the file
    return storage.writeData(result);
    } else {
      return null;
    }
  }

  Future<File> _saveData() async {
    setState(() {
      // if (_controller2.text == "New Note") {
      if (_controller2.text == DemoLocalizations.of(context).newNote) {
        _renameData(
            "${DemoLocalizations.of(context).newNote} ${DateTime.now().year.toString()}-${DateTime.now().month.toString()}-${DateTime.now().day.toString()}  [" +
                "${DateTime.now().hour.toString()}:${DateTime.now().minute.toString().padLeft(2,'0')}.${DateTime.now().second.toString().padLeft(2,'0')}]");
        _controller2.text = fileName;
      } else {
        fileName = _controller2.text;
      }
    });
    // write the variable as a string to the file
    return storage.writeData(result);
  }

  Future<File> _renameData(String name) async {
    return storage.renameData(name);
  }

  Future<File> _updateFileName() async => setState(() {
        fileName = _controller2.text;
      });

  Future<Null> _reloadData() async {
    final directory = await getApplicationDocumentsDirectory();
    var temp = directory.listSync();
    temp.sort((a, b) =>
        a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
    setState(() {
      noteList = temp;
    });
  }

  FocusNode _myNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            if (_controller2.text == '') {
              _renameData(
                  "${DemoLocalizations.of(context).untitledNote} ${DateTime.now().year.toString()}-${DateTime.now().month.toString()}-${DateTime.now().day.toString()} [" +
                      "${DateTime.now().hour.toString()}.${DateTime.now().minute.toString().padLeft(2,'0')}.${DateTime.now().second.toString().padLeft(2,'0')}]");
            }
            _saveData()
                .then((name) => _reloadData())
                .then((value) => Navigator.pop(context));
          },
        ),
        title: new Text('$fileName'),
      ),
      body: new GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Container(
          margin: const EdgeInsets.all(10.0),
          child: ListView(
            children: <Widget>[
              new TextField(
                textAlign: TextAlign.center,
                controller: _controller2,
                autocorrect: false,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  hintText: DemoLocalizations.of(context).noteTitle,
                  // hintText: "Title",
                  isDense: false,
                ),
                onChanged: (String str) {
                  title = str;
                  _renameData(title).then((_) => _updateFileName());
                },
              ),
              new TextField(
                focusNode: _myNode,
                controller: _controller,
                maxLines: null,
                autocorrect: false,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  hintText: DemoLocalizations.of(context).hintTextNote,
                  // hintText: "Type Your Notes Here",
                  isDense: false,
                ),
                onChanged: (String str) {
                  result = str;
                  _saveData();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}