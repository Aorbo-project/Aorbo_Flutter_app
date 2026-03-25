class TrekModel {
  final String title;
  final String subtitle;
  final String price;
  final String duration;
  final String departureDate;
  final double rating;
  final int slotsLeft;
  final bool hasDiscount;
  final String discountText;
  final List<DayItinerary> itinerary;
  final List<String> trekRoute;
  final List<String> activities;
  final List<Review> reviews;
  final List<Resort> resorts;
  final List<String> inclusions;
  final List<String> exclusions;

  TrekModel({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.duration,
    required this.departureDate,
    required this.rating,
    required this.slotsLeft,
    this.hasDiscount = false,
    this.discountText = '',
    required this.itinerary,
    required this.trekRoute,
    required this.activities,
    required this.reviews,
    required this.resorts,
    required this.inclusions,
    required this.exclusions,
  });

  static List<TrekModel> getTrekData() {
    return [
      TrekModel(
        title: 'Magical Manali',
        subtitle: 'Trekking Freaks limited',
        price: '5,999',
        duration: '5 Days / 4 Nights',
        departureDate: '22/12/2024',
        rating: 4.2,
        slotsLeft: 10,
        hasDiscount: true,
        discountText: 'Extra 10% OFF',
        itinerary: [
          DayItinerary(
            day: 1,
            title: 'Arrival and Acclimatization',
            description:
                'Arrive in Manali, check-in to hotel, briefing session, local sightseeing, and equipment distribution.',
            activities: [
              'Hotel Check-in',
              'Trek Briefing',
              'Local Sightseeing',
              'Equipment Distribution'
            ],
          ),
          DayItinerary(
            day: 2,
            title: 'Trek to Base Camp',
            description:
                'Drive to Gulaba, start trek to first base camp through beautiful meadows and forests.',
            activities: [
              'Drive to Gulaba',
              'Trek Start',
              'Lunch Break',
              'Camp Setup'
            ],
          ),
          DayItinerary(
            day: 3,
            title: 'Summit Attempt',
            description:
                'Early morning start for summit, reach peak by afternoon, return to base camp.',
            activities: ['Summit Trek', 'Peak Photography', 'Return Trek'],
          ),
          DayItinerary(
            day: 4,
            title: 'Return Trek',
            description:
                'Trek back to Gulaba, drive to Manali, evening free for rest.',
            activities: ['Return Trek', 'Drive to Manali', 'Rest & Relaxation'],
          ),
          DayItinerary(
            day: 5,
            title: 'Departure',
            description: 'After breakfast, departure for onward journey.',
            activities: ['Breakfast', 'Departure'],
          ),
        ],
        trekRoute: [
          'Manali → Gulaba',
          'Gulaba → Base Camp',
          'Base Camp → Summit → Base Camp',
          'Base Camp → Gulaba → Manali',
        ],
        activities: [
          'Mountain Climbing',
          'Photography',
          'Camping',
          'Star Gazing',
          'Wildlife Spotting',
        ],
        reviews: [
          Review(
            userName: 'John Doe',
            rating: 4.5,
            comment: 'Amazing experience with great guides!',
            date: '15/03/2024',
          ),
          Review(
            userName: 'Jane Smith',
            rating: 4.0,
            comment: 'Beautiful trek but quite challenging.',
            date: '10/03/2024',
          ),
        ],
        resorts: [
          Resort(
            name: 'Mountain View Camp',
            location: 'Base Camp',
            amenities: ['Heated Tents', 'Hot Meals', 'Basic Washrooms'],
          ),
          Resort(
            name: 'Manali Guest House',
            location: 'Manali',
            amenities: ['Wi-Fi', 'Hot Water', 'Restaurant'],
          ),
        ],
        inclusions: [
          'Professional Trek Leader',
          'Camping Equipment',
          'Meals during trek',
          'First Aid Kit',
          'Permits and Fees',
          'Transportation from Manali',
        ],
        exclusions: [
          'Personal Equipment',
          'Travel Insurance',
          'Tips and Gratuities',
          'Personal Expenses',
          'Emergency Evacuation',
        ],
      ),
      TrekModel(
        title: 'Gokarna and Dandeli',
        subtitle: 'Haunting voyages',
        price: '4,999',
        duration: '4 Days / 3 Nights',
        departureDate: '25/12/2024',
        rating: 3.5,
        slotsLeft: 5,
        hasDiscount: true,
        discountText: 'Extra 15% OFF',
        itinerary: [
          DayItinerary(
            day: 1,
            title: 'Arrival in Gokarna',
            description: 'Beach exploration and local sightseeing',
            activities: ['Beach Visit', 'Temple Tour'],
          ),
        ],
        trekRoute: ['Gokarna → Dandeli'],
        activities: ['Beach Trekking', 'Water Sports'],
        reviews: [],
        resorts: [],
        inclusions: ['Guide', 'Transport'],
        exclusions: ['Personal Expenses'],
      ),
      TrekModel(
        title: 'Kashmir Great Lakes',
        subtitle: 'Mountain Adventures',
        price: '8,999',
        duration: '7 Days / 6 Nights',
        departureDate: '28/12/2024',
        rating: 4.8,
        slotsLeft: 3,
        hasDiscount: false,
        itinerary: [],
        trekRoute: ['Srinagar → Lakes'],
        activities: ['Lake Trekking'],
        reviews: [],
        resorts: [],
        inclusions: ['Guide'],
        exclusions: ['Meals'],
      ),
      TrekModel(
        title: 'Hampta Pass',
        subtitle: 'Highland Expeditions',
        price: '6,999',
        duration: '6 Days / 5 Nights',
        departureDate: '01/01/2025',
        rating: 2.8,
        slotsLeft: 8,
        hasDiscount: true,
        discountText: 'Extra 20% OFF',
        itinerary: [],
        trekRoute: ['Manali → Hampta'],
        activities: ['High Altitude Trek'],
        reviews: [],
        resorts: [],
        inclusions: ['Equipment'],
        exclusions: ['Transport'],
      ),
    ];
  }
}

class DayItinerary {
  final int day;
  final String title;
  final String description;
  final List<String> activities;

  DayItinerary({
    required this.day,
    required this.title,
    required this.description,
    required this.activities,
  });
}

class Review {
  final String userName;
  final double rating;
  final String comment;
  final String date;

  Review({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class Resort {
  final String name;
  final String location;
  final List<String> amenities;

  Resort({
    required this.name,
    required this.location,
    required this.amenities,
  });
}
