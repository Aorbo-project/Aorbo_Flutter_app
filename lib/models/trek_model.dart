import 'package:arobo_app/utils/common_images.dart';

class BoardingPoint {
  final String location;
  final String time;
  final String date;
  final String transport;

  BoardingPoint({
    required this.location,
    required this.time,
    required this.date,
    required this.transport,
  });
}

class TrekRouteStop {
  final String time; // e.g., '03:50 PM'
  final String date; // e.g., '22/12'
  final String location; // e.g., 'Nampally railway station'
  final String transport; // e.g., 'Train'

  TrekRouteStop({
    required this.time,
    required this.date,
    required this.location,
    required this.transport,
  });
}

class CancellationTimeWindow {
  final String beforeDeparture;
  final String deduction;
  final int? deductionAmount;

  CancellationTimeWindow({
    required this.beforeDeparture,
    required this.deduction,
    this.deductionAmount,
  });
}

class CancellationPolicy {
  final List<CancellationTimeWindow> timeWindows;
  final String baseFare;
  final String startDate;
  final String startTime;
  final List<String> notes;

  CancellationPolicy({
    required this.timeWindows,
    required this.baseFare,
    required this.startDate,
    required this.startTime,
    required this.notes,
  });
}

class OtherPolicy {
  final String title;
  final String description;
  final String iconName; // We'll use this to determine which icon to show

  OtherPolicy({
    required this.title,
    required this.description,
    required this.iconName,
  });
}

class Booking {
  final String trekName;
  final String subtitle;
  final String pnrId;
  final String duration;
  final String departureDate;
  final String status; // e.g., 'Upcoming', 'Complete', 'Cancelled'
  final String organiserName;
  final String endLocation;
  final int slots;
  final String description;
  final int number;

  Booking(
      {required this.trekName,
      required this.subtitle,
      required this.pnrId,
      required this.duration,
      required this.departureDate,
      required this.status,
      required this.organiserName,
      required this.endLocation,
      required this.slots,
      required this.description,
      required this.number});
}

class Trek {
  final String name;
  final bool isPopular;
  final String subtitle;
  final String imagePath;
  final String price;
  final bool hasDiscount;
  final String discountText;
  final String duration;
  final double rating;
  final int numberOfRatings;
  final int numberOfReviews;
  final Map<String, double>
      peopleLikeRatings; // Categories people like with ratings
  final String departureDate;
  final int slotsLeft;
  final List<DayItinerary> itinerary;
  final List<TrekRouteStop> trekRoute;
  final List<String> activities;
  final List<Review> reviews;
  final List<Resort> resorts;
  final List<String> inclusions;
  final List<String> exclusions;
  final List<String> imageUrls;
  final BoardingPoint boardingPoint;
  final CancellationPolicy cancellationPolicy;
  final List<OtherPolicy> otherPolicies;

  Trek({
    required this.name,
    this.isPopular = false,
    required this.subtitle,
    required this.imagePath,
    required this.price,
    this.hasDiscount = false,
    this.discountText = '',
    required this.duration,
    required this.rating,
    required this.numberOfRatings,
    required this.numberOfReviews,
    required this.peopleLikeRatings,
    required this.departureDate,
    required this.slotsLeft,
    required this.itinerary,
    required this.trekRoute,
    required this.activities,
    required this.reviews,
    required this.resorts,
    required this.inclusions,
    required this.exclusions,
    this.imageUrls = const [],
    required this.boardingPoint,
    required this.cancellationPolicy,
    required this.otherPolicies,
  });
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
  final int day;
  final String date;
  final String dayName;

  Resort({
    required this.name,
    required this.location,
    required this.amenities,
    required this.day,
    required this.date,
    required this.dayName,
  });
}

final defaultCancellationPolicy = CancellationPolicy(
  timeWindows: [
    CancellationTimeWindow(
      // beforeDeparture: 'Cancelled before 72 hours',
      beforeDeparture: 'Advance Payment (₹999)',
      // deduction: '20%',
      deduction: 'Non-refundable',
      // deductionAmount: 1200,
      // deductionAmount: 0,
    ),
    CancellationTimeWindow(
      // beforeDeparture: 'Cancelled before 72 hours',
      beforeDeparture: 'Full Payment Made',
      // deduction: '20%',
      deduction: '₹999 held,refund processed',
      // deductionAmount: 1200,
      // deductionAmount: 0,
    ),
    CancellationTimeWindow(
      // beforeDeparture: 'Cancelled before 72 hours',
      beforeDeparture: 'Cancellation Notice',
      // deduction: '20%',
      deduction: '1 day before trek',
      // deductionAmount: 1200,
      // deductionAmount: 0,
    ),
    // CancellationTimeWindow(
    //   beforeDeparture: 'From 72 hours to 48 hours',
    //   deduction: '50%',
    //   deductionAmount: 3000,
    // ),
    // CancellationTimeWindow(
    //   beforeDeparture: 'From 48 hours to 24 hours',
    //   deduction: '70%',
    //   deductionAmount: 4199,
    // ),
    // CancellationTimeWindow(
    //   beforeDeparture: 'No refund within 24 hours',
    //   deduction: '100%',
    //   deductionAmount: 5999,
    // ),
  ],
  baseFare: '5999',
  startDate: '22-12-2024',
  startTime: '15:50',
  // notes: [
  //   'Cancellation fees are applied on a per-slot basis.',
  //   'The cancellation charge mentioned above is calculated based on a seat fare of ₹ 5999.',
  //   'Cancellation charges are determined based on the service start date and time: 22-12-2024 at 15:50.',
  //   'Tickets cannot be cancelled after the scheduled departure time of the trek from the boarding point.',
  //   'For group bookings, individual slots may be cancelled.',
  // ],
  notes: [
    'GST and taxes are non-refundable. The advance secures your slot and is non-refundable upon cancellation.',
    'The remaining balance will be refunded within 5 to 7 working days, subject to cancellation terms.',
    "Cancellations within 1 day of departure are at the vendor's discretion, and Aorbo Treks is not liable.",
    'For group bookings, individual slots may be cancelled.',
    'The cancellation policy will be solely determined and approved by the respective vendor.',
  ],
);

final defaultOtherPolicies = [
  OtherPolicy(
    title: 'Liquor Policy',
    description:
        'Carrying or consuming alcohol during the trek is strictly prohibited. The trek operator reserves the right to deboard any customers under the influence of alcohol.',
    iconName: 'no_drinks', // This will map to the no liquor icon
  ),
  OtherPolicy(
    title: 'Boarding time policy',
    description:
        'The trek operator is not obligated to wait past the scheduled departure time. No refund requests will be considered for customers arriving late.',
    iconName: 'schedule', // This will map to the clock/time icon
  ),
  OtherPolicy(
    title: 'Cancellation Policy',
    description:
        'The cancellation policy will be solely determined and approved by the respective vendor.',
    iconName: 'cancel_schedule_send', // This will map to the no liquor icon
  ),
  OtherPolicy(
    title: 'Refund Policy',
    description:
        'The refund policy will be solely determined and approved by the respective vendor.',
    iconName: 'attach_money', // This will map to the no liquor icon
  ),
  OtherPolicy(
    title: 'Emergency Contact',
    description:
        'The emergency contact will be solely determined and approved by the respective vendor.',
    iconName: 'phone_in_talk', // This will map to the no liquor icon
  ),
  OtherPolicy(
    title: 'Trek Leader',
    description:
        'The trek leader will be solely determined and approved by the respective vendor.',
    iconName: 'person_pin_circle', // This will map to the no liquor icon
  ),
];

final List<Trek> popularTreks = [
  Trek(
    name: 'Kedarkantha',
    isPopular: true,
    subtitle: 'Uttarakhand | 6 Days',
    imagePath: CommonImages.logo,
    price: '8,999',
    hasDiscount: true,
    discountText: '15% OFF',
    duration: '6 Days, 5 Nights',
    rating: 4.0,
    numberOfRatings: 165,
    numberOfReviews: 10,
    peopleLikeRatings: {
      'Safety and Security': 4.4,
      'Organizer Manner': 4.2,
      'Trek Planning': 3.9,
      'Women Safety': 4.5,
    },
    departureDate: '10/06/2025',
    slotsLeft: 8,
    boardingPoint: BoardingPoint(
      location: 'Dehradun Railway Station',
      time: '03:30 PM',
      date: '15/05',
      transport: 'Pickup Vehicle',
    ),
    cancellationPolicy: defaultCancellationPolicy,
    otherPolicies: defaultOtherPolicies,
    itinerary: [
      DayItinerary(
        day: 1,
        title: 'Arrival and Acclimatization',
        description:
            'Arrive in Dehradun, transfer to Sankri village. Evening briefing and equipment check.',
        activities: ['Transfer to Sankri', 'Trek Briefing', 'Equipment Check'],
      ),
      DayItinerary(
        day: 2,
        title: 'Trek to Base Camp',
        description:
            'Trek through dense pine forests to reach Juda Ka Talab base camp.',
        activities: ['Forest Trek', 'Camp Setup', 'Evening Tea'],
      ),
      DayItinerary(
        day: 3,
        title: 'Summit Push',
        description:
            'Early morning start for summit, reach peak by afternoon, return to base camp.',
        activities: ['Summit Trek', 'Peak Photography', 'Return Trek'],
      ),
    ],
    trekRoute: [
      TrekRouteStop(
        time: '06:00 AM',
        date: '15/05',
        location: 'Dehradun Railway Station',
        transport: 'Pickup Vehicle',
      ),
      TrekRouteStop(
        time: '11:30 AM',
        date: '15/05',
        location: 'Sankri Village',
        transport: 'Trek Start',
      ),
      TrekRouteStop(
        time: '02:00 PM',
        date: '16/05',
        location: 'Juda Ka Talab Base Camp',
        transport: 'Trek',
      ),
      TrekRouteStop(
        time: '07:00 AM',
        date: '17/05',
        location: 'Kedarkantha Summit',
        transport: 'Trek',
      ),
    ],
    activities: [
      'Snow Trekking',
      'Photography',
      'Camping',
      'Star Gazing',
      'Wildlife Spotting',
    ],
    reviews: [
      Review(
        userName: 'Rahul Sharma',
        rating: 4.5,
        comment: 'Beautiful winter trek with great views!',
        date: '10/03/2024',
      ),
      Review(
        userName: 'Priya Singh',
        rating: 4.8,
        comment: 'Beautiful winter trek with great views!',
        date: '10/03/2024',
      ),
    ],
    resorts: [
      Resort(
        name: 'Sankri Mountain Lodge',
        location: 'Sankri Village',
        amenities: ['Hot Water', 'Dining Hall', 'Bonfire'],
        day: 1,
        date: '15/05',
        dayName: 'Monday',
      ),
    ],
    inclusions: [
      'Professional Trek Leader',
      'Camping Equipment',
      'Meals during trek',
      'First Aid Kit',
      'Permits',
    ],
    exclusions: [
      'Personal Equipment',
      'Travel Insurance',
      'Tips',
      'Personal Expenses',
    ],
    imageUrls: [
      CommonImages.kedarkantha1,
      CommonImages.kedarkantha2,
      CommonImages.kedarkantha3,
      CommonImages.kedarkantha4,
      CommonImages.kedarkantha5,
    ],
  ),
  Trek(
    name: 'Wayanad',
    subtitle: 'Coorg | 11 Days',
    imagePath: CommonImages.logo,
    price: '7,999',
    duration: '3 Days, 2 Nights',
    hasDiscount: true,
    discountText: '15% OFF',
    rating: 4.7,
    numberOfRatings: 200,
    numberOfReviews: 12,
    peopleLikeRatings: {
      'Safety and Security': 4.6,
      'Organizer Manner': 4.5,
      'Trek Planning': 4.4,
      'Women Safety': 4.8,
    },
    departureDate: '20/07/2025',
    slotsLeft: 10,
    boardingPoint: BoardingPoint(
      location: 'Hyderabad/Vijayawada/Tirupati',
      time: '6:00:00 PM',
      date: '01/06',
      transport: 'Bus',
    ),
    cancellationPolicy: defaultCancellationPolicy,
    otherPolicies: defaultOtherPolicies,
    itinerary: [
      DayItinerary(
        day: 1,
        title: 'Arrival in Gangtok',
        description: 'Arrive in Gangtok, acclimatization and briefing.',
        activities: [
          '⭐ Arrive at Mysore station by 9:00 AM',
          '⭐ Depart for Wayanad',
          '🌳 Bandipur Forest Drive (Spot Wildlife)',
          '💥 Wayanad Heritage Museum',
          '🌉 Visit the 900 Kandi Glass Bridge',
          '💥 Giant Swing',
          '⭐ Proceed to the Stay'
        ],
      ),
      DayItinerary(
        day: 2,
        title: 'Arrival in Gangtok',
        description: 'Arrive in Gangtok, acclimatization and briefing.',
        activities: [
          '⭐ Wake up early in the morning',
          '⭐ Get ready by 7:30 AM',
          '⭐ Have breakfast',
          '⛰️ Kanthanpara Waterfalls',
          '🌊 Visit Banasura Sagar Dam',
          '🌅 Lakkidi View Point',
          '🌁 Experience Zipline',
          '💥 Pookode Lake'
              '🛍️ Enjoy shopping'
        ],
      ),
      DayItinerary(
        day: 3,
        title: 'Arrival in Gangtok',
        description: 'Arrive in Gangtok, acclimatization and briefing.',
        activities: [
          '⭐ Wake up & Freshen up',
          '⭐ Start by 8:00 AM',
          '🐆 Explore Wayanad Wildlife Sanctuary (If allowed)',
          '💥 Phantom Rock',
          '⭐ Start the return journey to Mysore',
          '⭐ Catch the train back to your base city.'
        ],
      ),
    ],
    trekRoute: [
      TrekRouteStop(
        time: '08:00 AM',
        date: '01/06',
        location: 'Hyderabad/Vijayawada/Tirupati',
        transport: 'Train',
      ),
      TrekRouteStop(
        time: '12:00 PM',
        date: '01/06',
        location: 'Mysore',
        transport: 'Car/Mini bus/Tempo',
      ),
      TrekRouteStop(
        time: '02:00 PM',
        date: '02/06',
        location: 'Wayanad',
        transport: 'Car/Mini bus/Tempo',
      ),
      TrekRouteStop(
        time: '12:00 PM',
        date: '01/06',
        location: 'Mysore',
        transport: 'Car/Mini bus/Tempo',
      ),
      TrekRouteStop(
        time: '08:00 AM',
        date: '01/06',
        location: 'Hyderabad/Vijayawada/Tirupati',
        transport: 'Train',
      ),
    ],
    activities: [
      'Bandipur Forest Drive (Spot Wildlife)',
      'Wayanad Heritage Museum',
      'Visit the 900 Kandi Glass Bridge',
      'Giant Swing',
      'EKanthanpara Waterfalls',
      'Visit Banasura Sagar Dam',
      'Lakkidi View Point',
      'Zipline',
      'Pookode Lake',
      'Wayanad Wildlife Sanctuary (If allowed)',
      "Phantom Rock"
    ],
    reviews: [
      Review(
        userName: 'Rahul Sharma',
        rating: 2.5,
        comment: 'Beautiful winter trek with great views!',
        date: '10/03/2024',
      ),
      Review(
        userName: 'Rahul Sharma',
        rating: 4.5,
        comment: 'Beautiful winter trek with great views!',
        date: '10/03/2024',
      ),
      Review(
        userName: 'Priya Singh',
        rating: 3.8,
        comment: 'Beautiful winter trek with great views!',
        date: '10/03/2024',
      ),
    ],
    resorts: [
      Resort(
        name: 'Evoke Lifestyle Candolim',
        location: '3 star',
        amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
        day: 1,
        date: '23 Dec',
        dayName: 'Mon',
      ),
      Resort(
        name: 'Evoke Lifestyle Candolim',
        location: '3 star',
        amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
        day: 2,
        date: '24 Dec',
        dayName: 'Tue',
      ),
      Resort(
        name: 'Evoke Lifestyle Candolim',
        location: '3 star',
        amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
        day: 3,
        date: '25 Dec',
        dayName: 'Wed',
      ),
      Resort(
        name: 'Evoke Lifestyle Candolim',
        location: '3 star',
        amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
        day: 4,
        date: '26 Dec',
        dayName: 'Thu',
      ),
    ],
    inclusions: [
      'Train tickets (round trip)',
      'Accommodation (3/4 sharing rooms)',
      'Local transportation Tempo',
      'Breakfast',
      'Tolls, Taxes & Permits',
      'Driver Allowances',
      'Trip Organiser',
      'Basic First Aid'
    ],
    exclusions: [
      'Food',
      'Entry tickets and Jeep rides',
      'Other expenses not mentioned in the inclusions.'
    ],
    imageUrls: [],
  ),
  Trek(
    name: 'Valley of Flowers',
    isPopular: true,
    subtitle: 'Uttarakhand | 7 Days',
    imagePath: CommonImages.logo,
    price: '12,999',
    duration: '7 Days, 6 Nights',
    hasDiscount: true,
    discountText: 'Extra 15% OFF',
    rating: 2.8,
    numberOfRatings: 142,
    numberOfReviews: 8,
    peopleLikeRatings: {
      'Safety and Security': 4.6,
      'Organizer Manner': 4.5,
      'Trek Planning': 4.3,
      'Women Safety': 4.7,
    },
    departureDate: '20/06/2025',
    slotsLeft: 5,
    boardingPoint: BoardingPoint(
      location: 'Rishikesh Bus Stand',
      time: '06:00 AM',
      date: '20/05',
      transport: 'Bus',
    ),
    cancellationPolicy: defaultCancellationPolicy,
    otherPolicies: defaultOtherPolicies,
    itinerary: [
      DayItinerary(
        day: 1,
        title: 'Arrival at Govindghat',
        description: 'Arrive at Govindghat and prepare for the trek',
        activities: ['Arrival', 'Trek Briefing', 'Equipment Check'],
      ),
      DayItinerary(
        day: 2,
        title: 'Trek to Ghangaria',
        description: 'Trek through beautiful valleys to reach Ghangaria base',
        activities: ['Valley Trek', 'Photography', 'Camp Setup'],
      ),
      DayItinerary(
        day: 3,
        title: 'Valley of Flowers Visit',
        description: 'Full day exploration of the Valley of Flowers',
        activities: ['Flower Valley Trek', 'Photography', 'Wildlife Spotting'],
      ),
    ],
    trekRoute: [
      TrekRouteStop(
        time: '07:00 AM',
        date: '20/05',
        location: 'Rishikesh Bus Stand',
        transport: 'Bus',
      ),
      TrekRouteStop(
        time: '02:30 PM',
        date: '20/05',
        location: 'Govindghat',
        transport: 'Trek Start',
      ),
      TrekRouteStop(
        time: '11:00 AM',
        date: '21/05',
        location: 'Ghangaria',
        transport: 'Trek',
      ),
      TrekRouteStop(
        time: '09:00 AM',
        date: '22/05',
        location: 'Valley of Flowers',
        transport: 'Trek',
      ),
    ],
    activities: [
      'Flower Photography',
      'Valley Trekking',
      'Bird Watching',
      'Nature Walk'
    ],
    reviews: [
      Review(
        userName: 'Priya Singh',
        rating: 4.8,
        comment:
            'I have a very good and comfortable journey experience with Haunting voyagers. I had fun in all over the Trek',
        date: '10/04/2024',
      ),
      Review(
        userName: 'Priya Singh',
        rating: 1.8,
        comment:
            'I have a very good and comfortable journey experience with Haunting voyagers. I had fun in all over the Trek',
        date: '10/04/2024',
      ),
      Review(
        userName: 'Priya Singh',
        rating: 2.8,
        comment:
            'I have a very good and comfortable journey experience with Haunting voyagers. I had fun in all over the Trek',
        date: '10/04/2024',
      ),
    ],
    resorts: [
      Resort(
        name: 'Ghangaria Base Camp',
        location: 'Ghangaria',
        amenities: ['Hot Water', 'Mountain View', 'Dining'],
        day: 1,
        date: '20/05',
        dayName: 'Monday',
      ),
    ],
    inclusions: [
      'Professional Guide',
      'Camping Equipment',
      'Meals',
      'First Aid',
      'Permits'
    ],
    exclusions: [
      'Travel Insurance',
      'Personal Equipment',
      'Tips',
      'Emergency Evacuation'
    ],
    imageUrls: [
      CommonImages.valleyOfFlowers1,
      CommonImages.valleyOfFlowers2,
      CommonImages.valleyOfFlowers3,
      CommonImages.valleyOfFlowers4,
      CommonImages.valleyOfFlowers5,
    ],
  ),
  Trek(
    name: 'Hampta Pass',
    isPopular: true,
    subtitle: 'Himachal Pradesh | 5 Days',
    imagePath: CommonImages.logo,
    price: '9,999',
    duration: '5 Days, 4 Nights',
    hasDiscount: true,
    discountText: 'Extra 5% OFF',
    rating: 4.3,
    numberOfRatings: 98,
    numberOfReviews: 6,
    peopleLikeRatings: {
      'Safety and Security': 4.2,
      'Organizer Manner': 4.1,
      'Trek Planning': 4.0,
      'Women Safety': 4.4,
    },
    departureDate: '20/06/2025',
    slotsLeft: 15,
    boardingPoint: BoardingPoint(
      location: 'Manali',
      time: '06:00 AM',
      date: '25/05',
      transport: 'Drive',
    ),
    cancellationPolicy: defaultCancellationPolicy,
    otherPolicies: defaultOtherPolicies,
    itinerary: [
      DayItinerary(
        day: 1,
        title: 'Manali to Chika',
        description: 'Drive from Manali and trek to Chika campsite',
        activities: ['Drive', 'Short Trek', 'Camp Setup'],
      ),
      DayItinerary(
        day: 2,
        title: 'Chika to Balu Ka Ghera',
        description: 'Trek through meadows to Balu Ka Ghera',
        activities: ['River Crossing', 'Valley Trek', 'Photography'],
      ),
      DayItinerary(
        day: 3,
        title: 'Cross Hampta Pass',
        description: 'Summit day - cross the magnificent Hampta Pass',
        activities: ['Pass Crossing', 'Snow Trek', 'Summit Photography'],
      ),
    ],
    trekRoute: [
      TrekRouteStop(
        time: '06:00 AM',
        date: '25/05',
        location: 'Manali',
        transport: 'Drive',
      ),
      TrekRouteStop(
        time: '09:00 AM',
        date: '25/05',
        location: 'Chika',
        transport: 'Trek',
      ),
      TrekRouteStop(
        time: '12:00 PM',
        date: '25/05',
        location: 'Balu Ka Ghera',
        transport: 'Trek',
      ),
      TrekRouteStop(
        time: '03:00 PM',
        date: '25/05',
        location: 'Hampta Pass',
        transport: 'Trek',
      ),
    ],
    activities: [
      'Snow Trekking',
      'River Crossing',
      'Valley Exploration',
      'Camping'
    ],
    reviews: [
      Review(
        userName: 'Arun Kumar',
        rating: 4.5,
        comment: 'Perfect mix of challenge and beauty',
        date: '15/04/2024',
      ),
    ],
    resorts: [
      Resort(
        name: 'Balu Ka Ghera Camp',
        location: 'Balu Ka Ghera',
        amenities: ['Camping', 'Basic Toilets', 'Kitchen'],
        day: 1,
        date: '25/05',
        dayName: 'Monday',
      ),
    ],
    inclusions: [
      'Trek Leader',
      'Camping',
      'Meals',
      'Safety Equipment',
      'Permits'
    ],
    exclusions: ['Personal Gear', 'Insurance', 'Transport to Manali', 'Tips'],
    imageUrls: [],
  ),
  Trek(
    name: 'Brahmatal',
    isPopular: true,
    subtitle: 'Uttarakhand | 6 Days',
    imagePath: CommonImages.logo,
    price: '10,999',
    duration: '6 Days, 5 Nights',
    rating: 4.4,
    numberOfRatings: 120,
    numberOfReviews: 5,
    peopleLikeRatings: {
      'Safety and Security': 4.3,
      'Organizer Manner': 4.2,
      'Trek Planning': 4.1,
      'Women Safety': 4.5,
    },
    departureDate: '20/06/2025',
    slotsLeft: 7,
    boardingPoint: BoardingPoint(
      location: 'Lohajung',
      time: '06:00 AM',
      date: '05/06',
      transport: 'Travel',
    ),
    cancellationPolicy: defaultCancellationPolicy,
    otherPolicies: defaultOtherPolicies,
    itinerary: [
      DayItinerary(
        day: 1,
        title: 'Reach Lohajung',
        description: 'Arrival and acclimatization at Lohajung',
        activities: ['Travel', 'Briefing', 'Local Exploration'],
      ),
      DayItinerary(
        day: 2,
        title: 'Trek to Bekaltal',
        description: 'Trek through oak and rhododendron forests',
        activities: ['Forest Trek', 'Lake Visit', 'Camping'],
      ),
      DayItinerary(
        day: 3,
        title: 'Brahmatal Summit',
        description: 'Trek to Brahmatal summit and lake',
        activities: ['Summit Trek', 'Lake Visit', 'Photography'],
      ),
    ],
    trekRoute: [
      TrekRouteStop(
        time: '06:00 AM',
        date: '05/06',
        location: 'Lohajung',
        transport: 'Travel',
      ),
      TrekRouteStop(
        time: '09:00 AM',
        date: '05/06',
        location: 'Bekaltal',
        transport: 'Trek',
      ),
      TrekRouteStop(
        time: '12:00 PM',
        date: '05/06',
        location: 'Brahmatal Summit',
        transport: 'Trek',
      ),
      TrekRouteStop(
        time: '03:00 PM',
        date: '06/06',
        location: 'Brahmatal Lake',
        transport: 'Trek',
      ),
    ],
    activities: [
      'Winter Trekking',
      'Lake Visits',
      'Summit Climb',
      'Snow Camping'
    ],
    reviews: [
      Review(
        userName: 'Vikram Mehta',
        rating: 4.4,
        comment: 'Beautiful winter trek with great views',
        date: '20/04/2024',
      ),
    ],
    resorts: [
      Resort(
        name: 'Brahmatal Base Camp',
        location: 'Near Brahmatal',
        amenities: ['Heated Tents', 'Hot Meals', 'Basic Facilities'],
        day: 1,
        date: '05/06',
        dayName: 'Monday',
      ),
    ],
    inclusions: [
      'Expert Guide',
      'Winter Camping Gear',
      'All Meals',
      'Safety Equipment'
    ],
    exclusions: [
      'Winter Clothing',
      'Personal Expenses',
      'Transport',
      'Insurance'
    ],
    imageUrls: [],
  ),
  Trek(
    name: 'Sandakphu',
    isPopular: true,
    subtitle: 'West Bengal | 7 Days',
    imagePath: CommonImages.logo,
    price: '11,999',
    duration: '7 Days, 6 Nights',
    rating: 4.2,
    numberOfRatings: 100,
    numberOfReviews: 4,
    peopleLikeRatings: {
      'Safety and Security': 4.1,
      'Organizer Manner': 4.0,
      'Trek Planning': 3.9,
      'Women Safety': 4.3,
    },
    departureDate: '20/06/2025',
    slotsLeft: 9,
    boardingPoint: BoardingPoint(
      location: 'Manebhanjan',
      time: '06:00 AM',
      date: '12/06',
      transport: 'Travel',
    ),
    cancellationPolicy: defaultCancellationPolicy,
    otherPolicies: defaultOtherPolicies,
    itinerary: [
      DayItinerary(
        day: 1,
        title: 'Reach Manebhanjan',
        description: 'Arrival and preparation at Manebhanjan',
        activities: ['Arrival', 'Permit Collection', 'Trek Briefing'],
      ),
      DayItinerary(
        day: 2,
        title: 'Trek to Tumling',
        description: 'First day trek through rhododendron forests',
        activities: ['Forest Trek', 'Village Visit', 'Sunset View'],
      ),
      DayItinerary(
        day: 3,
        title: 'Sandakphu Peak',
        description: 'Trek to Sandakphu peak for panoramic views',
        activities: ['Peak Trek', 'Mountain Photography', 'Camping'],
      ),
    ],
    trekRoute: [
      TrekRouteStop(
        time: '06:00 AM',
        date: '12/06',
        location: 'Manebhanjan',
        transport: 'Travel',
      ),
      TrekRouteStop(
        time: '09:00 AM',
        date: '12/06',
        location: 'Tumling',
        transport: 'Trek',
      ),
      TrekRouteStop(
        time: '12:00 PM',
        date: '12/06',
        location: 'Sandakphu Peak',
        transport: 'Trek',
      ),
      TrekRouteStop(
        time: '03:00 PM',
        date: '13/06',
        location: 'Sandakphu',
        transport: 'Trek',
      ),
    ],
    activities: [
      'Mountain Photography',
      'Village Visits',
      'Peak Climbing',
      'Sunrise Views'
    ],
    reviews: [
      Review(
        userName: 'Sneha Roy',
        rating: 4.2,
        comment: 'Amazing views of four 8000m peaks',
        date: '25/04/2024',
      ),
    ],
    resorts: [
      Resort(
        name: 'Sandakphu Mountain Lodge',
        location: 'Sandakphu Peak',
        amenities: ['Basic Rooms', 'Hot Water', 'Mountain Views'],
        day: 1,
        date: '12/06',
        dayName: 'Monday',
      ),
    ],
    inclusions: [
      'Local Guide',
      'Accommodation',
      'Meals',
      'Permits',
      'First Aid'
    ],
    exclusions: [
      'Travel to Manebhanjan',
      'Personal Equipment',
      'Extra Snacks',
      'Tips'
    ],
    imageUrls: [],
  ),
  Trek(
    name: 'Har Ki Dun',
    isPopular: true,
    subtitle: 'Uttarakhand | 8 Days',
    imagePath: CommonImages.logo,
    price: '13,999',
    duration: '8 Days, 7 Nights',
    rating: 4.6,
    numberOfRatings: 150,
    numberOfReviews: 7,
    peopleLikeRatings: {
      'Safety and Security': 4.5,
      'Organizer Manner': 4.4,
      'Trek Planning': 4.3,
      'Women Safety': 4.7,
    },
    departureDate: '20/06/2025',
    slotsLeft: 6,
    boardingPoint: BoardingPoint(
      location: 'Sankri',
      time: '06:00 AM',
      date: '18/06',
      transport: 'Drive',
    ),
    cancellationPolicy: defaultCancellationPolicy,
    otherPolicies: defaultOtherPolicies,
    itinerary: [
      DayItinerary(
        day: 1,
        title: 'Reach Sankri',
        description: 'Drive to Sankri and preparation',
        activities: ['Travel', 'Village Tour', 'Equipment Check'],
      ),
      DayItinerary(
        day: 2,
        title: 'Trek to Taluka',
        description: 'Trek through ancient villages and forests',
        activities: ['Village Trek', 'Cultural Experience', 'Camp Setup'],
      ),
      DayItinerary(
        day: 3,
        title: 'Har Ki Dun Valley',
        description: 'Explore the beautiful Har Ki Dun valley',
        activities: ['Valley Trek', 'Photography', 'Camping'],
      ),
    ],
    trekRoute: [
      TrekRouteStop(
        time: '06:00 AM',
        date: '18/06',
        location: 'Sankri',
        transport: 'Drive',
      ),
      TrekRouteStop(
        time: '09:00 AM',
        date: '18/06',
        location: 'Taluka',
        transport: 'Trek',
      ),
      TrekRouteStop(
        time: '12:00 PM',
        date: '18/06',
        location: 'Har Ki Dun Valley',
        transport: 'Trek',
      ),
      TrekRouteStop(
        time: '03:00 PM',
        date: '19/06',
        location: 'Osla',
        transport: 'Trek',
      ),
    ],
    activities: ['Valley Trekking', 'Cultural Tours', 'Photography', 'Camping'],
    reviews: [
      Review(
        userName: 'Rajesh Sharma',
        rating: 4.6,
        comment: 'Perfect blend of culture and nature',
        date: '01/05/2024',
      ),
    ],
    resorts: [
      Resort(
        name: 'Har Ki Dun Camp',
        location: 'Har Ki Dun Valley',
        amenities: ['Camping', 'Kitchen', 'Valley Views'],
        day: 1,
        date: '18/06',
        dayName: 'Monday',
      ),
    ],
    inclusions: [
      'Trek Guide',
      'Camping Equipment',
      'Meals',
      'Permits',
      'Transport from Sankri'
    ],
    exclusions: ['Personal Gear', 'Insurance', 'Transport to Sankri', 'Tips'],
    imageUrls: [
      CommonImages.valleyOfFlowers1,
      CommonImages.valleyOfFlowers2,
      CommonImages.valleyOfFlowers3,
      CommonImages.valleyOfFlowers4,
      CommonImages.valleyOfFlowers5,
    ],
  ),
  Trek(
    name: 'Roopkund',
    isPopular: true,
    subtitle: 'Uttarakhand | 8 Days',
    imagePath: CommonImages.logo,
    price: '14,999',
    duration: '8 Days, 7 Nights',
    rating: 4.7,
    numberOfRatings: 180,
    numberOfReviews: 9,
    peopleLikeRatings: {
      'Safety and Security': 4.6,
      'Organizer Manner': 4.5,
      'Trek Planning': 4.4,
      'Women Safety': 4.8,
    },
    departureDate: '25/05/2025',
    slotsLeft: 4,
    boardingPoint: BoardingPoint(
      location: 'Lohajung',
      time: '06:00 AM',
      date: '25/06',
      transport: 'Travel',
    ),
    cancellationPolicy: defaultCancellationPolicy,
    otherPolicies: defaultOtherPolicies,
    itinerary: [
      DayItinerary(
        day: 1,
        title: 'Reach Lohajung',
        description: 'Arrival at Lohajung base camp',
        activities: ['Travel', 'Acclimatization', 'Briefing'],
      ),
      DayItinerary(
        day: 2,
        title: 'Trek to Didina',
        description: 'Trek through dense forests to Didina village',
        activities: ['Forest Trek', 'Village Visit', 'Camp Setup'],
      ),
      DayItinerary(
        day: 3,
        title: 'Roopkund Lake',
        description: 'Trek to the mysterious Roopkund Lake',
        activities: ['High Altitude Trek', 'Lake Visit', 'Photography'],
      ),
    ],
    trekRoute: [
      TrekRouteStop(
        time: '06:00 AM',
        date: '25/06',
        location: 'Lohajung',
        transport: 'Travel',
      ),
      TrekRouteStop(
        time: '09:00 AM',
        date: '25/06',
        location: 'Didina',
        transport: 'Trek',
      ),
      TrekRouteStop(
        time: '12:00 PM',
        date: '25/06',
        location: 'Bedni Bugyal',
        transport: 'Trek',
      ),
      TrekRouteStop(
        time: '03:00 PM',
        date: '25/06',
        location: 'Roopkund Lake',
        transport: 'Trek',
      ),
    ],
    activities: [
      'High Altitude Trekking',
      'Mystery Lake Visit',
      'Meadow Camping',
      'Photography'
    ],
    reviews: [
      Review(
        userName: 'Amit Patel',
        rating: 4.7,
        comment: 'Challenging but rewarding trek',
        date: '05/05/2024',
      ),
    ],
    resorts: [
      Resort(
        name: 'Bedni Bugyal Camp',
        location: 'Bedni Bugyal',
        amenities: ['Alpine Tents', 'Hot Meals', 'Medical Aid'],
        day: 1,
        date: '25/06',
        dayName: 'Monday',
      ),
    ],
    inclusions: [
      'Expert Guide',
      'High Altitude Gear',
      'Meals',
      'Safety Equipment',
      'Permits'
    ],
    exclusions: [
      'Personal Equipment',
      'Insurance',
      'Transport to Lohajung',
      'Emergency Evacuation'
    ],
    imageUrls: [],
  ),
  Trek(
    name: 'Gokarna and Dandeli',
    subtitle: 'Haunting voyages',
    imagePath: CommonImages.logo,
    price: '4,999',
    duration: '4 Days / 3 Nights',
    departureDate: '20/06/2025',
    rating: 3.5,
    numberOfRatings: 50,
    numberOfReviews: 2,
    peopleLikeRatings: {
      'Safety and Security': 3.5,
      'Organizer Manner': 3.4,
      'Trek Planning': 3.3,
      'Women Safety': 3.6,
    },
    slotsLeft: 5,
    hasDiscount: true,
    discountText: 'Extra 15% OFF',
    boardingPoint: BoardingPoint(
      location: 'Nampally railway station',
      time: '03:50 PM',
      date: '22/12',
      transport: 'Train',
    ),
    cancellationPolicy: defaultCancellationPolicy,
    otherPolicies: defaultOtherPolicies,
    itinerary: [
      DayItinerary(
        day: 1,
        title: 'Arrival in Gokarna',
        description: 'Beach exploration and local sightseeing',
        activities: ['Beach Visit', 'Temple Tour'],
      ),
    ],
    trekRoute: [
      TrekRouteStop(
        time: '03:50 PM',
        date: '22/12',
        location: 'Nampally railway station',
        transport: 'Train',
      ),
      TrekRouteStop(
        time: '05:30 AM',
        date: '23/12',
        location: 'Hubli',
        transport: 'Mini bus/Car',
      ),
    ],
    activities: ['Beach Trekking', 'Water Sports'],
    reviews: [
      Review(
        userName: 'Rahul Sharma',
        rating: 4.5,
        comment: 'Beautiful winter trek with great views!',
        date: '10/03/2024',
      ),
      Review(
        userName: 'Priya Singh',
        rating: 4.8,
        comment: 'Beautiful winter trek with great views!',
        date: '10/03/2024',
      ),
    ],
    resorts: [
      Resort(
        name: 'Evoke Lifestyle Candolim',
        location: '3 star',
        amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
        day: 1,
        date: '23 Dec',
        dayName: 'Mon',
      ),
      Resort(
        name: 'Evoke Lifestyle Candolim',
        location: '3 star',
        amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
        day: 2,
        date: '24 Dec',
        dayName: 'Tue',
      ),
      Resort(
        name: 'Evoke Lifestyle Candolim',
        location: '3 star',
        amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
        day: 3,
        date: '25 Dec',
        dayName: 'Wed',
      ),
      Resort(
        name: 'Evoke Lifestyle Candolim',
        location: '3 star',
        amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
        day: 4,
        date: '26 Dec',
        dayName: 'Thu',
      ),
    ],
    inclusions: ['Guide', 'Transport'],
    exclusions: ['Personal Expenses'],
  ),

  //new treks
];

final List<Booking> bookedTreks = [
  Booking(
    trekName: 'Kedarkantha',
    subtitle: 'Uttarakhand | 6 Days',
    pnrId: 'AROBOK123456',
    duration: '6 Days, 5 Nights',
    departureDate: '10/06/2025',
    status: 'Upcoming',
    organiserName: 'Trekking Freaks limited',
    endLocation: 'Kedarkantha Summit',
    slots: 12,
    description: 'A thrilling snow trek to Kedarkantha summit.',
    number: 1234567890,
  ),
  Booking(
    trekName: 'Gokarna and Dandeli',
    subtitle: 'Haunting voyages',
    pnrId: 'AROBOG789012',
    duration: '4 Days / 3 Nights',
    departureDate: '15/06/2024',
    status: 'Completed',
    organiserName: 'Trekking Freaks limited',
    endLocation: 'Dandeli',
    slots: 20,
    description: 'Explore the beaches of Gokarna and forests of Dandeli.',
    number: 1234567890,
  ),
  Booking(
    trekName: 'Valley of Flowers',
    subtitle: 'Uttarakhand | 7 Days',
    pnrId: 'AROBOV345678',
    duration: '7 Days, 6 Nights',
    departureDate: '15/05/2024',
    status: 'Cancelled',
    organiserName: 'Trekking Freaks limited',
    endLocation: 'Dandeli',
    slots: 20,
    description: 'Explore the beaches of Gokarna and forests of Dandeli.',
    number: 1234567890,
  ),
];

// final List<Trek> allTreks = [
//   ...popularTreks,
//   Trek(
//     name: 'Goechala',
//     subtitle: 'Sikkim | 11 Days',
//     imagePath: CommonImages.logo,
//     price: '24,999',
//     duration: '11 Days, 10 Nights',
//     rating: 4.7,
//     numberOfRatings: 200,
//     numberOfReviews: 12,
//     peopleLikeRatings: {
//       'Safety and Security': 4.6,
//       'Organizer Manner': 4.5,
//       'Trek Planning': 4.4,
//       'Women Safety': 4.8,
//     },
//     departureDate: '20/07/2025',
//     slotsLeft: 10,
//     boardingPoint: BoardingPoint(
//       location: 'Gangtok Bus Terminal',
//       time: '07:00 AM',
//       date: '01/06',
//       transport: 'Bus',
//     ),
//     cancellationPolicy: defaultCancellationPolicy,
//     otherPolicies: defaultOtherPolicies,
//     itinerary: [
//       DayItinerary(
//         day: 1,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: ['Hotel Check-in', 'Trek Briefing'],
//       ),
//     ],
//     trekRoute: [
//       TrekRouteStop(
//         time: '08:00 AM',
//         date: '01/06',
//         location: 'Gangtok',
//         transport: 'Drive',
//       ),
//       TrekRouteStop(
//         time: '12:00 PM',
//         date: '01/06',
//         location: 'Yuksom',
//         transport: 'Trek Start',
//       ),
//       TrekRouteStop(
//         time: '02:00 PM',
//         date: '02/06',
//         location: 'Dzongri',
//         transport: 'Trek',
//       ),
//       TrekRouteStop(
//         time: '06:00 AM',
//         date: '03/06',
//         location: 'Goechala',
//         transport: 'Trek',
//       ),
//     ],
//     activities: ['High Altitude Trek', 'Photography'],
//     reviews: [],
//     resorts: [],
//     inclusions: ['Trek Leader', 'Permits'],
//     exclusions: ['Personal Equipment'],
//     imageUrls: [
//       CommonImages.valleyOfFlowers1,
//       CommonImages.valleyOfFlowers2,
//       CommonImages.valleyOfFlowers3,
//       CommonImages.valleyOfFlowers4,
//       CommonImages.valleyOfFlowers5,
//     ],
//   ),
//   Trek(
//     name: 'Tarsar Marsar',
//     subtitle: 'Kashmir | 8 Days',
//     imagePath: CommonImages.logo,
//     price: '18,999',
//     hasDiscount: true,
//     discountText: '10% OFF',
//     duration: '8 Days, 7 Nights',
//     rating: 4.6,
//     numberOfRatings: 100,
//     numberOfReviews: 5,
//     peopleLikeRatings: {
//       'Safety and Security': 4.5,
//       'Organizer Manner': 4.4,
//       'Trek Planning': 4.3,
//       'Women Safety': 4.7,
//     },
//     departureDate: '25/06/2025',
//     slotsLeft: 12,
//     boardingPoint: BoardingPoint(
//       location: 'Srinagar Airport',
//       time: '08:00 AM',
//       date: '10/06',
//       transport: 'Flight',
//     ),
//     cancellationPolicy: defaultCancellationPolicy,
//     otherPolicies: defaultOtherPolicies,
//     itinerary: [],
//     trekRoute: [],
//     activities: [],
//     reviews: [],
//     resorts: [],
//     inclusions: [],
//     exclusions: [],
//     imageUrls: [],
//   ),
//   Trek(
//     name: 'Pin Parvati Pass',
//     subtitle: 'Himachal Pradesh | 10 Days',
//     imagePath: CommonImages.logo,
//     price: '21,999',
//     duration: '10 Days, 9 Nights',
//     rating: 4.8,
//     numberOfRatings: 120,
//     numberOfReviews: 7,
//     peopleLikeRatings: {
//       'Safety and Security': 4.7,
//       'Organizer Manner': 4.6,
//       'Trek Planning': 4.5,
//       'Women Safety': 4.9,
//     },
//     departureDate: '20/07/2025',
//     slotsLeft: 8,
//     boardingPoint: BoardingPoint(
//       location: 'Manali',
//       time: '06:00 AM',
//       date: '15/06',
//       transport: 'Drive',
//     ),
//     cancellationPolicy: defaultCancellationPolicy,
//     otherPolicies: defaultOtherPolicies,
//     itinerary: [],
//     trekRoute: [],
//     activities: [],
//     reviews: [],
//     resorts: [],
//     inclusions: [],
//     exclusions: [],
//     imageUrls: [],
//   ),
//   Trek(
//     name: 'Chadar Trek',
//     subtitle: 'Ladakh | 9 Days',
//     imagePath: CommonImages.logo,
//     price: '25,999',
//     duration: '9 Days, 8 Nights',
//     rating: 4.9,
//     numberOfRatings: 150,
//     numberOfReviews: 9,
//     peopleLikeRatings: {
//       'Safety and Security': 4.8,
//       'Organizer Manner': 4.7,
//       'Trek Planning': 4.6,
//       'Women Safety': 5.0,
//     },
//     departureDate: '20/07/2025',
//     slotsLeft: 5,
//     boardingPoint: BoardingPoint(
//       location: 'Leh Airport',
//       time: '09:00 AM',
//       date: '20/06',
//       transport: 'Flight',
//     ),
//     cancellationPolicy: defaultCancellationPolicy,
//     otherPolicies: defaultOtherPolicies,
//     itinerary: [],
//     trekRoute: [],
//     activities: [],
//     reviews: [],
//     resorts: [],
//     inclusions: [],
//     exclusions: [],
//     imageUrls: [
//       CommonImages.valleyOfFlowers1,
//       CommonImages.valleyOfFlowers2,
//       CommonImages.valleyOfFlowers3,
//       CommonImages.valleyOfFlowers4,
//       CommonImages.valleyOfFlowers5,
//     ],
//   ),
//   Trek(
//     name: 'Kuari Pass',
//     subtitle: 'Uttarakhand | 6 Days',
//     imagePath: CommonImages.logo,
//     price: '11,999',
//     duration: '6 Days, 5 Nights',
//     rating: 4.4,
//     numberOfRatings: 80,
//     numberOfReviews: 3,
//     peopleLikeRatings: {
//       'Safety and Security': 4.3,
//       'Organizer Manner': 4.2,
//       'Trek Planning': 4.1,
//       'Women Safety': 4.5,
//     },
//     departureDate: '10/06/2025',
//     slotsLeft: 15,
//     boardingPoint: BoardingPoint(
//       location: 'Dehradun Railway Station',
//       time: '07:00 AM',
//       date: '25/06',
//       transport: 'Train',
//     ),
//     cancellationPolicy: defaultCancellationPolicy,
//     otherPolicies: defaultOtherPolicies,
//     itinerary: [],
//     trekRoute: [],
//     activities: [],
//     reviews: [],
//     resorts: [],
//     inclusions: [],
//     exclusions: [],
//     imageUrls: [],
//   ),
//   Trek(
//     name: 'Nag Tibba',
//     subtitle: 'Uttarakhand | 3 Days',
//     imagePath: CommonImages.logo,
//     price: '5,999',
//     duration: '3 Days, 2 Nights',
//     rating: 4.2,
//     numberOfRatings: 50,
//     numberOfReviews: 2,
//     peopleLikeRatings: {
//       'Safety and Security': 4.1,
//       'Organizer Manner': 4.0,
//       'Trek Planning': 3.9,
//       'Women Safety': 4.3,
//     },
//     departureDate: '20/06/2025',
//     slotsLeft: 20,
//     boardingPoint: BoardingPoint(
//       location: 'Dehradun Bus Stand',
//       time: '08:00 AM',
//       date: '30/06',
//       transport: 'Bus',
//     ),
//     cancellationPolicy: defaultCancellationPolicy,
//     otherPolicies: defaultOtherPolicies,
//     itinerary: [],
//     trekRoute: [],
//     activities: [],
//     reviews: [],
//     resorts: [],
//     inclusions: [],
//     exclusions: [],
//     imageUrls: [],
//   ),
//   Trek(
//     name: 'Coorg Chikmangalur',
//     subtitle: 'Coorg | 11 Days',
//     imagePath: CommonImages.logo,
//     price: '6,999',
//     duration: '3 Days, 2 Nights',
//     hasDiscount: true,
//     discountText: '5% OFF',
//     rating: 4.7,
//     numberOfRatings: 200,
//     numberOfReviews: 12,
//     peopleLikeRatings: {
//       'Safety and Security': 4.6,
//       'Organizer Manner': 4.5,
//       'Trek Planning': 4.4,
//       'Women Safety': 4.8,
//     },
//     departureDate: '20/07/2025',
//     slotsLeft: 10,
//     boardingPoint: BoardingPoint(
//       location: 'Nampally Railway Station',
//       time: '10:00:00 PM',
//       date: '01/06',
//       transport: 'Bus',
//     ),
//     cancellationPolicy: defaultCancellationPolicy,
//     otherPolicies: defaultOtherPolicies,
//     itinerary: [
//       DayItinerary(
//         day: 1,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           '🕘 Arrive in Mysore at 9:30 AM',
//           '🍳 Basic Freshen Up & Breakfast',
//           '🌟 Golden Temple 🕌',
//           '🐘 Visit Dubbare Elephant Camp 🐘',
//           '💥 Raja\'s Seat in the Evening',
//           '🛍 Enjoy some shopping 🛒',
//           '🏕 Overnight stay in an Coorg'
//         ],
//       ),
//       DayItinerary(
//         day: 2,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           '🕘 Start the day at 5 AM',
//           '🌟 Wake up and freshen up 🌄',
//           '⛰ Jeep Ride to Mandalpatti Peak 🏔️',
//           '🌟 Visit Abbey Waterfalls 🏞️',
//           '📍Start our Journey to Chikmagalur',
//           '🌟 Explore the Belur Temple 🏰',
//           '🌟 Water Sports in Yagachi Dam',
//           '🌟 Overnight stay 🌃'
//         ],
//       ),
//       DayItinerary(
//         day: 3,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           '🌟 Wake up and freshen up 🌅',
//           '🥾 Jeep Ride & Trek to Mullayanagiri Peak',
//           '🌊 Jhari Falls',
//           '🌟 Catch the return train to your base city.',
//         ],
//       ),
//     ],
//     trekRoute: [
//       TrekRouteStop(
//         time: '08:00 AM',
//         date: '01/06',
//         location: 'Nampally Railway Station',
//         transport: 'Train',
//       ),
//       TrekRouteStop(
//         time: '12:00 PM',
//         date: '01/06',
//         location: 'Mysore',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '02:00 PM',
//         date: '02/06',
//         location: 'Coorg',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '06:00 AM',
//         date: '03/06',
//         location: 'Chikmagalur',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '12:00 PM',
//         date: '01/06',
//         location: 'Mysore',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '08:00 AM',
//         date: '01/06',
//         location: 'Hyderabad',
//         transport: 'Train',
//       ),
//     ],
//     activities: [
//       'Golden Temple 🕌',
//       'Visit Dubbare Elephant Camp 🐘',
//       'Raja\'s Seat',
//       'Jeep Ride to Mandalpatti Peak 🏔️',
//       'Visit Abbey Waterfalls 🏞️',
//       'Explore the Belur Temple 🏰',
//       'Water Sports in Yagachi Dam',
//       'Jeep Ride & Trek to Mullayanagiri Peak',
//       'Jhari Falls'
//     ],
//     reviews: [
//       Review(
//         userName: 'Rahul Sharma',
//         rating: 2.5,
//         comment: 'Beautiful winter trek with great views!',
//         date: '10/03/2024',
//       ),
//       Review(
//         userName: 'Rahul Sharma',
//         rating: 4.5,
//         comment: 'Beautiful winter trek with great views!',
//         date: '10/03/2024',
//       ),
//       Review(
//         userName: 'Priya Singh',
//         rating: 3.8,
//         comment: 'Beautiful winter trek with great views!',
//         date: '10/03/2024',
//       ),
//     ],
//     resorts: [
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 1,
//         date: '23 Dec',
//         dayName: 'Mon',
//       ),
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 2,
//         date: '24 Dec',
//         dayName: 'Tue',
//       ),
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 3,
//         date: '25 Dec',
//         dayName: 'Wed',
//       ),
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 4,
//         date: '26 Dec',
//         dayName: 'Thu',
//       ),
//     ],
//     inclusions: [
//       'Train Tickets (To & From)',
//       'Accommodation (4 Sharing rooms) 🏨',
//       'Local Transportation for 3 Days',
//       'Tolls, Taxes, Parking',
//       'Driver Allowances',
//       'Trip Guide',
//       'First Aid',
//     ],
//     exclusions: [
//       'Food expenses 🍴',
//       'Entry tickets and fares 🎟',
//       'Jeep rides 🚙',
//       'Other expenses which are not mentioned 💰'
//     ],
//     imageUrls: [
//       CommonImages.valleyOfFlowers1,
//       CommonImages.valleyOfFlowers2,
//       CommonImages.valleyOfFlowers3,
//       CommonImages.valleyOfFlowers4,
//       CommonImages.valleyOfFlowers5,
//     ],
//   ),
//   Trek(
//     name: 'Wayanad',
//     subtitle: 'Coorg | 11 Days',
//     imagePath: CommonImages.logo,
//     price: '7,999',
//     duration: '3 Days, 2 Nights',
//     hasDiscount: true,
//     discountText: '15% OFF',
//     rating: 4.7,
//     numberOfRatings: 200,
//     numberOfReviews: 12,
//     peopleLikeRatings: {
//       'Safety and Security': 4.6,
//       'Organizer Manner': 4.5,
//       'Trek Planning': 4.4,
//       'Women Safety': 4.8,
//     },
//     departureDate: '20/07/2025',
//     slotsLeft: 10,
//     boardingPoint: BoardingPoint(
//       location: 'Hyderabad/Vijayawada/Tirupati',
//       time: '6:00:00 PM',
//       date: '01/06',
//       transport: 'Bus',
//     ),
//     cancellationPolicy: defaultCancellationPolicy,
//     otherPolicies: defaultOtherPolicies,
//     itinerary: [
//       DayItinerary(
//         day: 1,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           '⭐ Arrive at Mysore station by 9:00 AM',
//           '⭐ Depart for Wayanad',
//           '🌳 Bandipur Forest Drive (Spot Wildlife)',
//           '💥 Wayanad Heritage Museum',
//           '🌉 Visit the 900 Kandi Glass Bridge',
//           '💥 Giant Swing',
//           '⭐ Proceed to the Stay'
//         ],
//       ),
//       DayItinerary(
//         day: 2,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           '⭐ Wake up early in the morning',
//           '⭐ Get ready by 7:30 AM',
//           '⭐ Have breakfast',
//           '⛰️ Kanthanpara Waterfalls',
//           '🌊 Visit Banasura Sagar Dam',
//           '🌅 Lakkidi View Point',
//           '🌁 Experience Zipline',
//           '💥 Pookode Lake'
//               '🛍️ Enjoy shopping'
//         ],
//       ),
//       DayItinerary(
//         day: 3,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           '⭐ Wake up & Freshen up',
//           '⭐ Start by 8:00 AM',
//           '🐆 Explore Wayanad Wildlife Sanctuary (If allowed)',
//           '💥 Phantom Rock',
//           '⭐ Start the return journey to Mysore',
//           '⭐ Catch the train back to your base city.'
//         ],
//       ),
//     ],
//     trekRoute: [
//       TrekRouteStop(
//         time: '08:00 AM',
//         date: '01/06',
//         location: 'Hyderabad/Vijayawada/Tirupati',
//         transport: 'Train',
//       ),
//       TrekRouteStop(
//         time: '12:00 PM',
//         date: '01/06',
//         location: 'Mysore',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '02:00 PM',
//         date: '02/06',
//         location: 'Wayanad',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '12:00 PM',
//         date: '01/06',
//         location: 'Mysore',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '08:00 AM',
//         date: '01/06',
//         location: 'Hyderabad/Vijayawada/Tirupati',
//         transport: 'Train',
//       ),
//     ],
//     activities: [
//       'Bandipur Forest Drive (Spot Wildlife)',
//       'Wayanad Heritage Museum',
//       'Visit the 900 Kandi Glass Bridge',
//       'Giant Swing',
//       'EKanthanpara Waterfalls',
//       'Visit Banasura Sagar Dam',
//       'Lakkidi View Point',
//       'Zipline',
//       'Pookode Lake',
//       'Wayanad Wildlife Sanctuary (If allowed)',
//       "Phantom Rock"
//     ],
//     reviews: [
//       Review(
//         userName: 'Rahul Sharma',
//         rating: 2.5,
//         comment: 'Beautiful winter trek with great views!',
//         date: '10/03/2024',
//       ),
//       Review(
//         userName: 'Rahul Sharma',
//         rating: 4.5,
//         comment: 'Beautiful winter trek with great views!',
//         date: '10/03/2024',
//       ),
//       Review(
//         userName: 'Priya Singh',
//         rating: 3.8,
//         comment: 'Beautiful winter trek with great views!',
//         date: '10/03/2024',
//       ),
//     ],
//     resorts: [
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 1,
//         date: '23 Dec',
//         dayName: 'Mon',
//       ),
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 2,
//         date: '24 Dec',
//         dayName: 'Tue',
//       ),
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 3,
//         date: '25 Dec',
//         dayName: 'Wed',
//       ),
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 4,
//         date: '26 Dec',
//         dayName: 'Thu',
//       ),
//     ],
//     inclusions: [
//       'Train tickets (round trip)',
//       'Accommodation (3/4 sharing rooms)',
//       'Local transportation Tempo',
//       'Breakfast',
//       'Tolls, Taxes & Permits',
//       'Driver Allowances',
//       'Trip Organiser',
//       'Basic First Aid'
//     ],
//     exclusions: [
//       'Food',
//       'Entry tickets and Jeep rides',
//       'Other expenses not mentioned in the inclusions.'
//     ],
//     imageUrls: [],
//   ),
//
//   // Add more treks as needed
//
//   Trek(
//     name: 'OOTY COONOOR',
//     subtitle: 'Coorg | 11 Days',
//     imagePath: CommonImages.logo,
//     price: '7,999',
//     duration: '3D/2N',
//     rating: 4.7,
//     numberOfRatings: 200,
//     numberOfReviews: 12,
//     peopleLikeRatings: {
//       'Safety and Security': 4.6,
//       'Organizer Manner': 4.5,
//       'Trek Planning': 4.4,
//       'Women Safety': 4.8,
//     },
//     departureDate: '20/07/2025',
//     slotsLeft: 10,
//     boardingPoint: BoardingPoint(
//       location: 'Hyderabad/Bangalore/Vijayawada/Tirupati',
//       time: '6:00:00 PM',
//       date: '01/06',
//       transport: 'Bus',
//     ),
//     cancellationPolicy: defaultCancellationPolicy,
//     otherPolicies: defaultOtherPolicies,
//     itinerary: [
//       DayItinerary(
//         day: 1,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           'Mysore Marvels & Ooty Oasis*',
//           'Reach Mysore & Basic Freshen Up',
//           'Visit Mysore Palace',
//           'Drive through Bandipur Forest & Spot Wildlife',
//           'Eucalyptus Forest & Nilgiris View',
//         ],
//       ),
//       DayItinerary(
//         day: 2,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           'Coonoor Charms & Ooty Odyssey*',
//           'Toy Train from Ooty to Coonoor',
//           'Dolphin Nose View Point',
//           'Tea Factory & Tea Gardens',
//           'Visit Doddabetta Peak',
//           'Ooty Boat House',
//         ],
//       ),
//       DayItinerary(
//         day: 3,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           'Pine Forest & Nature\'s Bounty*',
//           'Shooting Point',
//           'Valley View Point',
//           'Chamundi Hills (If Only Time Permits)',
//           'Reach Station and board return train to base city.',
//         ],
//       ),
//     ],
//     trekRoute: [
//       TrekRouteStop(
//         time: '08:00 AM',
//         date: '01/06',
//         location: 'Hyderabad/Bangalore/Vijayawada/Tirupati',
//         transport: 'Train',
//       ),
//       TrekRouteStop(
//         time: '12:00 PM',
//         date: '01/06',
//         location: 'Mysore',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '02:00 PM',
//         date: '02/06',
//         location: 'Coonoor',
//         transport: 'Toy Train',
//       ),
//       TrekRouteStop(
//         time: '12:00 PM',
//         date: '01/06',
//         location: 'Ooty',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '12:00 PM',
//         date: '01/06',
//         location: 'Mysore',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '08:00 AM',
//         date: '01/06',
//         location: 'Hyderabad/Vijayawada/Tirupati',
//         transport: 'Train',
//       ),
//     ],
//     activities: [
//       'Mysore Marvels & Ooty Oasis',
//       'Mysore Palace',
//       'Bandipur Forest & Spot Wildlife',
//       'Eucalyptus Forest & Nilgiris View',
//       'Coonoor Charms & Ooty Odyssey',
//       'Toy Train from Ooty to Coonoor',
//       'Dolphin Nose View Point',
//       'Tea Factory & Tea Gardens',
//       'Visit Doddabetta Peak',
//       'Ooty Boat House',
//       'Pine Forest & Nature\'s Bounty*',
//       'Shooting Point',
//       'Valley View Point',
//       'Chamundi Hills (If Only Time Permits)'
//     ],
//     reviews: [],
//     resorts: [],
//     inclusions: [
//       '✅ Train tickets (to and from) (or) Semi Sleeper Bus',
//       '✅ Accommodation (4 sharing rooms)',
//       '✅ Local transportation for 3 days',
//       '✅ Trip guide charges',
//       '✅ All Permits, Taxes',
//       '✅ Tolls, Parking, Driver Allowances',
//       '✅ Basic First Aid',
//     ],
//     exclusions: [
//       '❌ Food',
//       '❌ Personal expenses such as shopping.',
//       '❌ Entry tickets (Toy Train, Mysore Palace etc.,)',
//       '❌ Other expenses not mentioned in the inclusions.'
//     ],
//     imageUrls: [],
//   ),
//   Trek(
//     name: 'Munnar',
//     subtitle: 'Coorg | 11 Days',
//     imagePath: CommonImages.logo,
//     price: '₹8,999',
//     duration: '3D/2N',
//     rating: 4.7,
//     numberOfRatings: 200,
//     numberOfReviews: 12,
//     peopleLikeRatings: {
//       'Safety and Security': 4.6,
//       'Organizer Manner': 4.5,
//       'Trek Planning': 4.4,
//       'Women Safety': 4.8,
//     },
//     departureDate: '20/07/2025',
//     slotsLeft: 10,
//     boardingPoint: BoardingPoint(
//       location: 'Hyderabad/Bangalore/Vijayawada',
//       time: '6:00:00 PM',
//       date: '01/06',
//       transport: 'Bus',
//     ),
//     cancellationPolicy: defaultCancellationPolicy,
//     otherPolicies: defaultOtherPolicies,
//     itinerary: [
//       DayItinerary(
//         day: 1,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           '📍 8:00 AM - Reach Coimbatore Railway Station.',
//           '⛲ Proceed to Munnar.',
//           '🥘 Drive through Chinna Wildlife Sanctuary🏕️ Lakkom waterfalls',
//           '🏕️ Botanical Garden',
//           '🌄 Activities (Zipline & Swing)',
//           '🔥 Check into our stay.'
//         ],
//       ),
//       DayItinerary(
//         day: 2,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           '⏰ 5:00 AM - Wake up.',
//           '🥘 Top Station',
//           '📸 Visit Echo Point',
//           '🧷 Proceed to Mattupetty Dam',
//           '📍 Tea Factory & Rose Garden.',
//           '🐘 Proceed to Elephant Camp',
//           '🏖️ Spice Plantation.',
//           '🏬 Check into Stay',
//           '😴 End of the Day.'
//         ],
//       ),
//       DayItinerary(
//         day: 3,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           '🖼️ Gap Road Munnar',
//           '🌟 Idlee Hills',
//           '🌄 Eravikulam National Park',
//           '💫 Start back to Coimbatore & Board the Train',
//         ],
//       ),
//     ],
//     trekRoute: [
//       TrekRouteStop(
//         time: '08:00 AM',
//         date: '01/06',
//         location: 'Hyderabad/Bangalore/Vijayawada',
//         transport: 'Train',
//       ),
//       TrekRouteStop(
//         time: '12:00 PM',
//         date: '01/06',
//         location: 'Coimbatore',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '02:00 PM',
//         date: '02/06',
//         location: 'Munnar',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '12:00 PM',
//         date: '01/06',
//         location: 'Coimbatore',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '08:00 AM',
//         date: '01/06',
//         location: 'Hyderabad/Bangalore/Vijayawada',
//         transport: 'Train',
//       ),
//     ],
//     activities: [
//       'Chinna Wildlife Sanctuary',
//       'Lakkom waterfalls',
//       'Botanical Garden',
//       'Zipline & Swing',
//       'Mattupetty Dam',
//       'Tea Factory & Rose Garden.',
//       'Elephant Camp',
//       'Spice Plantation.',
//       'Gap Road Munnar',
//       'Idlee Hills',
//       'Eravikulam National Park'
//     ],
//     reviews: [
//       Review(
//         userName: 'Rahul Sharma',
//         rating: 2.5,
//         comment: 'Beautiful winter trek with great views!',
//         date: '10/03/2024',
//       ),
//       Review(
//         userName: 'Rahul Sharma',
//         rating: 4.5,
//         comment: 'Beautiful winter trek with great views!',
//         date: '10/03/2024',
//       ),
//       Review(
//         userName: 'Priya Singh',
//         rating: 3.8,
//         comment: 'Beautiful winter trek with great views!',
//         date: '10/03/2024',
//       ),
//     ],
//     resorts: [
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 1,
//         date: '23 Dec',
//         dayName: 'Mon',
//       ),
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 2,
//         date: '24 Dec',
//         dayName: 'Tue',
//       ),
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 3,
//         date: '25 Dec',
//         dayName: 'Wed',
//       ),
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 4,
//         date: '26 Dec',
//         dayName: 'Thu',
//       ),
//     ],
//     inclusions: [
//       '🌟 Train Tickets (up & down)',
//       '🌟Accommodation in 3 star hotels.',
//       '🌟 Breakfast🌟Local Transportation for 3 days',
//       '🌟Toll tax, parking charges.',
//       '🌟Green tax, fuel charges and driver allowances.',
//       '🌟Trip Guide Charges',
//     ],
//     exclusions: [
//       'Meals other than specified.',
//       '🌟Laundry expenses, tips, camera fees or dry clean expenses.',
//       '🌟All Entry Tickets, Activities & Jeep Rides',
//       '🌟All personal expenses.',
//       'Anything not mentioned in the inclusions.'
//     ],
//     imageUrls: [],
//   ),
//   Trek(
//     name: 'Kodaikanal',
//     subtitle: 'Coorg | 11 Days',
//     imagePath: CommonImages.logo,
//     price: '₹8,499',
//     duration: '3D/2N',
//     rating: 4.7,
//     numberOfRatings: 200,
//     numberOfReviews: 12,
//     peopleLikeRatings: {
//       'Safety and Security': 4.6,
//       'Organizer Manner': 4.5,
//       'Trek Planning': 4.4,
//       'Women Safety': 4.8,
//     },
//     departureDate: '20/07/2025',
//     slotsLeft: 10,
//     boardingPoint: BoardingPoint(
//       location: 'Hyderabad/Bangalore/Vijayawada/Tirupati',
//       time: '6:00:00 PM',
//       date: '01/06',
//       transport: 'Bus',
//     ),
//     cancellationPolicy: defaultCancellationPolicy,
//     otherPolicies: defaultOtherPolicies,
//     itinerary: [
//       DayItinerary(
//         day: 1,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           '🚗 Arrive at Coimbatore🚗 Drive to Kodaikanal',
//           '🏞️ Discover Pillar Rocks',
//           '🤫 Marvel at Silent Valley',
//           '🌲 Wander through Pine Forest',
//           '🚣‍♂️ Enjoy Kodai Lake',
//           '🛌 Overnight Stay in Kodaikanal'
//         ],
//       ),
//       DayItinerary(
//         day: 2,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           'Manjummel Day*',
//           '🗣️ Echo your voices at Echo Point',
//           '🦇 Explore Guna Caves',
//           '🚣‍♂️ Coakers Walk',
//           '🌿 Bryant Park',
//           '🛌 Overnight Stay in Kodaikanal',
//         ],
//       ),
//       DayItinerary(
//         day: 3,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           'Return Journey*',
//           '🌿 Visit Dolphins Nose Point',
//           '🌄 Shola Falls',
//           '🚣‍♂️ Vattakanal Falls',
//           '🚍 Travel back to Coimbatore',
//           '👋 Bid farewell with cherished memories'
//         ],
//       ),
//     ],
//     trekRoute: [
//       TrekRouteStop(
//         time: '08:00 AM',
//         date: '01/06',
//         location: 'Hyderabad/Bangalore/Vijayawada/Tirupati',
//         transport: 'Train',
//       ),
//       TrekRouteStop(
//         time: '12:00 PM',
//         date: '01/06',
//         location: 'Coimbatore',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '02:00 PM',
//         date: '02/06',
//         location: 'Kodaikanal',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '12:00 PM',
//         date: '01/06',
//         location: 'Coimbatore',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '08:00 AM',
//         date: '01/06',
//         location: 'Hyderabad/Bangalore/Vijayawada/Tirupati',
//         transport: 'Train',
//       ),
//     ],
//     activities: [
//       'Pillar Rocks',
//       'Marvel at Silent Valley',
//       'Wander through Pine Forest',
//       'Kodai Lake',
//       'Guna Caves',
//       'Coakers Walk',
//       'Bryant Park',
//       'SVisit Dolphins Nose Point',
//       'Shola Falls',
//       '🚣‍♂️ Vattakanal Falls',
//       '🚍 Travel back to Coimbatore'
//     ],
//     reviews: [
//       Review(
//         userName: 'Rahul Sharma',
//         rating: 2.5,
//         comment: 'Beautiful winter trek with great views!',
//         date: '10/03/2024',
//       ),
//       Review(
//         userName: 'Rahul Sharma',
//         rating: 4.5,
//         comment: 'Beautiful winter trek with great views!',
//         date: '10/03/2024',
//       ),
//       Review(
//         userName: 'Priya Singh',
//         rating: 3.8,
//         comment: 'Beautiful winter trek with great views!',
//         date: '10/03/2024',
//       ),
//     ],
//     resorts: [
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 1,
//         date: '23 Dec',
//         dayName: 'Mon',
//       ),
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 2,
//         date: '24 Dec',
//         dayName: 'Tue',
//       ),
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 3,
//         date: '25 Dec',
//         dayName: 'Wed',
//       ),
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 4,
//         date: '26 Dec',
//         dayName: 'Thu',
//       ),
//     ],
//     inclusions: [
//       '✅ Train Tickets (to and from)',
//       '✅ Accommodation (4-sharing rooms)',
//       '✅ Local transportation for 3 days',
//       '✅ Trip guide charges',
//       '✅ Permits, Taxes, Tolls, Parking, Driver Allowances',
//       '✅ Basic First Aid',
//     ],
//     exclusions: [
//       'Other expenses not mentioned in the inclusions.',
//     ],
//     imageUrls: [],
//   ),
//   Trek(
//     name: 'Gokarna Dandeli',
//     subtitle: 'Coorg | 11 Days',
//     imagePath: CommonImages.logo,
//     price: '₹5,999',
//     duration: '3D/2N',
//     rating: 4.7,
//     numberOfRatings: 200,
//     numberOfReviews: 12,
//     peopleLikeRatings: {
//       'Safety and Security': 4.6,
//       'Organizer Manner': 4.5,
//       'Trek Planning': 4.4,
//       'Women Safety': 4.8,
//     },
//     departureDate: '20/07/2025',
//     slotsLeft: 10,
//     boardingPoint: BoardingPoint(
//       location: 'Hyderabad/Bangalore/Vijayawada/Tirupati',
//       time: '6:00:00 PM',
//       date: '01/06',
//       transport: 'Bus',
//     ),
//     cancellationPolicy: defaultCancellationPolicy,
//     otherPolicies: defaultOtherPolicies,
//     itinerary: [
//       DayItinerary(
//         day: 1,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           '🕖 7:00 AM - Arrive at Hubli station.',
//           '🚍 7:30 AM - Board our pre-hired tempo/vehicle',
//           '8:30 AM - Breakfast: Stop at a restaurant to freshen up and enjoy breakfast.\n(No bathing , but bathing is available at the stay by evening',
//           '🌊 Vibhuthi Waterfalls Hike: Explore Vibhuthi Falls with a 20-minute walk. \n(Dresshanging available fort',
//           ' Honnavar Board Walk: Enjoy a 20 min boardwalk in a lush green MangroveForest \n(Backwaters Boat Ride subject to Availability at own cost)',
//           ' 🌅 Murdeshwar Visit: Proceed to Murdeshwar (Pay-and-use washrooms areavailable for bathing if needed',
//           '🏡 Stay Type: Tent stay (3/4 sharing) and basic washrooms. (Rooms on ExtraCharges)'
//         ],
//       ),
//       DayItinerary(
//         day: 2,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           '🕔 7:00 AM - Wake up and get ready.',
//           '🍳 Breakfast: Finish breakfast.',
//           '🚶 Mirjan Fort: Reach Mirjan Fort by 9 AM and spend some time.',
//           '🌲 11:30 AM - Reach Gokarna and Visit Mahabaleshwar Temple',
//           '🌆 1:00 PM - Head to Om Beach and enjoy here for some time.',
//           '🚗 Transfer to Dandeli: Proceed to Dandeli.',
//           '🍱 Lunch: Enjoy lunch on the way.',
//           '🌆 Arrival at Dandeli: Reach Dandeli by 6:30 PM and check into the campings.',
//           '🌌 Evening Activities: Participate in indoor games, rain dance, swimming,campfire, and music',
//           '🏕️ Stay Type: Tent Stay with comfortable beds, pillows, blankets, and basicwashroom'
//         ],
//       ),
//       DayItinerary(
//         day: 3,
//         title: 'Arrival in Gangtok',
//         description: 'Arrive in Gangtok, acclimatization and briefing.',
//         activities: [
//           '🕠 5:30 AM - Wake up: Start your day early.',
//           '🍳 Breakfast: Enjoy breakfast around 9:00 AM.',
//           '🚣 Water Activities: Participate in adventure water sports including \n kayaking, raftboating, zorbing, zipline, and River Rafting (depending on the water level).',
//           '🍱 Lunch: Finish lunch and check out from your stay.',
//           '🚌 Transfer to Hubballi: Proceed to Hubballi.',
//           '🚂 Boarding: Reach Hubli and board the train/bus',
//           '🏡 Return: Reach your origin city on next day morning, refreshed and withwonderful memories'
//         ],
//       ),
//     ],
//     trekRoute: [
//       TrekRouteStop(
//         time: '08:00 AM',
//         date: '01/06',
//         location: 'Hyderabad/Bangalore/Vijayawada/Tirupati',
//         transport: 'Train',
//       ),
//       TrekRouteStop(
//         time: '12:00 PM',
//         date: '01/06',
//         location: 'Hubli',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '02:00 PM',
//         date: '02/06',
//         location: 'Murdeshwar',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '12:00 PM',
//         date: '01/06',
//         location: 'Gokarna',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '12:00 PM',
//         date: '01/06',
//         location: 'Dandeli',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '12:00 PM',
//         date: '01/06',
//         location: 'Hubballi',
//         transport: 'Car/Mini bus/Tempo',
//       ),
//       TrekRouteStop(
//         time: '08:00 AM',
//         date: '01/06',
//         location: 'Hyderabad/Bangalore/Vijayawada/Tirupati',
//         transport: 'Train',
//       ),
//     ],
//     activities: [
//       'Vibhuthi Waterfalls Hike',
//       'Honnavar Board Walk',
//       'Mangrove Forest',
//       'Mahabaleshwar Temple',
//       'Om Beach',
//       'indoor games, rain dance, swimming,',
//       'campfire, music and Tent Stay',
//       'kayaking, raft, boating, zorbing, ',
//       'zipline, and River Rafting (depending on the water level)',
//     ],
//     reviews: [
//       Review(
//         userName: 'Rahul Sharma',
//         rating: 2.5,
//         comment: 'Beautiful winter trek with great views!',
//         date: '10/03/2024',
//       ),
//       Review(
//         userName: 'Rahul Sharma',
//         rating: 4.5,
//         comment: 'Beautiful winter trek with great views!',
//         date: '10/03/2024',
//       ),
//       Review(
//         userName: 'Priya Singh',
//         rating: 3.8,
//         comment: 'Beautiful winter trek with great views!',
//         date: '10/03/2024',
//       ),
//     ],
//     resorts: [
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 1,
//         date: '23 Dec',
//         dayName: 'Mon',
//       ),
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 2,
//         date: '24 Dec',
//         dayName: 'Tue',
//       ),
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 3,
//         date: '25 Dec',
//         dayName: 'Wed',
//       ),
//       Resort(
//         name: 'Evoke Lifestyle Candolim',
//         location: '3 star',
//         amenities: ['Wi-Fi', 'Pool', 'Restaurant'],
//         day: 4,
//         date: '26 Dec',
//         dayName: 'Thu',
//       ),
//     ],
//     inclusions: [
//       'Train Tickets To & From',
//       'Local Transportation for 3 days on Tempo',
//       'Food - 3 Meals (1 breakfast, 1 lunch, 1 dinner) on one day at Dandeli',
//       'Accommodation (Camping Tents for 2 Nights)',
//       'Tolls, Parking, Entry Tickets & Guide',
//       'Basic First Aid',
//       'Water activities (kayaking, boating, zorbing, swimming in the resort pool)'
//     ],
//     exclusions: [
//       '➡️ Food that is not mentioned in the inclusions',
//       '➡️ Bus Fare if train tickets are not available',
//       '➡️ Rooms or Couple Rooms',
//       '➡️ Personal expenses and water bottles',
//       '➡️ River rafting, Zipline, Honnavar Boating'
//     ],
//     imageUrls: [],
//   ),
// ];
