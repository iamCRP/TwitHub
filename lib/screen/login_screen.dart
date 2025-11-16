import 'package:flutter/material.dart';
import 'package:twithub/components/my_button.dart';
import 'package:twithub/components/my_text_field.dart';
import '../services/auth/auth_services.dart';

class LoginScreen extends StatefulWidget {
  final void Function()? onTap;

  const LoginScreen({super.key, this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // text controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (_) =>
            const AlertDialog(title: Text("Please fill in all fields!")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.loginEmailPassword(email, password);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Login Failed"),
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                // logo
                Icon(
                  Icons.lock_open_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: 50),
                //Welcome back msg
                Text(
                  'Welcome back , you\'ve been missed! ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 30),
                //email textField
                MyTextField(
                  controller: emailController,
                  hintText: 'Enter email',
                  obscureText: false,
                ),
                SizedBox(height: 15),
                //password textField
                MyTextField(
                  controller: passwordController,
                  hintText: 'Enter password',
                  obscureText: true,
                ),
                SizedBox(height: 10),
                //forgot password
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    'Forgot Password ?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 35),
                //button
                MyButton(
                  text: 'LOGIN',
                  isLoading: _isLoading,
                  onTap: _isLoading ? null : login,
                ),
                SizedBox(height: 50),
                //not member msg
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Register now',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
