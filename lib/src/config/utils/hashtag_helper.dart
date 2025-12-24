class HashtagHelper {
  /// Generates hashtags based on post attach type
  static List<String> getHashtagsFromAttachType(String attachType) {
    final hashtags = <String>[];

    switch (attachType) {
      case 'meal':
        hashtags.addAll(['#Nutrition', '#MealPrep']);
        break;
      case 'challenge':
        hashtags.addAll(['#Challenge', '#Fitness']);
        break;
      case 'medal':
        hashtags.addAll(['#Achievement', '#Milestone']);
        break;
      case 'ingredient':
        hashtags.addAll(['#HealthyEating', '#Nutrition']);
        break;
      default:
        break;
    }

    return hashtags;
  }
}
