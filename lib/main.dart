import 'package:flutter/material.dart';
import 'package:notes/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notes/providers/notes_provider.dart';
import 'package:notes/screens/auth_screen.dart';
import 'package:notes/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoteProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        routes: {
          '/': (context) => AuthScreen(),
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}

