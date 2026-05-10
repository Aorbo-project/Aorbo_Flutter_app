class City {
  final String name;
  final bool isPopular;

  City({
    required this.name,
    this.isPopular = false,
  });
}

// Sample data
final List<City> popularCities = [
  City(name: 'Hyderabad', isPopular: true),
  City(name: 'Bangalore', isPopular: true),
  City(name: 'Vijayawada', isPopular: true),
  City(name: 'Chennai', isPopular: true),
  City(name: 'Mumbai', isPopular: true),
  City(name: 'Delhi', isPopular: true),
  City(name: 'Kolkata', isPopular: true),
];

final List<City> allCities = [
  ...popularCities,
  City(name: 'Pune'),
  City(name: 'Ahmedabad'),
  City(name: 'Jaipur'),
  City(name: 'Lucknow'),
  City(name: 'Kanpur'),
  City(name: 'Nagpur'),
  City(name: 'Indore'),
  City(name: 'Rajkot'),
  City(name: 'Surat'),
  City(name: 'Bhopal'),
  City(name: 'Thane'),
  City(name: 'Navsari'),
  City(name: 'Kerala'),
  City(name: 'Goa'),
  // Add more cities as needed
];
