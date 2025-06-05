import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _usernameCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _loggingIn = false;
  bool _registering = false;
  final _auth = AuthService();

  Future<void> _handleLogin() async {
    setState(() => _loggingIn = true);
    final success = await _auth.login(_usernameCtl.text, _passwordCtl.text);
    setState(() => _loggingIn = false);
    if (success) {
      Navigator.pushReplacementNamed(context, '/games');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
    }
  }

  Future<void> _handleRegister() async {
    setState(() => _registering = true);
    final success = await _auth.register(_usernameCtl.text, _passwordCtl.text);
    setState(() => _registering = false);
    if (success) {
      Navigator.pushReplacementNamed(context, '/games');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameCtl,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtl,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _loggingIn ? null : _handleLogin,
                  child: _loggingIn
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
                ElevatedButton(
                  onPressed: _registering ? null : _handleRegister,
                  child: _registering
                      ? const CircularProgressIndicator()
                      : const Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
