enum AchievementCategory { quiz, spin, checkIn, streak, coins, scratch, webVisit }

class AchievementDef {
  const AchievementDef({
    required this.id,
    required this.title,
    required this.description,
    required this.goal,
    required this.reward,
    required this.category,
  });

  final String id;
  final String title;
  final String description;
  final int goal;

  /// Coins awarded when the achievement is claimed.
  final int reward;

  final AchievementCategory category;

  static const List<AchievementDef> all = [
    // ── Quiz ──────────────────────────────────────────────────────────────────
    AchievementDef(
      id: 'quiz_novice',
      title: 'Quiz Novice',
      description: 'Complete 5 Quizzes',
      goal: 5,
      reward: 5,
      category: AchievementCategory.quiz,
    ),
    AchievementDef(
      id: 'quiz_master',
      title: 'Quiz Master',
      description: 'Complete 25 Quizzes',
      goal: 25,
      reward: 20,
      category: AchievementCategory.quiz,
    ),
    // ── Spin ──────────────────────────────────────────────────────────────────
    AchievementDef(
      id: 'spin_starter',
      title: 'Spin Starter',
      description: 'Spin the Wheel 3 Times',
      goal: 3,
      reward: 5,
      category: AchievementCategory.spin,
    ),
    AchievementDef(
      id: 'spin_legend',
      title: 'Spin Legend',
      description: 'Spin the Wheel 20 Times',
      goal: 20,
      reward: 25,
      category: AchievementCategory.spin,
    ),
    // ── Daily check-in ────────────────────────────────────────────────────────
    AchievementDef(
      id: 'daily_devotee',
      title: 'Daily Devotee',
      description: 'Check In for 5 Days',
      goal: 5,
      reward: 10,
      category: AchievementCategory.checkIn,
    ),
    AchievementDef(
      id: 'habit_master',
      title: 'Habit Master',
      description: 'Check In for 30 Days',
      goal: 30,
      reward: 50,
      category: AchievementCategory.checkIn,
    ),
    // ── Streak ────────────────────────────────────────────────────────────────
    AchievementDef(
      id: 'streak_seeker',
      title: 'Streak Seeker',
      description: 'Maintain a 3-Day Streak',
      goal: 3,
      reward: 10,
      category: AchievementCategory.streak,
    ),
    AchievementDef(
      id: 'streak_king',
      title: 'Streak King',
      description: 'Maintain a 7-Day Streak',
      goal: 7,
      reward: 30,
      category: AchievementCategory.streak,
    ),
    // ── Coins ─────────────────────────────────────────────────────────────────
    AchievementDef(
      id: 'coin_collector',
      title: 'Coin Collector',
      description: 'Earn 100 Coins',
      goal: 100,
      reward: 10,
      category: AchievementCategory.coins,
    ),
    AchievementDef(
      id: 'coin_hoarder',
      title: 'Coin Hoarder',
      description: 'Earn 500 Coins',
      goal: 500,
      reward: 30,
      category: AchievementCategory.coins,
    ),
    // ── Scratch card ──────────────────────────────────────────────────────────
    AchievementDef(
      id: 'scratch_novice',
      title: 'Scratch Novice',
      description: 'Scratch 3 Cards',
      goal: 3,
      reward: 5,
      category: AchievementCategory.scratch,
    ),
    AchievementDef(
      id: 'scratch_pro',
      title: 'Scratch Pro',
      description: 'Scratch 10 Cards',
      goal: 10,
      reward: 20,
      category: AchievementCategory.scratch,
    ),
    // ── Web visits ────────────────────────────────────────────────────────────
    AchievementDef(
      id: 'web_explorer',
      title: 'Web Explorer',
      description: 'Visit 3 Websites',
      goal: 3,
      reward: 5,
      category: AchievementCategory.webVisit,
    ),
    AchievementDef(
      id: 'web_warrior',
      title: 'Web Warrior',
      description: 'Visit 10 Websites',
      goal: 10,
      reward: 15,
      category: AchievementCategory.webVisit,
    ),
  ];
}
