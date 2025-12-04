

import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource{
  Future<UserEntity> signIn({required String email, required String password});
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> signUp({required String email, required String password});
  Future<void> signOut();
  Future<void> resetPassword({required String email});
  Future<void> updatePassword({required String newPassword});
  Future<UserEntity> getUserInfo();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDatasourceImpl implements AuthRemoteDataSource{
  final SupabaseClient supabaseClient;
  AuthRemoteDatasourceImpl(this.supabaseClient);

  Future<UserEntity> mapUserandCreateProfile(User user, String email) async {
    final defaultUsername = email.split('@')[0];
    final userId = user.id;

    try {

      // await Future.delayed(Duration(milliseconds: 100));

      final existingProfile = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();


      if (existingProfile == null) {
        
        try {

          final insertResult = await supabaseClient.from('profiles').insert({
            'id': userId,
            'username': defaultUsername,
            'email': email,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          }).select();
          
          if (insertResult.isEmpty) {
            throw Exception('Profile creation failed - no data returned');
          }
          
        } on PostgrestException catch (e) {
          
          if (e.code == '42501') {
            await _createProfileAlternative(userId, defaultUsername, email);
          } else {
            rethrow;
          }
        }
      }
  // get profile again to ensure we have the latest data
      final finalProfile = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (finalProfile == null) {
        throw Exception('Failed to create or retrieve profile');
      }

      return UserEntity(
        id: userId, 
        email: email,
        username: finalProfile['username'] ?? defaultUsername,
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
      );

    } catch (e) {
      rethrow;
    }
  }

  // Phương thức alternative để tạo profile
  Future<void> _createProfileAlternative(String userId, String username, String email) async {
    try {

      await supabaseClient.rpc('create_user_profile', params: {
        'user_id': userId,
        'user_email': email,
        'user_username': username,
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  @override
  Future<UserEntity> signIn({required String email, required String password}) async {
    try{
      final AuthResponse response = await supabaseClient.auth.signInWithPassword(email: email, password: password);
      if(response.user == null){
        throw Exception("Sign in failed");

      }
      return mapUserandCreateProfile(response.user!, email);
    }on AuthException catch(e){
      throw Exception("Sign in failed: ${e.message}");
    }

  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try{
      await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'fau.socialapp://login-callback',
      );
      return UserEntity(
        id: 'pending-google-auth',
        email: '',
        username: '',
        avatarUrl: null,
        isEmailVerified: false,
      );
    } on AuthException catch (e) {
        throw "Google sign in failed. Please try again. ${e.message}";
    }
  }

  @override
  Future<UserEntity> signUp({required String email, required String password}) async {
    try {
      
      final AuthResponse response = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {'email': email},
        emailRedirectTo: 'fau.socialapp://login-callback',
      );

      if (response.user?.identities == null || response.user!.identities!.isEmpty) {
        throw Exception("Email already registered. Please sign in instead.");
      }

      if (response.user?.identities != null && response.user!.identities!.isNotEmpty) {
        final providers = response.user!.identities!.map((i) => i.provider).toList();
        
        if (providers.contains('google')) {
          throw Exception("Email already registered with Google. Please sign in with Google instead.");
        }
      }

      if (response.user == null) {
        throw Exception("Sign up failed - no user created");
      }

      return UserEntity(
        id: response.user!.id,
        email: email,
        username: email.split('@')[0],
        avatarUrl: null,
        isEmailVerified: response.user?.emailConfirmedAt != null,
      );
      
    } on AuthException catch (e) {

      
      String errorMessage;
      
      if (e.message.contains('already registered') || 
          e.message.contains('user_exists') ||
          e.message.contains('user_already_exists') ||
          e.message.contains('email_already_in_use')) {
        errorMessage = "Email already registered. Please sign in instead.";
      } 
      else if (e.message.contains('invalid_email')) {
        errorMessage = "Invalid email format.";
      }
      else if (e.message.contains('weak_password')) {
        errorMessage = "Password is too weak. Please choose a stronger password.";
      }
      else {
        errorMessage = "Sign up failed: ${e.message}";
      }
      
      throw Exception(errorMessage);
      
    } catch (e) {
      throw Exception("Sign up failed: ${e.toString()}");
    }
  }

  @override
  Future<void> signOut() {
    return supabaseClient.auth.signOut();
  }


  @override
  Future<void> resetPassword({required String email}) async {
    try {

      await supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: 'fau.socialapp://reset-password',
      );
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<void> updatePassword({required String newPassword}) async {
    try{
      final res = await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword)
      );
      if(res.user == null){
         throw Exception('Failed to update password');
      }

    }catch(e){
      throw Exception(e.toString());
    }
  }
  
  @override
Future<UserEntity> getUserInfo() async {
  // BỎ CHECK NULL HOÀN TOÀN - giả định đã có session
  final currentUser = supabaseClient.auth.currentUser!;
  final session = supabaseClient.auth.currentSession; 
  
  final profile = await supabaseClient
    .from('profiles')
    .select()
    .eq('id', currentUser.id)
    .maybeSingle();

  if (profile == null) {
    return await mapUserandCreateProfile(currentUser, currentUser.email ?? '');
  }

  return UserEntity(
    id: currentUser.id,
    email: currentUser.email ?? 'Unknown',
    username: profile['username'] ?? currentUser.email?.split('@')[0] ?? 'Unknown',
    avatarUrl: profile['avatar_url'],
    isEmailVerified: currentUser.emailConfirmedAt != null,
    accessToken: session?.accessToken, // Thêm token
    refreshToken: session?.refreshToken, // Thêm token
  );
}

}