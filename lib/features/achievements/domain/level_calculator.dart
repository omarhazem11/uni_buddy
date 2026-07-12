// Simple flat scheme: 100 points per level. Level 1 spans 0-99 points,
// level 2 spans 100-199, and so on — no diminishing/escalating curve for
// now, easy to tune later without touching callers.
const pointsPerLevel = 100;

int levelForPoints(int totalPoints) => 1 + totalPoints ~/ pointsPerLevel;

/// 0.0-1.0 progress toward the next level.
double levelProgress(int totalPoints) => (totalPoints % pointsPerLevel) / pointsPerLevel;

/// Points still needed to reach the next level.
int pointsToNextLevel(int totalPoints) => pointsPerLevel - (totalPoints % pointsPerLevel);
