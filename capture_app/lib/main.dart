import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'router/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/local_api_service.dart';
import 'providers/theme_provider.dart';


import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  await Supabase.initialize(
    url: 'https://swbcyzmyykswbeifziff.supabase.co',
    anonKey: 'sb_publishable_KFF9ZzCoCO9E8h1qjRYUPw_TIvOPpui',
  );
  
  await Hive.initFlutter();
  await Hive.openBox('spacesBox');
  await Hive.openBox('capturesBox');
  
  final container = ProviderContainer();
  final localApi = LocalApiService(container);
  localApi.start(); // Runs in the background

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch themeProvider to force a rebuild of the entire app when toggled
    ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Capture',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(),
      routerConfig: appRouter,
    );
  }
}
