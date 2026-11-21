-- Namaste Tripathi — config rows
--
-- The app's taxonomy: service tiles, saved addresses, ride classes, filter
-- chips and editorial copy.
--
-- These live in a migration rather than in seed.sql deliberately. The
-- catalogue is content -- restaurants come and go, and a developer seeding a
-- fresh database wants a plausible set. This is reference data the UI's
-- structure depends on: without a ride class there is nothing to book, and
-- without a filter group the chip row is empty. It has to be present in
-- every environment, which means it has to be a migration -- `db push
-- --include-seed` will not re-run a seed file it has already recorded, so
-- new seed rows never reach a database that was seeded before they existed.
--
-- Safe to re-run: every insert upserts.

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
