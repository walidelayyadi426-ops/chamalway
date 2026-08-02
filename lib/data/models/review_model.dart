class ReviewModel {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String date;
  final String comment;

  const ReviewModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.date,
    required this.comment,
  });
}
