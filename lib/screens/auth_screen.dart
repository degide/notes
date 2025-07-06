import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes/validators/validators.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignup = false;
  bool _isLoading = false;

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (_isSignup) {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      if(context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication failed')),
        );
      }
    } catch (e) {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSignup ? 'Sign Up' : 'Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.emailValidator,
                  onEditingComplete: () {
                    _formKey.currentState?.validate();
                  },
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  obscureText: true,
                  validator: Validators.passwordValidator,
                  onEditingComplete: () {
                    _formKey.currentState?.validate();
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 25, bottom: 14),
                  child:
                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                            onPressed: () => _submit(context),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(_isSignup ? 'Sign Up' : 'Login'),
                          ),
                ),
                TextButton(
                  onPressed: () => setState(() => _isSignup = !_isSignup),
                  child: Text(
                    _isSignup
                        ? 'Already have an account? Login'
                        : 'Need an account? Sign Up',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
