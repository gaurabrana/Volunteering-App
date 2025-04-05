class LeaderboardStatistic {
  final String ID;
  final String name;
  final int numHours;
  final String profilePhotoURL;
  int rank;

  LeaderboardStatistic({
    required this.ID,
    required this.name,
    required this.numHours,
    required this.profilePhotoURL,
    required this.rank,
  });
}
