import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:udangtan_flutter_app/app/env_config.dart';
import 'package:udangtan_flutter_app/models/user.dart' as app_user;

class SupabaseService {
  static late SupabaseClient client;

  static Future<void> initialize() async {
    try {
      var url = EnvConfig.supabaseUrl;
      var anonKey = EnvConfig.supabaseAnonKey;

      if (url.isEmpty || anonKey.isEmpty) {
        throw Exception('Supabase URL or ANON KEY is not configured');
      }

      await Supabase.initialize(url: url, anonKey: anonKey, debug: false);

      client = Supabase.instance.client;
    } catch (e) {
      rethrow;
    }
  }

  static Future<app_user.User?> createOrUpdateUser(app_user.User user) async {
    try {
      var userData = {
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'profile_image_url': user.profileImageUrl,
        'provider': user.provider,
        'updated_at': DateTime.now().toIso8601String(),
      };
      var response =
          await client.from('users').upsert(userData).select().single();

      return app_user.User(
        id: response['id'],
        email: response['email'] ?? '',
        name: response['name'] ?? '',
        profileImageUrl: response['profile_image_url'] ?? '',
        provider: response['provider'] ?? '',
      );
    } catch (error) {
      return null;
    }
  }

  static Future<app_user.User?> getUserById(String userId) async {
    try {
      var response =
          await client.from('users').select().eq('id', userId).single();

      return app_user.User(
        id: response['id'],
        email: response['email'] ?? '',
        name: response['name'] ?? '',
        profileImageUrl: response['profile_image_url'] ?? '',
        provider: response['provider'] ?? '',
      );
    } catch (error) {
      return null;
    }
  }

  static Future<List<app_user.User>> getAllUsers() async {
    try {
      var response = await client
          .from('users')
          .select()
          .order('updated_at', ascending: false);

      return response.map<app_user.User>((user) {
        return app_user.User(
          id: user['id'],
          email: user['email'] ?? '',
          name: user['name'] ?? '',
          profileImageUrl: user['profile_image_url'] ?? '',
          provider: user['provider'] ?? '',
        );
      }).toList();
    } catch (error) {
      return [];
    }
  }

  static Future<bool> deleteUser(String userId) async {
    try {
      await client.from('users').delete().eq('id', userId);
      return true;
    } catch (error) {
      return false;
    }
  }
}
