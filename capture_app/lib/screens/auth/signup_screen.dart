import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/constants.dart';
import '../../../providers/auth_provider.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authNotifierProvider.notifier).signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      // Navigation handled by auth listener
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
                'Join Capture.',
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
                      onPressed: _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentOrange,
                        foregroundColor: kBackgroundDark,
                        padding: EdgeInsets.all(kSpacingM),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusM)),
                      ),
                      child: Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                    
              SizedBox(height: kSpacingM),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                },
                child: Text('Already have an account?', style: TextStyle(color: kTextSecondary)),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
