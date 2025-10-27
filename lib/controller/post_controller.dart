import 'package:admin_job/model/post_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlatformController extends GetxController {
  final supabase = Supabase.instance.client;

  final RxList<Post> pendingPosts = <Post>[].obs;
  final RxList<Post> approvedPosts = <Post>[].obs;
  final RxList<Post> rejectedPosts = <Post>[].obs;
  final RxList<PostApplication> applications = <PostApplication>[].obs;
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedTab = 0.obs;

  // Statistics
  final RxInt totalUsers = 0.obs;
  final RxInt totalPosts = 0.obs;
  final RxInt totalApplications = 0.obs;
  final RxInt activeUsers = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
    fetchApplications();
    fetchUsers();
    fetchStatistics();
  }

  Future<void> fetchPosts() async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('posts')
          .select('''
          *,
          users!posts_user_id_fkey(username, email, profile_photo_url),
          post_images(image_url)
        ''')
          .order('created_at', ascending: false);

      List<Post> allPosts = (response as List).map((json) {
        List<String> images =
            (json['post_images'] as List?)
                ?.map((img) => img['image_url'].toString())
                .toList() ??
            [];
        return Post(
          id: json['id'],
          userId: json['user_id'],
          title: json['title'],
          description: json['description'],
          location: json['location'],
          status: json['status'],
          salaryMin: json['salary_min'],
          salaryMax: json['salary_max'],
          salaryType: json['salary_type'],
          viewsCount: json['views_count'] ?? 0,
          likesCount: json['likes_count'] ?? 0,
          createdAt: DateTime.parse(json['created_at']),
          userName: json['users']?['username'],
          userEmail: json['users']?['email'],
          userPhoto: json['users']?['profile_photo_url'],
          images: images,
          applicationsCount: 0,
        );
      }).toList();

      pendingPosts.value = allPosts
          .where((p) => p.status == 'pending')
          .toList();
      approvedPosts.value = allPosts
          .where((p) => p.status == 'approved')
          .toList();
      rejectedPosts.value = allPosts
          .where((p) => p.status == 'rejected')
          .toList();
    } catch (e) {
      _showError('Postlarni yuklashda xatolik', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchApplications() async {
    try {
      final response = await supabase
          .from('post_applications')
          .select('''
            *,
            users!post_applications_user_id_fkey(username, email, profile_photo_url),
            posts!post_applications_post_id_fkey(title)
          ''')
          .order('created_at', ascending: false);

      applications.value = (response as List).map((json) {
        return PostApplication(
          id: json['id'],
          postId: json['post_id'],
          userId: json['user_id'],
          status: json['status'],
          message: json['message'],
          createdAt: DateTime.parse(json['created_at']),
          userName: json['users']?['username'],
          userEmail: json['users']?['email'],
          userPhoto: json['users']?['profile_photo_url'],
          postTitle: json['posts']?['title'],
        );
      }).toList();
    } catch (e) {
      print('Arizalar yuklanmadi: $e');
    }
  }

  Future<void> fetchUsers() async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);

      users.value = (response as List).map((json) {
        return UserModel(
          id: json['id'],
          username: json['username'],
          email: json['email'],
          firstName: json['first_name'],
          lastName: json['last_name'],
          bio: json['bio'],
          profilePhotoUrl: json['profile_photo_url'],
          userType: json['user_type'],
          isEmailVerified: json['is_email_verified'] ?? false,
          location: json['location'],
          rating: (json['rating'] ?? 0.0).toDouble(),
          createdAt: DateTime.parse(json['created_at']),
          isActive: json['is_active'] ?? true,
        );
      }).toList();
    } catch (e) {
      _showError('Foydalanuvchilarni yuklashda xatolik', e.toString());
    }
  }

  Future<void> fetchStatistics() async {
    try {
      final usersCount = (await supabase.from('users').select('id')).length;
      final postsCount = (await supabase.from('posts').select('id')).length;
      final appsCount =
          (await supabase.from('post_applications').select('id')).length;
      final activeUsersCount =
          (await supabase.from('users').select('id').eq('is_active', true))
              .length;

      totalUsers.value = usersCount;
      totalPosts.value = postsCount;
      totalApplications.value = appsCount;
      activeUsers.value = activeUsersCount;
    } catch (e) {
      print('Statistika yuklanmadi: $e');
    }
  }

  // Post Actions
  Future<void> approvePost(Post post) async {
    try {
      print(
        'So\'rov boshlandi: ${DateTime.now()} - Updating post ID ${post.id}',
      );
      final response = await supabase
          .from('posts')
          .update({'status': 'approved'})
          .eq('id', post.id);

      print('Javob qaytdi: ${DateTime.now()} - Response: $response');
      if (response == null || response.data == null) {
        _showError('Tasdiqlashda xatolik', 'Serverdan javob olinmadi');
        print('Javob: null yoki ma\'lumot yo\'q');
        return;
      }
      if (response.error != null) {
        _showError('Tasdiqlashda xatolik', response.error!.message);
        print('Xatolik: ${response.error!.message}');
        return;
      }

      final adminId = supabase.auth.currentUser?.id;
      if (adminId != null) {
        await supabase.from('admin_actions').insert({
          'admin_id': adminId,
          'action_type': 'post_approved',
          'target_id': post.id,
          'note': 'Post tasdiqlandi: ${post.title}',
        });
      }

      await _sendNotification(
        post.userId,
        '✅ E\'lon tasdiqlandi',
        '"${post.title}" e\'loningiz tasdiqlandi va endi barchaga ko\'rinadi.',
        'post_approved',
      );
      _showSuccess('Post tasdiqlandi');
      await fetchPosts();
    } catch (e) {
      _showError('Tasdiqlanmadi', e.toString());
      print('Xatolik tafsiloti: ${DateTime.now()} - $e');
    }
  }

  Future<void> rejectPost(Post post, String reason) async {
    try {
      await supabase
          .from('posts')
          .update({'status': 'rejected'})
          .eq('id', post.id);
      await _sendNotification(
        post.userId,
        '❌ E\'lon rad etildi',
        '"${post.title}" e\'loningiz quyidagi sabab bilan rad etildi:\n$reason',
        'post_rejected',
      );
      _showSuccess('Post rad etildi', Colors.orange);
      await fetchPosts();
    } catch (e) {
      _showError('Rad etilmadi', e.toString());
    }
  }

  Future<void> deletePost(Post post) async {
    try {
      await supabase.from('posts').delete().eq('id', post.id);
      await _sendNotification(
        post.userId,
        '🗑️ E\'lon o\'chirildi',
        '"${post.title}" e\'loningiz o\'chirildi.',
        'post_deleted',
      );
      _showSuccess('Post o\'chirildi', Colors.red);
      await fetchPosts();
    } catch (e) {
      _showError('O\'chirilmadi', e.toString());
    }
  }

  // Application Actions
  Future<void> updateApplicationStatus(
    PostApplication app,
    String status,
  ) async {
    try {
      await supabase
          .from('post_applications')
          .update({'status': status})
          .eq('id', app.id);

      String title = status == 'accepted'
          ? '✅ Arizangiz qabul qilindi'
          : '❌ Arizangiz rad etildi';
      String body = status == 'accepted'
          ? '"${app.postTitle}" e\'loni uchun arizangiz qabul qilindi! Ish beruvchi siz bilan bog\'lanadi.'
          : '"${app.postTitle}" e\'loni uchun arizangiz rad etildi.';

      await _sendNotification(app.userId, title, body, 'application_$status');
      _showSuccess(
        'Ariza yangilandi',
        status == 'accepted' ? Colors.green : Colors.orange,
      );
      await fetchApplications();
    } catch (e) {
      _showError('Ariza yangilanmadi', e.toString());
    }
  }

  // User Actions
  Future<void> toggleUserStatus(UserModel user) async {
    try {
      final newStatus = !user.isActive;
      await supabase
          .from('users')
          .update({'is_active': newStatus})
          .eq('id', user.id);
      await _sendNotification(
        user.id,
        newStatus ? '✅ Akkaunt faollashtirildi' : '⚠️ Akkaunt bloklandi',
        newStatus
            ? 'Akkauntingiz qayta faollashtirildi. Endi barcha xizmatlardan foydalanishingiz mumkin.'
            : 'Akkauntingiz vaqtincha bloklandi. Tafsilotlar uchun bog\'laning.',
        newStatus ? 'account_activated' : 'account_blocked',
      );
      _showSuccess(
        newStatus ? 'Foydalanuvchi faollashtirildi' : 'Foydalanuvchi bloklandi',
        newStatus ? Colors.green : Colors.orange,
      );
      await fetchUsers();
    } catch (e) {
      _showError('Xatolik', e.toString());
    }
  }

  Future<void> deleteUser(UserModel user) async {
    try {
      await supabase.from('users').delete().eq('id', user.id);
      _showSuccess('Foydalanuvchi o\'chirildi', Colors.red);
      await fetchUsers();
    } catch (e) {
      _showError('O\'chirilmadi', e.toString());
    }
  }

  Future<void> changeUserType(UserModel user, String newType) async {
    try {
      await supabase
          .from('users')
          .update({'user_type': newType})
          .eq('id', user.id);
      await _sendNotification(
        user.id,
        '🔄 Akkaunt tipi o\'zgartirildi',
        'Akkaunt tipingiz "$newType" ga o\'zgartirildi.',
        'account_type_changed',
      );
      _showSuccess('Foydalanuvchi tipi o\'zgartirildi');
      await fetchUsers();
    } catch (e) {
      _showError('O\'zgartirilmadi', e.toString());
    }
  }

  // Helper Methods
  Future<void> _sendNotification(
    String userId,
    String title,
    String body,
    String type,
  ) async {
    try {
      await supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'is_read': false,
      });
      print('✅ Bildirishnoma yuborildi: $title');
    } catch (e) {
      print('❌ Bildirishnoma yuborishda xato: $e');
    }
  }

  void _showSuccess(String message, [Color? color]) {
    Get.snackbar(
      'Muvaffaqiyatli',
      message,
      backgroundColor: color ?? Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  void refresh() {
    fetchPosts();
    fetchApplications();
    fetchUsers();
    fetchStatistics();
  }
}

// User Model
class UserModel {
  final String id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? profilePhotoUrl;
  final String userType;
  final bool isEmailVerified;
  final String? location;
  final double rating;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.bio,
    this.profilePhotoUrl,
    required this.userType,
    required this.isEmailVerified,
    this.location,
    required this.rating,
    required this.createdAt,
    required this.isActive,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  String get displayName => fullName.isNotEmpty ? fullName : username;
}
