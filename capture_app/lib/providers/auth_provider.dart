import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  User? build() {
    final client = ref.watch(supabaseClientProvider);
    return client.auth.currentUser;
  }

  Future<void> signIn(String email, String password) async {
    final client = ref.read(supabaseClientProvider);
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    state = response.user;
  }

  Future<void> signUp(String email, String password) async {
    final client = ref.read(supabaseClientProvider);
    final response = await client.auth.signUp(
      email: email,
      password: password,
    );
    state = response.user;
  }

  Future<void> signOut() async {
    final client = ref.read(supabaseClientProvider);
    await client.auth.signOut();
    state = null;
  }
}

// Global state to check if user is logged in
@riverpod
bool isLoggedIn(Ref ref) {
  return ref.watch(authNotifierProvider) != null;
}
