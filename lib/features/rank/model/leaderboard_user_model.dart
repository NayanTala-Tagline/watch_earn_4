class LeaderboardUser {
  final String name;
  final String coins;
  final int level;

  const LeaderboardUser(this.name, this.coins, this.level);

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  String get tier {
    if (level >= 10) return 'Expert';
    if (level >= 5) return 'Intermediate';
    return 'Beginner';
  }
}
