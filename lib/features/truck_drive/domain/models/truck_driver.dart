class TruckDriver {
  final String uid;
  final String idTruck;
  final String uidUsers;

  TruckDriver({
    required this.uid,
    required this.idTruck,
    required this.uidUsers,
  });

  TruckDriver copyWith({String? uid, String? idTruck, String? uidUsers}) {
    return TruckDriver(
      uid: uid ?? this.uid,
      idTruck: idTruck ?? this.idTruck,
      uidUsers: uidUsers ?? this.uidUsers,
    );
  }
}
