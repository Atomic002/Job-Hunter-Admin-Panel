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
}
