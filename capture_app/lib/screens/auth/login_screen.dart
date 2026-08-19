import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/constants.dart';
import '../../../providers/auth_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authNotifierProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      // Navigation is handled by auth state listener in main or router
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(kSpacingXl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome back.',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: kDurationNormal).slideY(begin: 0.2),
              SizedBox(height: kSpacingXl),
              
              TextField(
                controller: _emailController,
                decoration: InputDecoration(hintText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              SizedBox(height: kSpacingM),
              
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(hintText: 'Password'),
                obscureText: true,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              SizedBox(height: kSpacingL),

              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: kErrorRed),
                  textAlign: TextAlign.center,
                ).animate().shake(),
                
              SizedBox(height: kSpacingL),
              
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: kAccentOrange))
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentOrange,
                        foregroundColor: kBackgroundDark,
                        padding: EdgeInsets.all(kSpacingM),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusM)),
                      ),
                      child: Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                    
              SizedBox(height: kSpacingM),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SignupScreen()));
                },
                child: Text('Create an account', style: TextStyle(color: kTextSecondary)),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
