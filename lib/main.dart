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

// variables to use for Note app
var noteList = new List();
final NoteStorage storage = new NoteStorage();
String fileName = "";
String fullFileName = "";
bool newNote = false;

class NoteStorage {
  // get the path where the notes are stored
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    noteList = directory.listSync();
    return directory.path;
  }

  Future<File> get _localFile async {
    // get the full file name path
    final path = await _localPath;
    return new File('$path/$fullFileName.txt');
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
    //write the contents of the notes to the file
    final file = await _localFile;
    // Write the file
    return file.writeAsString('$note');
  }

  Future<File> deleteData() async {
    final file = await _localFile;
    // print("Deleting" + file.path);
    // Write the file
    return file.delete();
  }

  Future<File> renameData(String name) async {
    // rename the file when updating the title or just clicking on an existing note
    final oldFile = await _localFile;
    final newFile = await _localPath;
    // print("Renaming" +
    //     oldFile.toString() +
    //     "to $newFile/$name${DateTime.now().year.toString()}-${DateTime.now().month.toString()}-${DateTime.now().day.toString()}  [" +
    //     "${DateTime.now().hour.toString()}:${DateTime.now().minute.toString().padLeft(2,'0')}.${DateTime.now().second.toString().padLeft(2,'0')}].txt");
    // Rename the file
    return oldFile.rename(
        "$newFile/$name${DateTime.now().year.toString()}-${DateTime.now().month.toString().padLeft(2,'0')}-${DateTime.now().day.toString().padLeft(2,'0')} [" +
            "${DateTime.now().hour.toString().padLeft(2,'0')}:${DateTime.now().minute.toString().padLeft(2,'0')}.${DateTime.now().second.toString().padLeft(2,'0')}].txt");
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
    // reload the list when either renaming, deleting, or adding a note
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
    // load all the notes in the directory into a list
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: const Color.fromARGB(255, 241, 232, 220),
        appBar: new AppBar(
          backgroundColor: Colors.deepPurple,
          title: new Text(DemoLocalizations.of(context).titleNote),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.add),
              // create a new note when pressed
              onPressed: () => _openNotes(
                  DemoLocalizations.of(context).newNote.toString(),'', true),
            )
          ],
        ),
        body: new RefreshIndicator( //pull down to refresh the list in case somehting doesn't update right away
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
    // get the filename and split it into the
    // fullName which includes the date
    // and newName which is just the title
    var t = noteList[i].toString().split('/');
    var noteName = t[t.length - 1];
    var newName = noteName.substring(0, noteName.length - 26);
    var fullName = noteName.substring(0, noteName.length - 5);
    return new Dismissible(
        background: new Opacity(
          child: new Container(color: Colors.red),
          opacity: 0.5,
        ),
        child: new Container(
            height: 75.0,
            decoration: (i + 1) == noteList.length //create a black bottom border unless it is the last item
                ? null
                : const BoxDecoration(
                    border: const Border(
                      bottom: const BorderSide(width: 1.0, color: Colors.black),
                    ),
                  ),
            child: new ListTile(
              title: new Text(newName),
              subtitle: new Text('Last Updated: ' +
                  noteName.substring(
                      noteName.length - 26, noteName.length - 5)),  //show when the note was last opened
              onTap: () {
                _openNotes(newName,fullName, false);
              },
            )),
        key: new ObjectKey(newName),
        onDismissed: (direction) {
          noteList.removeAt(i);
          _prepareDelete(fullName);
          Scaffold.of(context).showSnackBar(new SnackBar(
                content: new Text("$newName ${DemoLocalizations.of(context).deleteNote}"),
                duration: new Duration(milliseconds: 500), //show a snack bar with what was deleted
              ));
        });
  }

  Future _prepareDelete(String name) async {
    // get ready to delete the file by getting the fullpath name with the date
    setState(() {
      fullFileName = name;
    });
    storage.deleteData().then((_) => _reloadData());
  }

  Future _openNotes(String name, String fullName, bool state) async {
    setState(() {
      fileName =
          name; 
      if (state) {  //create a fullFileName if it is a new note
        setState(() {
          fullFileName = name +
          '${DateTime.now().year.toString()}-${DateTime.now().month.toString().padLeft(2,'0')}-${DateTime.now().day.toString().padLeft(2,'0')} [${DateTime.now().hour.toString().padLeft(2,'0')}:${DateTime.now().minute.toString().padLeft(2,'0')}.${DateTime.now().second.toString().padLeft(2,'0')}]';
        });
      } else {  //set the name to the fullFileNme
        fullFileName = fullName;
      }
      newNote = state;
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
    storage.readData().then((String value) { // get the title and contents of the note to display
      setState(() {
        _controller.text = value;
        _controller2.text = fileName;
      });
    }).then((_) => _saveDataStart());
  }

  Future<File> _saveDataStart() async {
    if (newNote) {  // if new note create a filename
      setState(() {
        _controller2.text = fileName;
        });
      // write the variable as a string to the file
      return storage.writeData(result);
    } else {
      return null;
    }
  }

  Future<File> _saveData(bool fullSave) async {
    setState(() {
      if (fullSave) {   //need to rename the file because the name has changed
        fileName = _controller2.text;
        _renameData(fileName).then((_) => _updateFileName());
      }
    });
    // write the variable as a string to the file
    return storage.writeData(result);
  }

  Future<File> _renameData(String name) async {
    return storage.renameData(name);
  }

  Future<File> _updateFileName() async => setState(() {
    // update the file with the updated time after renaming the title
        fileName = _controller2.text;
        fullFileName = fileName + 
            '${DateTime.now().year.toString()}-${DateTime.now().month.toString().padLeft(2,'0')}-${DateTime.now().day.toString().padLeft(2,'0')} [${DateTime.now().hour.toString().padLeft(2,'0')}:${DateTime.now().minute.toString().padLeft(2,'0')}.${DateTime.now().second.toString().padLeft(2,'0')}]';
      });

  Future<Null> _reloadData() async {
    //reload the list so if something has been deleted, added, or renamed
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
      backgroundColor: const Color.fromARGB(255, 241, 232, 220),
      appBar: new AppBar(
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            _saveData(true) // true is passed because the title will need to updated with an updated time (and title if necessary)
                .then((name) => _reloadData())
                .then((value) => Navigator.pop(context));
          },
        ),
        title: new Text(_controller2.text),
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
                  isDense: false,
                ),
                onChanged: (String str) {   // change the fileName if title changed
                  title =
                      str; 
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
                  isDense: false,
                ),
                onChanged: (String str) { //keep writing the contents of the note to the file so no need to manually save
                  result = str;
                  _saveData(false); //do not need to rename the file so false is passed
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
