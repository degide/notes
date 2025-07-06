import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class NoteProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> fetchNotes() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('notes').where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid).get();
      _notes = snapshot.docs.map((doc) => {'id': doc.id, 'text': doc['text']}).toList();
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text('Notes fetched successfully')));
    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text('Failed to fetch notes')));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(String text) async {
    try {
      await _firestore.collection('notes').add({
        'text': text,
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await fetchNotes();
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text('Note added successfully')));
    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text('Failed to add note')));
    }
  }

  Future<void> updateNote(String id, String text) async {
    try {
      await _firestore.collection('notes').doc(id).update({'text': text});
      await fetchNotes();
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text('Note updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text('Failed to update note')));
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _firestore.collection('notes').doc(id).delete();
      await fetchNotes();
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text('Note deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text('Failed to delete note')));
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _notes.clear();
      notifyListeners();
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text('Signed out successfully')));
    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text('Failed to sign out')));
    }
  }
}