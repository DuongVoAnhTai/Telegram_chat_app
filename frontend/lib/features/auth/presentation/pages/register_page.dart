import 'package:frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_button.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_input_filed.dart';
import 'package:frontend/features/auth/presentation/widgets/login_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/theme/theme.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showInputValue() {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    print("Username: $username - Email: $email - Password: $password");
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    BlocProvider.of<AuthBloc>(context).add(
      RegisterEvent(
        username: _usernameController.text,
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
                hint: 'Username',
                icon: Icons.person,
                controller: _usernameController,
              ),
              SizedBox(height: 20),
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
                  return AuthButton(text: 'Register', onPressed: _onRegister);
                },
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    Navigator.pushNamed(context, '/login');
                  } else if (state is AuthFailure) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.error)));
                  }
                },
              ),
              LoginPrompt(
                title: 'Already have an account',
                subtitle: 'Click here to login',
                onTap: () {
                  Navigator.pushNamed(context, '/login');
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
      child: Text('Register', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      heightFactor: 3,
      child: GestureDetector(
        onTap: () {},
        child: RichText(
          text: TextSpan(
            text: 'Already have an account?',
            style: TextStyle(color: Colors.grey),
            children: [
              TextSpan(
                text: 'Click here to login',
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
