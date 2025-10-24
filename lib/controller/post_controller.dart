import 'package:admin_job/model/post_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminController extends GetxController {
  final supabase = Supabase.instance.client;

  final RxList<Post> pendingPosts = <Post>[].obs;
  final RxList<Post> approvedPosts = <Post>[].obs;
  final RxList<Post> rejectedPosts = <Post>[].obs;
  final RxList<PostApplication> applications = <PostApplication>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
    fetchApplications();
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

  Future<void> approvePost(Post post) async {
    try {
      await supabase
          .from('posts')
          .update({'status': 'approved'})
          .eq('id', post.id);
      await _sendNotification(
        post.userId,
        '✅ E\'lon tasdiqlandi',
        '"${post.title}" e\'loningiz tasdiqlandi',
        'post_approved',
      );
      _showSuccess('Post tasdiqlandi');
      await fetchPosts();
    } catch (e) {
      _showError('Tasdiqlanmadi', e.toString());
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
        '"${post.title}" rad etildi:\n$reason',
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
        '"${post.title}" o\'chirildi',
        'post_deleted',
      );
      _showSuccess('Post o\'chirildi', Colors.red);
      await fetchPosts();
    } catch (e) {
      _showError('O\'chirilmadi', e.toString());
    }
  }

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
          ? '"${app.postTitle}" uchun arizangiz qabul qilindi!'
          : '"${app.postTitle}" uchun arizangiz rad etildi';

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

  Future<void> _sendNotification(
    String userId,
    String title,
    String body,
    String type,
  ) async {
    await supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'is_read': false,
    });
  }

  void _showSuccess(String message, [Color? color]) {
    Get.snackbar(
      'Muvaffaqiyatli',
      message,
      backgroundColor: color ?? Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
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
    );
  }
}
