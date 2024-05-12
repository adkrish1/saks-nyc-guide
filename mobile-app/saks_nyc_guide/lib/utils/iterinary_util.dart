class Attraction {
  String name;
  String address;
  String phone;
  String rating;
  String categories;
  String price;
  double latitude;
  double longitude;
  Map<String, String> openingHours;

  Attraction({
    required this.name,
    required this.address,
    required this.phone,
    required this.rating,
    required this.categories,
    required this.price,
    required this.latitude,
    required this.longitude,
    required this.openingHours,
  });

  factory Attraction.fromJson(Map<String, dynamic> json) {
    return Attraction(
      name: json['Name'],
      address: json['Address'],
      phone: json['Phone'],
      rating: json['Rating'],
      categories: json['Categories'],
      price: json['price'],
      latitude: json['Latitude'].toDouble(),
      longitude: json['Longitude'].toDouble(),
      openingHours: {
        'Monday': json['Monday'],
        'Tuesday': json['Tuesday'],
        'Wednesday': json['Wednesday'],
        'Thursday': json['Thursday'],
        'Friday': json['Friday'],
        'Saturday': json['Saturday'],
        'Sunday': json['Sunday'],
      },
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'rating': rating,
      'categories': categories,
      'latitude': latitude,
      'longitude': longitude,
      'monday': openingHours['Monday'],
      'tuesday': openingHours['Tuesday'],
      'wednesday': openingHours['Wednesday'],
      'thursday': openingHours['Thursday'],
      'friday': openingHours['Friday'],
      'saturday': openingHours['Saturday'],
      'sunday': openingHours['Sunday'],
    };
  }

}
