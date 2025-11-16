import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../components/my_text_field.dart';
import '../services/auth/auth_services.dart';

class RegisterScreen extends StatefulWidget {
  final void Function()? onTap;

  const RegisterScreen({super.key, this.onTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //text controller
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = cPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (_) =>
            const AlertDialog(title: Text("Please fill all fields!")),
      );
      return;
    }

    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (_) =>
            const AlertDialog(title: Text("Passwords do not match!")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.registerEmailPassword(name, email, password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Registration Failed"),
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
                  "Let's create an account for you",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 30),
                //name textField
                MyTextField(
                  controller: nameController,
                  hintText: 'Enter name',
                  obscureText: false,
                ),
                SizedBox(height: 15),
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
                SizedBox(height: 15),
                //confirm password textField
                MyTextField(
                  controller: cPasswordController,
                  hintText: 'Confirm password',
                  obscureText: true,
                ),
                SizedBox(height: 35),
                //button
                MyButton(
                  text: 'REGISTER',
                  isLoading: _isLoading,
                  onTap: _isLoading ? null : register,
                ),
                SizedBox(height: 50),
                //Already a member msg
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Login now',
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
