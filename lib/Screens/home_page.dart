import 'dart:async';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Note> _notes = [];
  final TextEditingController _noteController = TextEditingController();

  void _addNote() {
    if (_noteController.text.isNotEmpty) {
      final newNote = Note(
        text: _noteController.text,
        position: const Offset(150, 300),
        direction: _getRandomDirection(), // Get a random direction
      );

      setState(() {
        _notes.add(newNote);
        _noteController.clear();
      });

      // Start the animation
      _startAnimation(newNote);
    }
  }

  void _startAnimation(Note note) {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        // Update the note's position
        note.position = Offset(
          (note.position.dx + note.direction.dx)
              .clamp(0, MediaQuery.of(context).size.width - 50),
          (note.position.dy + note.direction.dy)
              .clamp(0, MediaQuery.of(context).size.height - 50),
        );

        // Check if the note hits the left or right border and reverse direction
        if (note.position.dx <= 0 ||
            note.position.dx >= MediaQuery.of(context).size.width - 50) {
          note.direction = Offset(-note.direction.dx, note.direction.dy);
        }

        // Remove the note after 5 seconds
        if (note.position.dy < 0 ||
            note.position.dy > MediaQuery.of(context).size.height) {
          _notes.remove(note);
          timer.cancel(); // Stop the timer if the note is removed
        }
      });
    });

    // Set a delay for removing the note
    Future.delayed(const Duration(seconds: 10), () {
      if (_notes.contains(note)) {
        setState(() {
          _notes.remove(note); // Remove note after 5 seconds
        });
      }
    });
  }

  // Generate a random direction for the note to move towards
  Offset _getRandomDirection() {
    // Randomly choose one of four directions
    final directions = [
      const Offset(5, 0), // Right
      const Offset(-5, 0), // Left
    ];
    return directions[DateTime.now().microsecond % directions.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/wlcm.gif'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Welcome text (background layer)
            Center(
              child: Text(
                'Welcome to Your Magical Note App!!!🌈🦄',
                style: TextStyle(
                  fontSize: 27,
                  color: Colors.black26.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                  shadows: const [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 3.0,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            ),
            // Display notes with animated positions (foreground layer)
            ..._notes.map((note) {
              return Positioned(
                left: note.position.dx,
                top: note.position.dy,
                child: _buildNoteBubble(note),
              );
            }),
            // Round button to add note
            Positioned(
              bottom: 35,
              child: FloatingActionButton(
                onPressed: () {
                  _showNoteDialog();
                },
                backgroundColor: const Color.fromARGB(
                    255, 197, 27, 107), // Set background color
                child: const Text(
                  '✨', // Magic wand emoji
                  style: TextStyle(
                    fontSize: 30, // Adjust size as needed
                    color: Colors.white, // Set icon color
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteBubble(Note note) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        note.text,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Future<void> _showNoteDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Have Fun with Note'),
          content: TextField(
            controller: _noteController,
            decoration: const InputDecoration(hintText: 'Enter your note here'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addNote();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class Note {
  final String text;
  Offset position; // Current position of the note
  Offset direction; // Direction in which the note will move

  Note({
    required this.text,
    required this.position,
    required this.direction,
  });
}
