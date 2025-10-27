class Post {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String location;
  final String status;
  final int? salaryMin;
  final int? salaryMax;
  final String? salaryType;
  final int viewsCount;
  final int likesCount;
  final DateTime createdAt;
  final String? userName;
  final String? userEmail;
  final String? userPhoto;
  final List<String> images;
  final int applicationsCount;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.location,
    required this.status,
    this.salaryMin,
    this.salaryMax,
    this.salaryType,
    this.viewsCount = 0,
    this.likesCount = 0,
    required this.createdAt,
    this.userName,
    this.userEmail,
    this.userPhoto,
    this.images = const [],
    this.applicationsCount = 0,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['post_images'] != null) {
      images = (json['post_images'] as List)
          .map((img) => img['image_url'].toString())
          .toList();
    }

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
  }
}

class PostApplication {
  final String id;
  final String postId;
  final String userId;
  final String status;
  final String? message;
  final DateTime createdAt;
  final String? userName;
  final String? userEmail;
  final String? userPhoto;
  final String? postTitle;

  PostApplication({
    required this.id,
    required this.postId,
    required this.userId,
    required this.status,
    this.message,
    required this.createdAt,
    this.userName,
    this.userEmail,
    this.userPhoto,
    this.postTitle,
  });

  factory PostApplication.fromJson(Map<String, dynamic> json) {
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
  }
}

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

  factory UserModel.fromJson(Map<String, dynamic> json) {
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
  }
}
