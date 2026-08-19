import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/constants.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: Theme.of(context).textTheme.displayMedium),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kAccentViolet,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.person, size: 40, color: kBackgroundDark),
              ),
            ),
            SizedBox(height: kSpacingL),
            Text('User Profile', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: kSpacingS),
            Text('user@example.com', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
