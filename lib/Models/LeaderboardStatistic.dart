class LeaderboardStatistic {
  final String ID;
  final String name;
  final int numHours;
  final String profilePhotoURL;
  final String teamId;
  int rank;

  LeaderboardStatistic({
    required this.ID,
    required this.teamId,
    required this.name,
    required this.numHours,
    required this.profilePhotoURL,
    required this.rank,
  });
}
