class UserModel {
  final String name;
  final String surname;
  final String phone;
  final String profilePic;
  final String address;
  final String uid;

  const UserModel({
    required this.name,
    required this.surname,
    required this.phone,
    required this.profilePic,
    required this.address,
    required this.uid,
  });

  UserModel copyWith({
    String? name,
    String? surname,
    String? phone,
    String? profilePic,
    String? address,
    String? uid,
  }) {
    return UserModel(
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phone: phone ?? this.phone,
      profilePic: profilePic ?? this.profilePic,
      address: address ?? this.address,
      uid: uid ?? this.uid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'phone': phone,
      'profilePic': profilePic,
      'address': address,
      'uid': uid,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String,
      surname: map['surname'] as String,
      phone: map['phone'] as String,
      profilePic: map['profilePic'] as String,
      address: map['address'] as String,
      uid: map['uid'] as String,
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, profilePic: $profilePic, phone: $phone, uid: $uid, address: $address)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          other.name == name &&
          other.profilePic == profilePic &&
          other.surname == surname &&
          other.uid == uid &&
          other.phone == phone &&
          other.address == address;

  @override
  int get hashCode {
    return name.hashCode ^
        profilePic.hashCode ^
        address.hashCode ^
        uid.hashCode ^
        phone.hashCode ^
        surname.hashCode;
  }
}
