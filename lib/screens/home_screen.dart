import 'package:flutter/material.dart';
import 'package:notes/providers/notes_provider.dart';
import 'package:notes/validators/validators.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _addNoteController = TextEditingController();
  final TextEditingController _editNoteController = TextEditingController();
  final _editNoteFormKey = GlobalKey<FormState>();
  final _addNoteFormKey = GlobalKey<FormState>();

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add Note'),
            content: Form(
              key: _addNoteFormKey,
              child: TextFormField(
                controller: _addNoteController,
                validator: Validators.noteValidator,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_addNoteFormKey.currentState!.validate()) {
                    Provider.of<NoteProvider>(
                      context,
                      listen: false,
                    ).addNote(_addNoteController.text);
                    _addNoteController.clear();
                    Navigator.pop(context);
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
    );
  }

  void _showEditDialog(BuildContext context, String id, String text) {
    _editNoteController.text = text;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Note'),
            content: Form(
              key: _editNoteFormKey,
              child: TextFormField(
                controller: _editNoteController,
                validator: Validators.noteValidator,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_editNoteFormKey.currentState!.validate()) {
                    Provider.of<NoteProvider>(
                      context,
                      listen: false,
                    ).updateNote(id, _editNoteController.text);
                    _editNoteController.clear();
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetch notes when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NoteProvider>(context, listen: false).fetchNotes();
    });
  }

  @override
  void dispose() {
    _addNoteController.dispose();
    _editNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Notes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Consumer(
            builder: (context, NoteProvider noteProvider, child) {
              return DropdownButton(
                icon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.more_vert, color: Colors.blueAccent),
                ),
                underline: SizedBox(),
                items: [
                  DropdownMenuItem(value: 'refresh', child: Text('Refresh')),
                  DropdownMenuItem(value: 'sign_out', child: Text('Sign Out')),
                ],
                onChanged: (value) {
                  if (value == 'refresh') {
                    noteProvider.fetchNotes();
                  } else if (value == 'sign_out') {
                    noteProvider.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Consumer<NoteProvider>(
            builder: (context, noteProvider, child) {
              if (noteProvider.notes.isEmpty && noteProvider.isLoading) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 100),
                  child: Center(
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  );
                } else if (noteProvider.notes.isEmpty && !noteProvider.isLoading) {
                  return Center(child: Text('Nothing here yet—tap ➕ to add a note.'));
                } else {
                  return ListView.builder(
                    itemCount: noteProvider.notes.length,
                    itemBuilder: (context, index) {
                      final note = noteProvider.notes[index];
                      return ListTile(
                        title: Text(note['text']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed:
                                  () => _showEditDialog(
                                    context,
                                    note['id'],
                                    note['text'],
                                  ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed:
                                  () => noteProvider.deleteNote(note['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}
