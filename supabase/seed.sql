-- Namaste Tripathi — catalogue seed.
--
-- Mirrors lib/data/mock_data.dart so the app looks identical whether it is
-- reading from Supabase or falling back to the bundled catalogue. Image
-- values are bundled asset paths; swap them for Storage URLs when the
-- artwork moves to a bucket.
--
-- Safe to re-run: every insert upserts on its primary key.

-- ---------------------------------------------------------------- coupons
insert into public.coupons (code, description, flat, percent, min_order, sort_order) values
  ('SAVE20',    '20% off above ₹300',        0,  20, 300, 1),
  ('FREEDEL',   'Free delivery above ₹500',  50,  0, 500, 2),
  ('WELCOME50', 'Flat ₹50 off',              50,  0,   0, 3)
on conflict (code) do update set
  description = excluded.description, flat = excluded.flat,
  percent = excluded.percent, min_order = excluded.min_order,
  sort_order = excluded.sort_order;

-- ---------------------------------------------------------------- restaurants
insert into public.restaurants
  (id, name, cuisine, rating, delivery_time, cost_for_two, image, tags, free_delivery, badge, sort_order) values
  ('r1', 'The Obsidian Grill', 'Modern American • Seasonal • Wood-fired', 4.9, '25-35 min', 250,
   'assets/images/restaurant1.jpg', array['Continental','All'], true, 'Crowd Favorite', 1),
  ('r2', 'Pasta Paradise', 'Authentic Italian • Fresh Pasta • Wine', 4.7, '30-40 min', 600,
   'assets/images/restaurant2.jpg', array['Italian','All'], true, null, 2),
  ('r3', 'The Windy Grill', 'Modern Indian • Seasonal • Tandoor', 4.8, '20-30 min', 450,
   'assets/images/restaurant3.jpg', array['North Indian','All'], true, 'Trending', 3),
  ('r4', 'Lotus & Lantern', 'Pan Asian • Dim Sum • Wok', 4.6, '35-45 min', 520,
   'assets/images/restaurant4.jpg', array['Chinese','All'], true, null, 4),
  ('r5', 'Brew & Butter', 'Cafe • Bakes • All-day Breakfast', 4.5, '15-25 min', 300,
   'assets/images/restaurant5.jpg', array['Desserts','All'], true, null, 5),
  ('r6', 'Saffron House', 'Awadhi • Biryani • Kebabs', 4.4, '30-40 min', 400,
   'assets/images/restaurant6.jpg', array['North Indian','All'], true, null, 6)
on conflict (id) do update set
  name = excluded.name, cuisine = excluded.cuisine, rating = excluded.rating,
  delivery_time = excluded.delivery_time, cost_for_two = excluded.cost_for_two,
  image = excluded.image, tags = excluded.tags,
  free_delivery = excluded.free_delivery, badge = excluded.badge,
  sort_order = excluded.sort_order;

-- ---------------------------------------------------------------- menu items
insert into public.menu_items
  (id, restaurant_id, name, description, price, image, category, is_veg, sort_order) values
  -- The Obsidian Grill
  ('m1', 'r1', 'Obsidian Truffle Pasta', '24-month aged parmesan, white truffle shavings, hand-rolled tagliatelle', 225, 'assets/images/pasta.jpg', 'Popular', true, 1),
  ('m2', 'r1', 'The Horizon Burger', 'A5 Wagyu, smoked gouda, balsamic onions, brioche bun', 199, 'assets/images/burger.jpg', 'Popular', false, 2),
  ('m3', 'r1', 'Truffle Fries', 'Triple-cooked, rosemary salt, parmesan dust', 80, 'assets/images/steak.jpg', 'Starters', true, 3),
  ('m4', 'r1', 'Charred Corn Ribs', 'Chilli butter, lime, cotija cheese', 149, 'assets/images/platter.jpg', 'Starters', true, 4),
  ('m5', 'r1', 'Wood-Fired Lamb Chops', 'Smoked jus, burnt garlic mash, seasonal greens', 480, 'assets/images/steak.jpg', 'Mains', false, 5),
  ('m6', 'r1', 'Seasonal Harvest Bowl', 'Roasted roots, quinoa, tahini dressing, toasted seeds', 265, 'assets/images/saladBowl.jpg', 'Mains', true, 6),
  ('m7', 'r1', 'Molten Chocolate Fondant', 'Salted caramel core, vanilla bean ice cream', 185, 'assets/images/dessert.jpg', 'Desserts', true, 7),
  ('m8', 'r1', 'Red Reserve', 'House pour, Nashik valley shiraz', 150, 'assets/images/donuts.jpg', 'Desserts', true, 8),
  -- Pasta Paradise
  ('p1', 'r2', 'Pesto Farfalle', 'Basil pesto, sun-dried tomato, pine nuts', 245, 'assets/images/pasta.jpg', 'Popular', true, 1),
  ('p2', 'r2', 'Margherita Verace', 'San Marzano, fior di latte, 48-hour dough', 320, 'assets/images/pizza.jpg', 'Popular', true, 2),
  ('p3', 'r2', 'Burrata & Heirloom', 'Puglian burrata, heirloom tomato, aged balsamic', 290, 'assets/images/saladBowl.jpg', 'Starters', true, 3),
  ('p4', 'r2', 'Tiramisu Classico', 'Mascarpone, espresso-soaked savoiardi, cocoa', 190, 'assets/images/dessert.jpg', 'Desserts', true, 4),
  -- The Windy Grill
  ('w1', 'r3', 'Butter Chicken Dhaba', 'Slow-simmered tomato gravy, kasuri methi, cream', 310, 'assets/images/curry.jpg', 'Popular', false, 1),
  ('w2', 'r3', 'Paneer Tikka Platter', 'Charcoal grilled, mint chutney, pickled onion', 280, 'assets/images/platter.jpg', 'Popular', true, 2),
  ('w3', 'r3', 'Dal Makhani', 'Twelve-hour black lentils, white butter finish', 230, 'assets/images/curry.jpg', 'Mains', true, 3),
  ('w4', 'r3', 'Gulab Jamun Trio', 'Warm, saffron syrup, rose petal', 120, 'assets/images/donuts.jpg', 'Desserts', true, 4),
  -- Lotus & Lantern
  ('r4p1', 'r4', 'Pesto Farfalle', 'Basil pesto, sun-dried tomato, pine nuts', 245, 'assets/images/pasta.jpg', 'Popular', true, 1),
  ('r4p2', 'r4', 'Margherita Verace', 'San Marzano, fior di latte, 48-hour dough', 320, 'assets/images/pizza.jpg', 'Popular', true, 2),
  ('r4p3', 'r4', 'Burrata & Heirloom', 'Puglian burrata, heirloom tomato, aged balsamic', 290, 'assets/images/saladBowl.jpg', 'Starters', true, 3),
  ('r4p4', 'r4', 'Tiramisu Classico', 'Mascarpone, espresso-soaked savoiardi, cocoa', 190, 'assets/images/dessert.jpg', 'Desserts', true, 4),
  -- Brew & Butter
  ('r5w1', 'r5', 'Butter Chicken Dhaba', 'Slow-simmered tomato gravy, kasuri methi, cream', 310, 'assets/images/curry.jpg', 'Popular', false, 1),
  ('r5w2', 'r5', 'Paneer Tikka Platter', 'Charcoal grilled, mint chutney, pickled onion', 280, 'assets/images/platter.jpg', 'Popular', true, 2),
  ('r5w3', 'r5', 'Dal Makhani', 'Twelve-hour black lentils, white butter finish', 230, 'assets/images/curry.jpg', 'Mains', true, 3),
  ('r5w4', 'r5', 'Gulab Jamun Trio', 'Warm, saffron syrup, rose petal', 120, 'assets/images/donuts.jpg', 'Desserts', true, 4),
  -- Saffron House
  ('r6w1', 'r6', 'Butter Chicken Dhaba', 'Slow-simmered tomato gravy, kasuri methi, cream', 310, 'assets/images/curry.jpg', 'Popular', false, 1),
  ('r6w2', 'r6', 'Paneer Tikka Platter', 'Charcoal grilled, mint chutney, pickled onion', 280, 'assets/images/platter.jpg', 'Popular', true, 2),
  ('r6w3', 'r6', 'Dal Makhani', 'Twelve-hour black lentils, white butter finish', 230, 'assets/images/curry.jpg', 'Mains', true, 3),
  ('r6w4', 'r6', 'Gulab Jamun Trio', 'Warm, saffron syrup, rose petal', 120, 'assets/images/donuts.jpg', 'Desserts', true, 4)
on conflict (id) do update set
  restaurant_id = excluded.restaurant_id, name = excluded.name,
  description = excluded.description, price = excluded.price,
  image = excluded.image, category = excluded.category,
  is_veg = excluded.is_veg, sort_order = excluded.sort_order;

-- ---------------------------------------------------------------- hotels
insert into public.hotels
  (id, name, category, rating, reviews, location, distance, price_per_night, image,
   gallery, amenities, tagline, description, discount_percent, sort_order) values
  ('h1', 'Skyline Grand Hotel', 'Luxury', 4.9, 1548, 'Downtown', '1.2 km from center', 7999,
   'assets/images/hotel1.jpg',
   array['assets/images/hotel1.jpg','assets/images/hotelRoom.jpg','assets/images/spa.jpg','assets/images/beach.jpg'],
   array['Free WiFi','Pool','Spa','Breakfast'],
   'Timeless Elegance in the Heart of the City',
   'Perched above the city skyline, Skyline Grand pairs a quiet, considered calm with the energy of downtown. Rooms are designed around long views, deep soaking tubs and a bed you will not want to leave. The rooftop pool stays open until midnight.',
   10, 1),
  ('h2', 'Ocean View Resort', 'Resort', 4.7, 982, 'Coastline', '6.4 km from center', 12000,
   'assets/images/hotel2.jpg',
   array['assets/images/hotel2.jpg','assets/images/beach.jpg','assets/images/seaNight.jpg','assets/images/spa.jpg'],
   array['Private Beach','Bar','Surf Club','Spa'],
   'Where the Day Starts and Ends with the Sea',
   'A low-slung resort built along a private stretch of sand. Mornings are for the surf club, afternoons for the shaded cabanas, and evenings for the bar that leans right out over the water.',
   15, 2),
  ('h3', 'Urban Stay Heritage', 'Heritage', 4.5, 431, 'Downtown', '1.2 km from center', 3200,
   'assets/images/hotel3.jpg',
   array['assets/images/hotel3.jpg','assets/images/interior3.jpg','assets/images/hotelRoom.jpg'],
   array['Free WiFi','Heritage Walk','Courtyard'],
   'A Restored Haveli, Still Keeping Its Secrets',
   'Four generations of a trading family lived here before it opened its doors as a hotel. The carved jharokhas, the stepwell courtyard and the hand-set floor tiles are all original.',
   0, 3),
  ('h4', 'Azure Bay Resort', 'Luxury', 4.9, 1203, 'Amalfi, Italy', '2.0 km from center', 850,
   'assets/images/hotel4.jpg',
   array['assets/images/hotel4.jpg','assets/images/beach.jpg','assets/images/hotelRoom.jpg','assets/images/seaNight.jpg'],
   array['Ocean Suite','Infinity Pool','Breakfast','Concierge'],
   'Timeless Elegance and Coastal Serenity',
   'Perched on the dramatic limestone cliffs of the Amalfi Coast, Azure Bay offers a sanctuary of refined luxury. Designed with a meticulous eye for detail, the suite harmonizes modern comfort with heritage Italian craftsmanship. Every window frames a different piece of the sea.',
   10, 4),
  ('h5', 'The Quiet Boutique', 'Boutique', 4.6, 288, 'Old Quarter', '0.6 km from center', 4600,
   'assets/images/restaurant4.jpg',
   array['assets/images/restaurant4.jpg','assets/images/interior1.jpg','assets/images/hotelRoom.jpg'],
   array['Library Bar','Free WiFi','Breakfast'],
   'Eleven Rooms, No Two Alike',
   'An eleven-room house on a lane too narrow for cars. Breakfast is served whenever you come down, and the library bar runs on the honour system.',
   0, 5)
on conflict (id) do update set
  name = excluded.name, category = excluded.category, rating = excluded.rating,
  reviews = excluded.reviews, location = excluded.location, distance = excluded.distance,
  price_per_night = excluded.price_per_night, image = excluded.image,
  gallery = excluded.gallery, amenities = excluded.amenities,
  tagline = excluded.tagline, description = excluded.description,
  discount_percent = excluded.discount_percent, sort_order = excluded.sort_order;

-- ---------------------------------------------------------------- properties
insert into public.properties
  (id, name, location, price, beds, baths, area, image, gallery, tags, description,
   for_rent, monthly_rent, configuration, sort_order) values
  ('pr1', 'Lakeside Manor', 'Winnetka, IL', 12000000, 5, 6, 6800,
   'assets/images/property1.jpg',
   array['assets/images/property1.jpg','assets/images/interior1.jpg','assets/images/interior2.jpg','assets/images/interior3.jpg'],
   array['Premium','For Sale','All'],
   'A lakefront manor with its own boat dock, a double-height great room and a kitchen built for people who actually cook. The gardens were laid out in 1948 and have been kept almost unchanged.',
   false, 0, '', 1),
  ('pr2', 'Elysian Vista Villa', 'Beverly Hills, CA', 42500000, 4, 5, 5200,
   'assets/images/property2.jpg',
   array['assets/images/property2.jpg','assets/images/interior2.jpg','assets/images/interior1.jpg'],
   array['Premium','For Sale','All'],
   'Glass on three sides, canyon views from every room, and a pool that disappears into the hillside. Fully automated, move-in ready.',
   false, 0, '', 2),
  ('pr3', 'Azure Coastal Estate', 'Malibu, CA', 89000000, 6, 8, 12400,
   'assets/images/property3.jpg',
   array['assets/images/property3.jpg','assets/images/interior3.jpg','assets/images/interior1.jpg'],
   array['Premium','For Sale','All','New'],
   'A twelve-thousand square foot estate on a private bluff, with direct beach steps, a guest wing and a twenty-car motor court.',
   false, 0, '', 3),
  ('pr4', 'The Nordic Sanctuary', 'Aspen, Colorado', 19000000, 4, 4, 4100,
   'assets/images/property4.jpg',
   array['assets/images/property4.jpg','assets/images/interior2.jpg'],
   array['For Sale','All'],
   'Blackened timber, warm oak inside, and a wall of glass pointed straight at the ridge. Ski-in, ski-out from the lower terrace.',
   false, 0, '', 4),
  ('pr5', 'The Glass Pavilion', 'Skyline District, North Tower', 15500000, 3, 3, 3200,
   'assets/images/property6.jpg',
   array['assets/images/property6.jpg','assets/images/interior1.jpg','assets/images/cityscape.jpg'],
   array['Premium','For Sale','All','New'],
   'A residential pavilion on the thirty-first floor, wrapped in floor-to-ceiling glass with a private lift lobby and a concierge who remembers your coffee order.',
   false, 0, '', 5),
  ('pr6', 'Azure Heights Estate', 'Malibu, California', 76000000, 5, 7, 9800,
   'assets/images/property7.jpg',
   array['assets/images/property7.jpg','assets/images/interior3.jpg'],
   array['Premium','For Sale','All'],
   'Set into the hillside with a cantilevered terrace, an outdoor kitchen and a lap pool that runs the length of the house.',
   false, 0, '', 6),
  ('pr7', 'Luxury Loft, West Loop', 'West Loop, Chicago', 0, 2, 2, 1200,
   'assets/images/interior1.jpg',
   array['assets/images/interior1.jpg','assets/images/interior2.jpg'],
   array['For Rent','All'],
   'An exposed-brick loft in a converted printing house. Two bedrooms, a twenty-foot ceiling and a freight lift that still works.',
   true, 3200, '2 BHK • 1,200 sqft', 7),
  ('pr8', 'Riverfront Residences', 'Sector 150, Noida', 0, 3, 3, 1850,
   'assets/images/property9.jpg',
   array['assets/images/property9.jpg','assets/images/interior2.jpg'],
   array['For Rent','All','New'],
   'A three-bedroom in a riverside tower with a wrap-around balcony, covered parking and a club floor on level twenty.',
   true, 58000, '3 BHK • 1,850 sqft', 8)
on conflict (id) do update set
  name = excluded.name, location = excluded.location, price = excluded.price,
  beds = excluded.beds, baths = excluded.baths, area = excluded.area,
  image = excluded.image, gallery = excluded.gallery, tags = excluded.tags,
  description = excluded.description, for_rent = excluded.for_rent,
  monthly_rent = excluded.monthly_rent, configuration = excluded.configuration,
  sort_order = excluded.sort_order;

-- ---------------------------------------------------------------- providers
insert into public.service_providers
  (id, name, profession, category, profession_color, rating, reviews, years, distance,
   photo, about, email, phone, office, operating_area, sort_order) values
  ('sp1', 'Ramesh Chand', 'Master Electrician', 'Electricians', '#7A4F00', 4.9, 134, 12, 2.4,
   'assets/images/man1.jpg',
   E'With over 12 years of experience in high-quality residential and commercial services, Ramesh Chand has established a reputation for excellence and reliability. Known for combining technical expertise with strong customer communication, every project is handled with precision and care.\n\nRamesh Chand holds professional certifications and regularly updates skills to meet modern standards. The focus is on delivering lasting solutions that exceed client expectations while staying within budget.',
   'ramesh.chand@pro.com', '+91 98176 04512', 'Sector 10, Ghaziabad',
   'Ghaziabad, Noida & Delhi NCR — covers a 25 km radius', 1),
  ('sp2', 'Reema Kapoor', 'Hair & Style Specialist', 'Salon', '#C2185B', 4.8, 207, 8, 0.8,
   'assets/images/woman1.jpg',
   'Eight years behind the chair, trained in London and Mumbai, with a particular love for precision cuts and colour correction. Reema runs a small studio and keeps the appointment book deliberately short so every client gets unhurried time.',
   'reema@studio.co', '+91 99103 22847', 'Hauz Khas Village, New Delhi',
   'South Delhi — studio visits and at-home appointments', 2),
  ('sp3', 'Musafir Ali', 'Lead Mechanic', 'Mechanics', '#15803D', 5.0, 98, 15, 4.1,
   'assets/images/man3.jpg',
   'Fifteen years on engines of every description, from scooters to imported saloons. Musafir runs a two-bay workshop and will always show you the old part before fitting the new one.',
   'musafir.works@pro.com', '+91 97119 55012', 'Mohan Nagar, Ghaziabad',
   'Ghaziabad & East Delhi — free pickup within 10 km', 3),
  ('sp4', 'Shahdab Khan', 'Plumbing Specialist', 'Plumbers', '#7C3AED', 4.7, 162, 6, 1.5,
   'assets/images/man5.jpg',
   'Six years of residential and light commercial plumbing, with a focus on leak detection and bathroom refits. Shahdab carries his own camera scope so there is no guesswork and no unnecessary breaking of walls.',
   'shahdab.plumb@pro.com', '+91 98730 11094', 'Indirapuram, Ghaziabad',
   'Indirapuram, Vaishali & Noida — same-day callouts', 4),
  ('sp5', 'Anita Desai', 'Deep Clean Lead', 'Cleaning', '#0E7490', 4.8, 311, 9, 3.2,
   'assets/images/woman4.jpg',
   'Anita leads a four-person team that handles move-in deep cleans, post-renovation clearing and recurring home contracts. Everything is quoted per room, in writing, before anyone starts.',
   'anita@spotless.in', '+91 90045 77123', 'Sector 62, Noida',
   'Noida & Greater Noida — teams of two to six', 5),
  ('sp6', 'Karan Mehta', 'Strength & Mobility Coach', 'Fitness', '#B45309', 4.9, 76, 7, 2.0,
   'assets/images/man4.jpg',
   'Karan works with desk-bound clients on getting strong without getting hurt. Sessions are one-to-one, programmed in six-week blocks, at your home or at a partner gym.',
   'karan@movewell.fit', '+91 98111 44320', 'Greater Kailash II, New Delhi',
   'South & Central Delhi — home and gym sessions', 6),
  ('sp7', 'Vikram Sethi', 'Senior Electrician', 'Electricians', '#7A4F00', 4.6, 89, 10, 5.3,
   'assets/images/man7.jpg',
   'Ten years of commercial fit-outs and panel work, with a side speciality in backup power. Vikram handles load calculations and inverter sizing himself rather than passing it to a vendor.',
   'vikram.sethi@pro.com', '+91 99580 61233', 'Okhla Phase II, New Delhi',
   'Delhi NCR — commercial contracts and AMCs', 7),
  ('sp8', 'Neha Bansal', 'Plumbing & Fittings', 'Plumbers', '#7C3AED', 4.7, 54, 5, 1.1,
   'assets/images/woman5.jpg',
   'One of the few women running her own plumbing crew in the city. Neha took over the family business in 2020 and now handles bathroom refits and apartment-block maintenance contracts.',
   'neha@bansalplumbing.in', '+91 98219 30077', 'Rajnagar Extension, Ghaziabad',
   'Ghaziabad — apartment blocks and individual homes', 8)
on conflict (id) do update set
  name = excluded.name, profession = excluded.profession, category = excluded.category,
  profession_color = excluded.profession_color, rating = excluded.rating,
  reviews = excluded.reviews, years = excluded.years, distance = excluded.distance,
  photo = excluded.photo, about = excluded.about, email = excluded.email,
  phone = excluded.phone, office = excluded.office,
  operating_area = excluded.operating_area, sort_order = excluded.sort_order;

-- Expertise chips. `icon` maps to an IconData in lib/data/icon_registry.dart.
delete from public.provider_expertise
 where provider_id in ('sp1','sp2','sp3','sp4','sp5','sp6','sp7','sp8');

insert into public.provider_expertise (provider_id, label, icon, sort_order) values
  ('sp1', 'Wiring & Panels', 'electrical_services', 1),
  ('sp1', 'Light Fitting',   'lightbulb_outline',  2),
  ('sp1', 'Safety Audit',    'verified_user',      3),
  ('sp1', 'Solar Install',   'solar_power',        4),
  ('sp1', 'Maintenance',     'settings',           5),
  ('sp1', 'Estimations',     'receipt_long',       6),
  ('sp2', 'Precision Cuts',  'content_cut',        1),
  ('sp2', 'Colour',          'palette',            2),
  ('sp2', 'Bridal',          'favorite_outline',   3),
  ('sp2', 'Keratin',         'auto_awesome',       4),
  ('sp2', 'Styling',         'brush',              5),
  ('sp2', 'Consults',        'chat_bubble',        6),
  ('sp3', 'Diagnostics',     'build_circle',       1),
  ('sp3', 'Engine Work',     'settings_suggest',   2),
  ('sp3', 'Brakes',          'disc_full',          3),
  ('sp3', 'Electricals',     'bolt',               4),
  ('sp3', 'Detailing',       'local_car_wash',     5),
  ('sp3', 'Pickup',          'local_shipping',     6),
  ('sp4', 'Leak Detection',  'water_damage',       1),
  ('sp4', 'Bath Refits',     'bathtub',            2),
  ('sp4', 'Water Tanks',     'water_drop',         3),
  ('sp4', 'Drainage',        'plumbing',           4),
  ('sp4', 'Geysers',         'hot_tub',            5),
  ('sp4', 'Estimations',     'receipt_long',       6),
  ('sp5', 'Deep Clean',      'cleaning_services',  1),
  ('sp5', 'Sofa & Rug',      'weekend',            2),
  ('sp5', 'Kitchen',         'kitchen',            3),
  ('sp5', 'Sanitising',      'sanitizer',          4),
  ('sp5', 'Move-in',         'moving',             5),
  ('sp5', 'Contracts',       'event_repeat',       6),
  ('sp6', 'Strength',        'fitness_center',     1),
  ('sp6', 'Mobility',        'accessibility_new',  2),
  ('sp6', 'Rehab',           'healing',            3),
  ('sp6', 'Nutrition',       'restaurant_menu',    4),
  ('sp6', 'Assessment',      'monitor_heart',      5),
  ('sp6', 'Programming',     'calendar_month',     6),
  ('sp7', 'Panels',          'electrical_services', 1),
  ('sp7', 'Inverters',       'battery_charging_full', 2),
  ('sp7', 'Load Calc',       'calculate',          3),
  ('sp7', 'Fit-outs',        'store_mall_directory', 4),
  ('sp7', 'Safety Audit',    'verified_user',      5),
  ('sp7', 'AMC',             'event_repeat',       6),
  ('sp8', 'Refits',          'bathtub',            1),
  ('sp8', 'Leak Repair',     'water_damage',       2),
  ('sp8', 'Fittings',        'plumbing',           3),
  ('sp8', 'Pumps',           'water_drop',         4),
  ('sp8', 'AMC',             'event_repeat',       5),
  ('sp8', 'Estimations',     'receipt_long',       6);

delete from public.provider_reviews
 where provider_id in ('sp1','sp2','sp3','sp4','sp5','sp6','sp7','sp8');

insert into public.provider_reviews (provider_id, author, when_label, rating, body)
select p.id, r.author, r.when_label, r.rating, r.body
  from public.service_providers p
 cross join (values
   ('Suraj Kumar',  '2 days ago',  5.0, 'Provided exceptional clarity on our complex requirements. The solutions saved us weeks in delays. Highly recommend for any project!'),
   ('Priya Sharma', '1 week ago',  4.5, 'Very professional and punctual. Work was completed to a high standard and the pricing was fair. Would definitely use again.'),
   ('Aman Verma',   '3 weeks ago', 5.0, 'Turned up on a Sunday at short notice and sorted the whole panel. Explained everything without the usual upselling.')
 ) as r(author, when_label, rating, body);

-- ---------------------------------------------------------------- offers
insert into public.offers
  (code, title, subtitle, image, color_start, color_end, valid_till, sort_order) values
  ('SAVE20', '20% off your food order', 'On orders above ₹300. Valid at all partner restaurants.',
   'assets/images/platter.jpg', '#7A4F00', '#A16207', 'Valid till 31 Dec', 1),
  ('STAY15', 'Flat 15% off hotel stays', 'Minimum two nights. Excludes peak dates.',
   'assets/images/hotel2.jpg', '#0E7490', '#22D3EE', 'Valid till 15 Jan', 2),
  ('RIDE50', '₹50 off your next 5 rides', 'Bike taxi and e-rickshaw. New riders only.',
   'assets/images/motorcycle.jpg', '#7C3AED', '#A78BFA', 'Valid till 30 Nov', 3),
  ('FIXIT', 'First home service free callout', 'Waived visit charge on electricians and plumbers.',
   'assets/images/electrician.jpg', '#B45309', '#F59E0B', 'Valid till 28 Feb', 4)
on conflict (code) do update set
  title = excluded.title, subtitle = excluded.subtitle, image = excluded.image,
  color_start = excluded.color_start, color_end = excluded.color_end,
  valid_till = excluded.valid_till, sort_order = excluded.sort_order;

-- ---------------------------------------------------------------- service tiles
-- `is_wide` marks the full-width tile the home screen puts under the grid.
insert into public.service_categories (id, label, icon, is_wide, sort_order) values
  ('food',       'Food Delivery',     'restaurant', false, 1),
  ('hotel',      'Hotel Booking',     'king_bed',   false, 2),
  ('realestate', 'Real Estate',       'home',       false, 3),
  ('bike',       'Bike Taxi',         'two_wheeler', false, 4),
  ('providers',  'Service Providers', 'handyman',   true,  5)
on conflict (id) do update set
  label = excluded.label, icon = excluded.icon,
  is_wide = excluded.is_wide, sort_order = excluded.sort_order;

-- ---------------------------------------------------------------- saved places
insert into public.saved_places (id, icon, label, address, sort_order) values
  ('home',    'home',   'Home',    'Diya Green City, Rajnagar Extension', 1),
  ('work',    'work',   'Work',    'Sector 62, Noida • Block B',          2),
  ('airport', 'flight', 'Airport', 'IGI Terminal 3, New Delhi',           3)
on conflict (id) do update set
  icon = excluded.icon, label = excluded.label,
  address = excluded.address, sort_order = excluded.sort_order;

-- ---------------------------------------------------------------- ride options
insert into public.ride_options
  (id, title, subtitle, icon, color, eta, price_per_km, sort_order) values
  ('bike',      'Bike taxi',  'Fastest in traffic',   'two_wheeler',
   '#7A4F00', '3 min away',  8, 1),
  ('erickshaw', 'E-rickshaw', 'Cheaper and Reliable', 'electric_rickshaw',
   '#16A34A', '6 min away',  6, 2),
  ('parcel',    'Parcel',     'Send Anything',        'inventory_2',
   '#DC2626', '5 min away', 10, 3),
  ('cab',       'Cab',        'Comfortable, AC',      'local_taxi',
   '#B45309', '8 min away', 14, 4)
on conflict (id) do update set
  title = excluded.title, subtitle = excluded.subtitle, icon = excluded.icon,
  color = excluded.color, eta = excluded.eta,
  price_per_km = excluded.price_per_km, sort_order = excluded.sort_order;

-- ---------------------------------------------------------------- filter chips
-- Keyed by `FilterGroup` in the app. 'All' leads every group.
insert into public.filter_options (group_key, label, sort_order) values
  ('cuisine',  'All',           1),
  ('cuisine',  'North Indian',  2),
  ('cuisine',  'Chinese',       3),
  ('cuisine',  'Italian',       4),
  ('cuisine',  'Continental',   5),
  ('cuisine',  'Desserts',      6),
  ('hotel',    'All',           1),
  ('hotel',    'Luxury',        2),
  ('hotel',    'Boutique',      3),
  ('hotel',    'Resort',        4),
  ('hotel',    'Heritage',      5),
  ('property', 'All',           1),
  ('property', 'For Sale',      2),
  ('property', 'For Rent',      3),
  ('property', 'Premium',       4),
  ('property', 'New',           5),
  ('provider', 'All Services',  1),
  ('provider', 'Electricians',  2),
  ('provider', 'Plumbers',      3),
  ('provider', 'Mechanics',     4),
  ('provider', 'Salon',         5),
  ('provider', 'Cleaning',      6),
  ('provider', 'Fitness',       7)
on conflict (group_key, label) do update set
  sort_order = excluded.sort_order;

-- ---------------------------------------------------------------- settings
insert into public.app_settings (key, value) values
  ('traveler_tip',
   'You have a 4-hour gap between your Spa session and Dinner. We recommend the coastal walk via Path of the Gods.')
on conflict (key) do update set value = excluded.value;
