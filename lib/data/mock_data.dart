import 'package:flutter/material.dart';
import 'images.dart';
import 'models.dart';

// ---------------------------------------------------------------- categories
const kCategories = <ServiceCategory>[
  ServiceCategory('food', 'Food Delivery', Icons.restaurant_rounded),
  ServiceCategory('hotel', 'Hotel Booking', Icons.king_bed_rounded),
  ServiceCategory('realestate', 'Real Estate', Icons.home_rounded),
  ServiceCategory('bike', 'Bike Taxi', Icons.two_wheeler_rounded),
];

const kWideCategory =
    ServiceCategory('providers', 'Service Providers', Icons.handyman_rounded);

// ---------------------------------------------------------------- food
const kCuisineFilters = [
  'All',
  'North Indian',
  'Chinese',
  'Italian',
  'Continental',
  'Desserts',
];

final kCoupons = <Coupon>[
  const Coupon('SAVE20', '20% off above ₹300', 0, 20, 300),
  const Coupon('FREEDEL', 'Free delivery above ₹500', 50, 0, 500),
  const Coupon('WELCOME50', 'Flat ₹50 off', 50, 0, 0),
];

final _obsidianMenu = <MenuItem>[
  MenuItem(
    id: 'm1',
    name: 'Obsidian Truffle Pasta',
    description: '24-month aged parmesan, white truffle shavings, hand-rolled tagliatelle',
    price: 225,
    image: Img.pasta,
    category: 'Popular',
  ),
  MenuItem(
    id: 'm2',
    name: 'The Horizon Burger',
    description: 'A5 Wagyu, smoked gouda, balsamic onions, brioche bun',
    price: 199,
    image: Img.burger,
    category: 'Popular',
    isVeg: false,
  ),
  MenuItem(
    id: 'm3',
    name: 'Truffle Fries',
    description: 'Triple-cooked, rosemary salt, parmesan dust',
    price: 80,
    image: Img.steak,
    category: 'Starters',
  ),
  MenuItem(
    id: 'm4',
    name: 'Charred Corn Ribs',
    description: 'Chilli butter, lime, cotija cheese',
    price: 149,
    image: Img.platter,
    category: 'Starters',
  ),
  MenuItem(
    id: 'm5',
    name: 'Wood-Fired Lamb Chops',
    description: 'Smoked jus, burnt garlic mash, seasonal greens',
    price: 480,
    image: Img.steak,
    category: 'Mains',
    isVeg: false,
  ),
  MenuItem(
    id: 'm6',
    name: 'Seasonal Harvest Bowl',
    description: 'Roasted roots, quinoa, tahini dressing, toasted seeds',
    price: 265,
    image: Img.saladBowl,
    category: 'Mains',
  ),
  MenuItem(
    id: 'm7',
    name: 'Molten Chocolate Fondant',
    description: 'Salted caramel core, vanilla bean ice cream',
    price: 185,
    image: Img.dessert,
    category: 'Desserts',
  ),
  MenuItem(
    id: 'm8',
    name: 'Red Reserve',
    description: 'House pour, Nashik valley shiraz',
    price: 150,
    image: Img.donuts,
    category: 'Desserts',
  ),
];

final _pastaMenu = <MenuItem>[
  MenuItem(
    id: 'p1',
    name: 'Pesto Farfalle',
    description: 'Basil pesto, sun-dried tomato, pine nuts',
    price: 245,
    image: Img.pasta,
    category: 'Popular',
  ),
  MenuItem(
    id: 'p2',
    name: 'Margherita Verace',
    description: 'San Marzano, fior di latte, 48-hour dough',
    price: 320,
    image: Img.pizza,
    category: 'Popular',
  ),
  MenuItem(
    id: 'p3',
    name: 'Burrata & Heirloom',
    description: 'Puglian burrata, heirloom tomato, aged balsamic',
    price: 290,
    image: Img.saladBowl,
    category: 'Starters',
  ),
  MenuItem(
    id: 'p4',
    name: 'Tiramisu Classico',
    description: 'Mascarpone, espresso-soaked savoiardi, cocoa',
    price: 190,
    image: Img.dessert,
    category: 'Desserts',
  ),
];

final _windyMenu = <MenuItem>[
  MenuItem(
    id: 'w1',
    name: 'Butter Chicken Dhaba',
    description: 'Slow-simmered tomato gravy, kasuri methi, cream',
    price: 310,
    image: Img.curry,
    category: 'Popular',
    isVeg: false,
  ),
  MenuItem(
    id: 'w2',
    name: 'Paneer Tikka Platter',
    description: 'Charcoal grilled, mint chutney, pickled onion',
    price: 280,
    image: Img.platter,
    category: 'Popular',
  ),
  MenuItem(
    id: 'w3',
    name: 'Dal Makhani',
    description: 'Twelve-hour black lentils, white butter finish',
    price: 230,
    image: Img.curry,
    category: 'Mains',
  ),
  MenuItem(
    id: 'w4',
    name: 'Gulab Jamun Trio',
    description: 'Warm, saffron syrup, rose petal',
    price: 120,
    image: Img.donuts,
    category: 'Desserts',
  ),
];

final kRestaurants = <Restaurant>[
  Restaurant(
    id: 'r1',
    name: 'The Obsidian Grill',
    cuisine: 'Modern American • Seasonal • Wood-fired',
    rating: 4.9,
    deliveryTime: '25-35 min',
    costForTwo: 250,
    image: Img.restaurant1,
    tags: ['Continental', 'All'],
    badge: 'Crowd Favorite',
    menu: _obsidianMenu,
  ),
  Restaurant(
    id: 'r2',
    name: 'Pasta Paradise',
    cuisine: 'Authentic Italian • Fresh Pasta • Wine',
    rating: 4.7,
    deliveryTime: '30-40 min',
    costForTwo: 600,
    image: Img.restaurant2,
    tags: ['Italian', 'All'],
    menu: _pastaMenu,
  ),
  Restaurant(
    id: 'r3',
    name: 'The Windy Grill',
    cuisine: 'Modern Indian • Seasonal • Tandoor',
    rating: 4.8,
    deliveryTime: '20-30 min',
    costForTwo: 450,
    image: Img.restaurant3,
    tags: ['North Indian', 'All'],
    badge: 'Trending',
    menu: _windyMenu,
  ),
  Restaurant(
    id: 'r4',
    name: 'Lotus & Lantern',
    cuisine: 'Pan Asian • Dim Sum • Wok',
    rating: 4.6,
    deliveryTime: '35-45 min',
    costForTwo: 520,
    image: Img.restaurant4,
    tags: ['Chinese', 'All'],
    menu: _pastaMenu,
  ),
  Restaurant(
    id: 'r5',
    name: 'Brew & Butter',
    cuisine: 'Cafe • Bakes • All-day Breakfast',
    rating: 4.5,
    deliveryTime: '15-25 min',
    costForTwo: 300,
    image: Img.restaurant5,
    tags: ['Desserts', 'All'],
    menu: _windyMenu,
  ),
  Restaurant(
    id: 'r6',
    name: 'Saffron House',
    cuisine: 'Awadhi • Biryani • Kebabs',
    rating: 4.4,
    deliveryTime: '30-40 min',
    costForTwo: 400,
    image: Img.restaurant6,
    tags: ['North Indian', 'All'],
    menu: _windyMenu,
  ),
];

// ---------------------------------------------------------------- hotels
const kHotelFilters = ['All', 'Luxury', 'Boutique', 'Resort', 'Heritage'];

final kHotels = <Hotel>[
  Hotel(
    id: 'h1',
    name: 'Skyline Grand Hotel',
    category: 'Luxury',
    rating: 4.9,
    reviews: 1548,
    location: 'Downtown',
    distance: '1.2 km from center',
    pricePerNight: 7999,
    image: Img.hotel1,
    gallery: [Img.hotel1, Img.hotelRoom, Img.spa, Img.beach],
    amenities: ['Free WiFi', 'Pool', 'Spa', 'Breakfast'],
    tagline: 'Timeless Elegance in the Heart of the City',
    description:
        'Perched above the city skyline, Skyline Grand pairs a quiet, considered '
        'calm with the energy of downtown. Rooms are designed around long views, '
        'deep soaking tubs and a bed you will not want to leave. The rooftop pool '
        'stays open until midnight.',
    discountPercent: 10,
  ),
  Hotel(
    id: 'h2',
    name: 'Ocean View Resort',
    category: 'Resort',
    rating: 4.7,
    reviews: 982,
    location: 'Coastline',
    distance: '6.4 km from center',
    pricePerNight: 12000,
    image: Img.hotel2,
    gallery: [Img.hotel2, Img.beach, Img.seaNight, Img.spa],
    amenities: ['Private Beach', 'Bar', 'Surf Club', 'Spa'],
    tagline: 'Where the Day Starts and Ends with the Sea',
    description:
        'A low-slung resort built along a private stretch of sand. Mornings are '
        'for the surf club, afternoons for the shaded cabanas, and evenings for '
        'the bar that leans right out over the water.',
    discountPercent: 15,
  ),
  Hotel(
    id: 'h3',
    name: 'Urban Stay Heritage',
    category: 'Heritage',
    rating: 4.5,
    reviews: 431,
    location: 'Downtown',
    distance: '1.2 km from center',
    pricePerNight: 3200,
    image: Img.hotel3,
    gallery: [Img.hotel3, Img.interior3, Img.hotelRoom],
    amenities: ['Free WiFi', 'Heritage Walk', 'Courtyard'],
    tagline: 'A Restored Haveli, Still Keeping Its Secrets',
    description:
        'Four generations of a trading family lived here before it opened its '
        'doors as a hotel. The carved jharokhas, the stepwell courtyard and the '
        'hand-set floor tiles are all original.',
  ),
  Hotel(
    id: 'h4',
    name: 'Azure Bay Resort',
    category: 'Luxury',
    rating: 4.9,
    reviews: 1203,
    location: 'Amalfi, Italy',
    distance: '2.0 km from center',
    pricePerNight: 850,
    image: Img.hotel4,
    gallery: [Img.hotel4, Img.beach, Img.hotelRoom, Img.seaNight],
    amenities: ['Ocean Suite', 'Infinity Pool', 'Breakfast', 'Concierge'],
    tagline: 'Timeless Elegance and Coastal Serenity',
    description:
        'Perched on the dramatic limestone cliffs of the Amalfi Coast, Azure Bay '
        'offers a sanctuary of refined luxury. Designed with a meticulous eye for '
        'detail, the suite harmonizes modern comfort with heritage Italian '
        'craftsmanship. Every window frames a different piece of the sea.',
    discountPercent: 10,
  ),
  Hotel(
    id: 'h5',
    name: 'The Quiet Boutique',
    category: 'Boutique',
    rating: 4.6,
    reviews: 288,
    location: 'Old Quarter',
    distance: '0.6 km from center',
    pricePerNight: 4600,
    image: Img.restaurant4,
    gallery: [Img.restaurant4, Img.interior1, Img.hotelRoom],
    amenities: ['Library Bar', 'Free WiFi', 'Breakfast'],
    tagline: 'Eleven Rooms, No Two Alike',
    description:
        'An eleven-room house on a lane too narrow for cars. Breakfast is served '
        'whenever you come down, and the library bar runs on the honour system.',
  ),
];

// ---------------------------------------------------------------- real estate
const kPropertyFilters = ['All', 'For Sale', 'For Rent', 'Premium', 'New'];

final kProperties = <Property>[
  Property(
    id: 'pr1',
    name: 'Lakeside Manor',
    location: 'Winnetka, IL',
    price: 12000000,
    beds: 5,
    baths: 6,
    area: 6800,
    image: Img.property1,
    gallery: [Img.property1, Img.interior1, Img.interior2, Img.interior3],
    tags: ['Premium', 'For Sale', 'All'],
    description:
        'A lakefront manor with its own boat dock, a double-height great room and '
        'a kitchen built for people who actually cook. The gardens were laid out '
        'in 1948 and have been kept almost unchanged.',
  ),
  Property(
    id: 'pr2',
    name: 'Elysian Vista Villa',
    location: 'Beverly Hills, CA',
    price: 42500000,
    beds: 4,
    baths: 5,
    area: 5200,
    image: Img.property2,
    gallery: [Img.property2, Img.interior2, Img.interior1],
    tags: ['Premium', 'For Sale', 'All'],
    description:
        'Glass on three sides, canyon views from every room, and a pool that '
        'disappears into the hillside. Fully automated, move-in ready.',
  ),
  Property(
    id: 'pr3',
    name: 'Azure Coastal Estate',
    location: 'Malibu, CA',
    price: 89000000,
    beds: 6,
    baths: 8,
    area: 12400,
    image: Img.property3,
    gallery: [Img.property3, Img.interior3, Img.interior1],
    tags: ['Premium', 'For Sale', 'All', 'New'],
    description:
        'A twelve-thousand square foot estate on a private bluff, with direct '
        'beach steps, a guest wing and a twenty-car motor court.',
  ),
  Property(
    id: 'pr4',
    name: 'The Nordic Sanctuary',
    location: 'Aspen, Colorado',
    price: 19000000,
    beds: 4,
    baths: 4,
    area: 4100,
    image: Img.property4,
    gallery: [Img.property4, Img.interior2],
    tags: ['For Sale', 'All'],
    description:
        'Blackened timber, warm oak inside, and a wall of glass pointed straight '
        'at the ridge. Ski-in, ski-out from the lower terrace.',
  ),
  Property(
    id: 'pr5',
    name: 'The Glass Pavilion',
    location: 'Skyline District, North Tower',
    price: 15500000,
    beds: 3,
    baths: 3,
    area: 3200,
    image: Img.property6,
    gallery: [Img.property6, Img.interior1, Img.cityscape],
    tags: ['Premium', 'For Sale', 'All', 'New'],
    description:
        'A residential pavilion on the thirty-first floor, wrapped in floor-to-'
        'ceiling glass with a private lift lobby and a concierge who remembers '
        'your coffee order.',
  ),
  Property(
    id: 'pr6',
    name: 'Azure Heights Estate',
    location: 'Malibu, California',
    price: 76000000,
    beds: 5,
    baths: 7,
    area: 9800,
    image: Img.property7,
    gallery: [Img.property7, Img.interior3],
    tags: ['Premium', 'For Sale', 'All'],
    description:
        'Set into the hillside with a cantilevered terrace, an outdoor kitchen '
        'and a lap pool that runs the length of the house.',
  ),
  Property(
    id: 'pr7',
    name: 'Luxury Loft, West Loop',
    location: 'West Loop, Chicago',
    price: 0,
    beds: 2,
    baths: 2,
    area: 1200,
    image: Img.interior1,
    gallery: [Img.interior1, Img.interior2],
    tags: ['For Rent', 'All'],
    description:
        'An exposed-brick loft in a converted printing house. Two bedrooms, a '
        'twenty-foot ceiling and a freight lift that still works.',
    forRent: true,
    monthlyRent: 3200,
    configuration: '2 BHK • 1,200 sqft',
  ),
  Property(
    id: 'pr8',
    name: 'Riverfront Residences',
    location: 'Sector 150, Noida',
    price: 0,
    beds: 3,
    baths: 3,
    area: 1850,
    image: Img.property9,
    gallery: [Img.property9, Img.interior2],
    tags: ['For Rent', 'All', 'New'],
    description:
        'A three-bedroom in a riverside tower with a wrap-around balcony, covered '
        'parking and a club floor on level twenty.',
    forRent: true,
    monthlyRent: 58000,
    configuration: '3 BHK • 1,850 sqft',
  ),
];

// ---------------------------------------------------------------- providers
const kProviderFilters = [
  'All Services',
  'Electricians',
  'Plumbers',
  'Mechanics',
  'Salon',
  'Cleaning',
  'Fitness',
];

const _reviewsA = <Review>[
  Review(
    'Suraj Kumar',
    '2 days ago',
    5,
    'Provided exceptional clarity on our complex requirements. The solutions '
        'saved us weeks in delays. Highly recommend for any project!',
  ),
  Review(
    'Priya Sharma',
    '1 week ago',
    4.5,
    'Very professional and punctual. Work was completed to a high standard and '
        'the pricing was fair. Would definitely use again.',
  ),
  Review(
    'Aman Verma',
    '3 weeks ago',
    5,
    'Turned up on a Sunday at short notice and sorted the whole panel. '
        'Explained everything without the usual upselling.',
  ),
];

final kProviders = <ServicePro>[
  ServicePro(
    id: 'sp1',
    name: 'Ramesh Chand',
    profession: 'Master Electrician',
    category: 'Electricians',
    professionColor: const Color(0xFF7A4F00),
    rating: 4.9,
    reviews: 134,
    years: 12,
    distance: 2.4,
    photo: Img.man1,
    about:
        'With over 12 years of experience in high-quality residential and '
        'commercial services, Ramesh Chand has established a reputation for '
        'excellence and reliability. Known for combining technical expertise with '
        'strong customer communication, every project is handled with precision '
        'and care.\n\nRamesh Chand holds professional certifications and regularly '
        'updates skills to meet modern standards. The focus is on delivering '
        'lasting solutions that exceed client expectations while staying within '
        'budget.',
    expertise: [
      Expertise('Wiring & Panels', Icons.electrical_services_rounded),
      Expertise('Light Fitting', Icons.lightbulb_outline_rounded),
      Expertise('Safety Audit', Icons.verified_user_outlined),
      Expertise('Solar Install', Icons.solar_power_rounded),
      Expertise('Maintenance', Icons.settings_rounded),
      Expertise('Estimations', Icons.receipt_long_rounded),
    ],
    email: 'ramesh.chand@pro.com',
    phone: '+91 98176 04512',
    office: 'Sector 10, Ghaziabad',
    operatingArea: 'Ghaziabad, Noida & Delhi NCR — covers a 25 km radius',
    testimonials: _reviewsA,
  ),
  ServicePro(
    id: 'sp2',
    name: 'Reema Kapoor',
    profession: 'Hair & Style Specialist',
    category: 'Salon',
    professionColor: const Color(0xFFC2185B),
    rating: 4.8,
    reviews: 207,
    years: 8,
    distance: 0.8,
    photo: Img.woman1,
    about:
        'Eight years behind the chair, trained in London and Mumbai, with a '
        'particular love for precision cuts and colour correction. Reema runs a '
        'small studio and keeps the appointment book deliberately short so every '
        'client gets unhurried time.',
    expertise: [
      Expertise('Precision Cuts', Icons.content_cut_rounded),
      Expertise('Colour', Icons.palette_outlined),
      Expertise('Bridal', Icons.favorite_outline_rounded),
      Expertise('Keratin', Icons.auto_awesome_outlined),
      Expertise('Styling', Icons.brush_outlined),
      Expertise('Consults', Icons.chat_bubble_outline_rounded),
    ],
    email: 'reema@studio.co',
    phone: '+91 99103 22847',
    office: 'Hauz Khas Village, New Delhi',
    operatingArea: 'South Delhi — studio visits and at-home appointments',
    testimonials: _reviewsA,
  ),
  ServicePro(
    id: 'sp3',
    name: 'Musafir Ali',
    profession: 'Lead Mechanic',
    category: 'Mechanics',
    professionColor: const Color(0xFF15803D),
    rating: 5.0,
    reviews: 98,
    years: 15,
    distance: 4.1,
    photo: Img.man3,
    about:
        'Fifteen years on engines of every description, from scooters to imported '
        'saloons. Musafir runs a two-bay workshop and will always show you the '
        'old part before fitting the new one.',
    expertise: [
      Expertise('Diagnostics', Icons.build_circle_outlined),
      Expertise('Engine Work', Icons.settings_suggest_rounded),
      Expertise('Brakes', Icons.disc_full_outlined),
      Expertise('Electricals', Icons.bolt_rounded),
      Expertise('Detailing', Icons.local_car_wash_outlined),
      Expertise('Pickup', Icons.local_shipping_outlined),
    ],
    email: 'musafir.works@pro.com',
    phone: '+91 97119 55012',
    office: 'Mohan Nagar, Ghaziabad',
    operatingArea: 'Ghaziabad & East Delhi — free pickup within 10 km',
    testimonials: _reviewsA,
  ),
  ServicePro(
    id: 'sp4',
    name: 'Shahdab Khan',
    profession: 'Plumbing Specialist',
    category: 'Plumbers',
    professionColor: const Color(0xFF7C3AED),
    rating: 4.7,
    reviews: 162,
    years: 6,
    distance: 1.5,
    photo: Img.man5,
    about:
        'Six years of residential and light commercial plumbing, with a focus on '
        'leak detection and bathroom refits. Shahdab carries his own camera scope '
        'so there is no guesswork and no unnecessary breaking of walls.',
    expertise: [
      Expertise('Leak Detection', Icons.water_damage_outlined),
      Expertise('Bath Refits', Icons.bathtub_outlined),
      Expertise('Water Tanks', Icons.water_drop_outlined),
      Expertise('Drainage', Icons.plumbing_rounded),
      Expertise('Geysers', Icons.hot_tub_rounded),
      Expertise('Estimations', Icons.receipt_long_rounded),
    ],
    email: 'shahdab.plumb@pro.com',
    phone: '+91 98730 11094',
    office: 'Indirapuram, Ghaziabad',
    operatingArea: 'Indirapuram, Vaishali & Noida — same-day callouts',
    testimonials: _reviewsA,
  ),
  ServicePro(
    id: 'sp5',
    name: 'Anita Desai',
    profession: 'Deep Clean Lead',
    category: 'Cleaning',
    professionColor: const Color(0xFF0E7490),
    rating: 4.8,
    reviews: 311,
    years: 9,
    distance: 3.2,
    photo: Img.woman4,
    about:
        'Anita leads a four-person team that handles move-in deep cleans, post-'
        'renovation clearing and recurring home contracts. Everything is quoted '
        'per room, in writing, before anyone starts.',
    expertise: [
      Expertise('Deep Clean', Icons.cleaning_services_rounded),
      Expertise('Sofa & Rug', Icons.weekend_outlined),
      Expertise('Kitchen', Icons.kitchen_outlined),
      Expertise('Sanitising', Icons.sanitizer_outlined),
      Expertise('Move-in', Icons.moving_rounded),
      Expertise('Contracts', Icons.event_repeat_rounded),
    ],
    email: 'anita@spotless.in',
    phone: '+91 90045 77123',
    office: 'Sector 62, Noida',
    operatingArea: 'Noida & Greater Noida — teams of two to six',
    testimonials: _reviewsA,
  ),
  ServicePro(
    id: 'sp6',
    name: 'Karan Mehta',
    profession: 'Strength & Mobility Coach',
    category: 'Fitness',
    professionColor: const Color(0xFFB45309),
    rating: 4.9,
    reviews: 76,
    years: 7,
    distance: 2.0,
    photo: Img.man4,
    about:
        'Karan works with desk-bound clients on getting strong without getting '
        'hurt. Sessions are one-to-one, programmed in six-week blocks, at your '
        'home or at a partner gym.',
    expertise: [
      Expertise('Strength', Icons.fitness_center_rounded),
      Expertise('Mobility', Icons.accessibility_new_rounded),
      Expertise('Rehab', Icons.healing_rounded),
      Expertise('Nutrition', Icons.restaurant_menu_rounded),
      Expertise('Assessment', Icons.monitor_heart_outlined),
      Expertise('Programming', Icons.calendar_month_rounded),
    ],
    email: 'karan@movewell.fit',
    phone: '+91 98111 44320',
    office: 'Greater Kailash II, New Delhi',
    operatingArea: 'South & Central Delhi — home and gym sessions',
    testimonials: _reviewsA,
  ),
  ServicePro(
    id: 'sp7',
    name: 'Vikram Sethi',
    profession: 'Senior Electrician',
    category: 'Electricians',
    professionColor: const Color(0xFF7A4F00),
    rating: 4.6,
    reviews: 89,
    years: 10,
    distance: 5.3,
    photo: Img.man7,
    about:
        'Ten years of commercial fit-outs and panel work, with a side speciality '
        'in backup power. Vikram handles load calculations and inverter sizing '
        'himself rather than passing it to a vendor.',
    expertise: [
      Expertise('Panels', Icons.electrical_services_rounded),
      Expertise('Inverters', Icons.battery_charging_full_rounded),
      Expertise('Load Calc', Icons.calculate_outlined),
      Expertise('Fit-outs', Icons.store_mall_directory_outlined),
      Expertise('Safety Audit', Icons.verified_user_outlined),
      Expertise('AMC', Icons.event_repeat_rounded),
    ],
    email: 'vikram.sethi@pro.com',
    phone: '+91 99580 61233',
    office: 'Okhla Phase II, New Delhi',
    operatingArea: 'Delhi NCR — commercial contracts and AMCs',
    testimonials: _reviewsA,
  ),
  ServicePro(
    id: 'sp8',
    name: 'Neha Bansal',
    profession: 'Plumbing & Fittings',
    category: 'Plumbers',
    professionColor: const Color(0xFF7C3AED),
    rating: 4.7,
    reviews: 54,
    years: 5,
    distance: 1.1,
    photo: Img.woman5,
    about:
        'One of the few women running her own plumbing crew in the city. Neha '
        'took over the family business in 2020 and now handles bathroom refits '
        'and apartment-block maintenance contracts.',
    expertise: [
      Expertise('Refits', Icons.bathtub_outlined),
      Expertise('Leak Repair', Icons.water_damage_outlined),
      Expertise('Fittings', Icons.plumbing_rounded),
      Expertise('Pumps', Icons.water_drop_outlined),
      Expertise('AMC', Icons.event_repeat_rounded),
      Expertise('Estimations', Icons.receipt_long_rounded),
    ],
    email: 'neha@bansalplumbing.in',
    phone: '+91 98219 30077',
    office: 'Rajnagar Extension, Ghaziabad',
    operatingArea: 'Ghaziabad — apartment blocks and individual homes',
    testimonials: _reviewsA,
  ),
];

// ---------------------------------------------------------------- bookings
final kBookings = <Booking>[
  Booking(
    id: 'b1',
    title: 'Azure Bay Resort',
    subtitle: 'Ocean Suite • 2 Adults, 1 Child',
    kind: 'Luxury Stay',
    when: 'Oct 24 - Oct 28, 2024',
    status: BookingStatus.confirmed,
    image: Img.hotel4,
    location: 'Amalfi, Italy',
    reference: '#AB-992384',
  ),
  Booking(
    id: 'b2',
    title: 'Celestial Zen Spa',
    subtitle: 'Signature 90-minute ritual',
    kind: 'Wellness',
    when: 'Oct 26, 2024 • 2:00 PM',
    status: BookingStatus.confirmed,
    image: Img.spa,
    reference: '#CZ-441028',
  ),
  Booking(
    id: 'b3',
    title: 'The Gilded Table',
    subtitle: 'Table for 4 • Terrace',
    kind: 'Dining',
    when: 'Oct 25, 2024 • 8:30 PM',
    status: BookingStatus.processing,
    image: Img.restaurant3,
    reference: '#GT-778210',
  ),
  Booking(
    id: 'b4',
    title: 'Ramesh Chand',
    subtitle: 'Panel inspection & rewiring quote',
    kind: 'Home Service',
    when: 'Oct 22, 2024 • 11:00 AM',
    status: BookingStatus.completed,
    image: Img.electrician,
    reference: '#RC-120934',
  ),
];

const kTravelerTip =
    'You have a 4-hour gap between your Spa session and Dinner. We recommend '
    'the coastal walk via Path of the Gods.';

// ---------------------------------------------------------------- offers
final kOffers = <Offer>[
  Offer(
    code: 'SAVE20',
    title: '20% off your food order',
    subtitle: 'On orders above ₹300. Valid at all partner restaurants.',
    image: Img.platter,
    colors: const [Color(0xFF7A4F00), Color(0xFFA16207)],
    validTill: 'Valid till 31 Dec',
  ),
  Offer(
    code: 'STAY15',
    title: 'Flat 15% off hotel stays',
    subtitle: 'Minimum two nights. Excludes peak dates.',
    image: Img.hotel2,
    colors: const [Color(0xFF0E7490), Color(0xFF22D3EE)],
    validTill: 'Valid till 15 Jan',
  ),
  Offer(
    code: 'RIDE50',
    title: '₹50 off your next 5 rides',
    subtitle: 'Bike taxi and e-rickshaw. New riders only.',
    image: Img.motorcycle,
    colors: const [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    validTill: 'Valid till 30 Nov',
  ),
  Offer(
    code: 'FIXIT',
    title: 'First home service free callout',
    subtitle: 'Waived visit charge on electricians and plumbers.',
    image: Img.electrician,
    colors: const [Color(0xFFB45309), Color(0xFFF59E0B)],
    validTill: 'Valid till 28 Feb',
  ),
];

// ---------------------------------------------------------------- bike taxi
//
// `RideOption` itself lives in `models.dart`: these are the bundled defaults
// the app falls back to when `/config` cannot be reached.
const kRideOptions = <RideOption>[
  RideOption(
    id: 'bike',
    title: 'Bike taxi',
    subtitle: 'Fastest in traffic',
    icon: Icons.two_wheeler_rounded,
    color: Color(0xFF7A4F00),
    eta: '3 min away',
    pricePerKm: 8,
  ),
  RideOption(
    id: 'erickshaw',
    title: 'E-rickshaw',
    subtitle: 'Cheaper and Reliable',
    icon: Icons.electric_rickshaw,
    color: Color(0xFF16A34A),
    eta: '6 min away',
    pricePerKm: 6,
  ),
  RideOption(
    id: 'parcel',
    title: 'Parcel',
    subtitle: 'Send Anything',
    icon: Icons.inventory_2_outlined,
    color: Color(0xFFDC2626),
    eta: '5 min away',
    pricePerKm: 10,
  ),
  RideOption(
    id: 'cab',
    title: 'Cab',
    subtitle: 'Comfortable, AC',
    icon: Icons.local_taxi_rounded,
    color: Color(0xFFB45309),
    eta: '8 min away',
    pricePerKm: 14,
  ),
];

const kSavedPlaces = <SavedPlace>[
  SavedPlace(
    id: 'home',
    icon: Icons.home_rounded,
    label: 'Home',
    address: 'Diya Green City, Rajnagar Extension',
  ),
  SavedPlace(
    id: 'work',
    icon: Icons.work_rounded,
    label: 'Work',
    address: 'Sector 62, Noida \u2022 Block B',
  ),
  SavedPlace(
    id: 'airport',
    icon: Icons.flight_rounded,
    label: 'Airport',
    address: 'IGI Terminal 3, New Delhi',
  ),
];

// ---------------------------------------------------------------- config

/// The taxonomy the app ships with, used until `/config` answers and
/// whenever it cannot be reached.
const kBundledConfig = AppConfig(
  categories: kCategories,
  wideCategory: kWideCategory,
  savedPlaces: kSavedPlaces,
  rideOptions: kRideOptions,
  filters: {
    FilterGroup.cuisine: kCuisineFilters,
    FilterGroup.hotel: kHotelFilters,
    FilterGroup.property: kPropertyFilters,
    FilterGroup.provider: kProviderFilters,
  },
  travelerTip: kTravelerTip,
);
