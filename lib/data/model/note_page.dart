import 'package:flutter/material.dart';
import 'package:myapp/data/db/db_helper.dart';
import 'dart:math';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _allNotes = [];
  List<Map<String, dynamic>> _filteredNotes = [];
  final Random _random = Random();
  Color _noteColor = Colors.transparent;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  void _fetchNotes() async {
    final notes = await _dbHelper.getNotes();
    setState(() {
      _allNotes = notes;
      _filteredNotes = notes;
    });
  }

  void _filterNotes(String query) {
    final filtered = _allNotes.where((note) {
      final title = note['title'].toLowerCase();
      final content = note['content'].toLowerCase();
      final searchText = query.toLowerCase();
      return title.contains(searchText) || content.contains(searchText);
    }).toList();

    setState(() {
      _filteredNotes = filtered;
    });
  }

  void _createOrUpdateNoteDialog([Map<String, dynamic>? note]) {
    final titleController = TextEditingController(text: note?['title']);
    final contentController = TextEditingController(text: note?['content']);
    String? titleError;
    String? contentError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(note == null ? 'Create Note' : 'Update Note'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: InputBorder.none,
                          hintText: 'Enter note title',
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                          errorText: titleError,
                        ),
                        style: const TextStyle(fontSize: 18),
                        onChanged: (value) {
                          setState(() {
                            titleError = value.trim().isEmpty
                                ? 'Title cannot be empty'
                                : null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: contentController,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        border: const OutlineInputBorder(),
                        hintText: 'Enter note content',
                        errorText: contentError,
                      ),
                      maxLines: 5,
                      onChanged: (value) {
                        setState(() {
                          contentError = value.trim().isEmpty
                              ? 'Content cannot be empty'
                              : null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final content = contentController.text.trim();

                    setState(() {
                      titleError =
                          title.isEmpty ? 'Title cannot be empty' : null;
                      contentError =
                          content.isEmpty ? 'Content cannot be empty' : null;
                    });

                    if (titleError == null && contentError == null) {
                      if (note == null) {
                        await _dbHelper.addNote(title, content);
                      } else {
                        await _dbHelper.updateNote(note['id'], title, content);
                      }
                      _fetchNotes();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(note == null ? 'Save' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _viewNoteDetails(Map<String, dynamic> note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.all(20),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Row(
            children: [
              const Icon(
                Icons.note,
                color: Colors.purple,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  note['title'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              note['content'],
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  label: const Text(
                    'Close',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _deleteNoteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _dbHelper.deleteNote(id);
                _fetchNotes();
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Color _randomColor() {
    return Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    );
  }

  void _transitionNoteColor() {
    setState(() {
      _noteColor = Colors.lightBlue;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _noteColor = Colors.transparent;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                onChanged: (value) => _filterNotes(value),
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
              )
            : const Text("MyNotes"),
        backgroundColor: const Color.fromARGB(255, 146, 30, 117),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _filteredNotes = _allNotes;
                }
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      body: _filteredNotes.isEmpty
          ? const Center(child: Text('No notes found.'))
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = _filteredNotes[index];
                  return GestureDetector(
                    onTap: () => _viewNoteDetails(note), // View note details
                    onDoubleTap: () =>
                        _createOrUpdateNoteDialog(note), // Double-tap to edit
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _noteColor == Colors.transparent
                            ? _randomColor()
                            : _noteColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 6,
                            spreadRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Text(
                              note['content'],
                              style: const TextStyle(
                                fontSize: 14,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () =>
                                      _createOrUpdateNoteDialog(note),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _deleteNoteDialog(note['id']),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 146, 30, 117),
        onPressed: () => _createOrUpdateNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
