class User {
  final int id;
  final String username;
  final String email;
  final DateTime dateJoined;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.dateJoined,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      dateJoined: json['date_joined'] != null 
          ? DateTime.parse(json['date_joined']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'date_joined': dateJoined.toIso8601String(),
    };
  }
}

class UserProfile {
  final int id;
  final User user;
  final String? fullName;
  final String? phoneNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? zipCode;
  final String? profilePicture;

  UserProfile({
    required this.id,
    required this.user,
    this.fullName,
    this.phoneNumber,
    this.address,
    this.city,
    this.state,
    this.country,
    this.zipCode,
    this.profilePicture,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      user: User.fromJson(json['user']),
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      zipCode: json['zip_code'],
      profilePicture: json['profile_picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'full_name': fullName,
      'phone_number': phoneNumber,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'zip_code': zipCode,
      'profile_picture': profilePicture,
    };
  }

  UserProfile copyWith({
    int? id,
    User? user,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? city,
    String? state,
    String? country,
    String? zipCode,
    String? profilePicture,
  }) {
    return UserProfile(
      id: id ?? this.id,
      user: user ?? this.user,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      zipCode: zipCode ?? this.zipCode,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}