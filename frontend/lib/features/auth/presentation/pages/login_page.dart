import 'package:frontend/features/auth/presentation/widgets/auth_button.dart';
import 'package:frontend/features/auth/presentation/widgets/login_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/theme/theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_input_filed.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showInputValue() {
    String email = _emailController.text;
    String password = _passwordController.text;

    print("Email: $email - Password: $password");
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    BlocProvider.of<AuthBloc>(context).add(
      LoginEvent(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthInputFiled(
                hint: 'Email',
                icon: Icons.email,
                controller: _emailController,
              ),
              SizedBox(height: 20),
              AuthInputFiled(
                hint: 'Password',
                icon: Icons.password,
                controller: _passwordController,
                isPassword: true,
              ),
              SizedBox(height: 20),
              BlocConsumer<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return AuthButton(text: 'Login', onPressed: _onLogin);
                },
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  } else if (state is AuthFailure) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.error)));
                  }
                },
              ),
              LoginPrompt(
                title: 'Don\'t have an account?',
                subtitle: 'Click here to register',
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.sentMessageInput,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _showInputValue,
      style: ElevatedButton.styleFrom(
        backgroundColor: DefaultColors.buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
      child: Text('Login', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      heightFactor: 3,
      child: GestureDetector(
        onTap: () {},
        child: RichText(
          text: TextSpan(
            text: 'Don\'t have an account?',
            style: TextStyle(color: Colors.grey),
            children: [
              TextSpan(
                text: ' Click here to register',
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
