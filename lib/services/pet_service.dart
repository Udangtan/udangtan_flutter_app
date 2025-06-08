import 'package:udangtan_flutter_app/models/pet.dart';
import 'package:udangtan_flutter_app/services/supabase_service.dart';

class PetService {
  static Future<List<Pet>> getAllPets() async {
    try {
      var response = await SupabaseService.client
          .from('pets_with_owners')
          .select()
          .order('created_at', ascending: false);

      return response.map<Pet>((petData) => Pet.fromJson(petData)).toList();
    } catch (error) {
      return [];
    }
  }

  static Future<List<Pet>> getPetsByUser(String userId) async {
    try {
      var response = await SupabaseService.client
          .from('pets')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      return response.map<Pet>((petData) => Pet.fromJson(petData)).toList();
    } catch (error) {
      return [];
    }
  }

  static Future<List<Pet>> getLikedPets(String userId) async {
    try {
      var response = await SupabaseService.client
          .from('pet_likes')
          .select('''
            pet_id,
            pets_with_owners (*)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response
          .where((item) => item['pets_with_owners'] != null)
          .map<Pet>((item) => Pet.fromJson(item['pets_with_owners']))
          .toList();
    } catch (error) {
      return [];
    }
  }

  static Future<Pet?> createPet(Pet pet) async {
    try {
      var response =
          await SupabaseService.client
              .from('pets')
              .insert(pet.toJson())
              .select()
              .single();

      return Pet.fromJson(response);
    } catch (error) {
      return null;
    }
  }

  static Future<bool> likePet(String userId, int petId) async {
    try {
      var existing = await SupabaseService.client
          .from('pet_likes')
          .select()
          .eq('user_id', userId)
          .eq('pet_id', petId);

      if (existing.isNotEmpty) {
        return true;
      }

      await SupabaseService.client.from('pet_likes').insert({
        'user_id': userId,
        'pet_id': petId,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<bool> unlikePet(String userId, int petId) async {
    try {
      await SupabaseService.client
          .from('pet_likes')
          .delete()
          .eq('user_id', userId)
          .eq('pet_id', petId);
      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<bool> isPetLiked(String userId, int petId) async {
    try {
      var response = await SupabaseService.client
          .from('pet_likes')
          .select()
          .eq('user_id', userId)
          .eq('pet_id', petId);

      return response.isNotEmpty;
    } catch (error) {
      return false;
    }
  }

  static Future<List<Pet>> getPetsByLocation(
    String city,
    String? district,
  ) async {
    try {
      var query = SupabaseService.client
          .from('pets_with_owners')
          .select()
          .eq('location_city', city);

      if (district != null) {
        query = query.eq('location_district', district);
      }

      var response = await query.order('created_at', ascending: false);

      return response.map<Pet>((petData) => Pet.fromJson(petData)).toList();
    } catch (error) {
      return [];
    }
  }
}
