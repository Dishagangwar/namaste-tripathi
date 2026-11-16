# Namaste Tripathi

A Flutter rebuild of the city super-app from the reference recording — food
delivery, hotel booking, real estate, bike taxi and a service-provider
directory, all behind one OTP sign-in.

The catalogue, sign-in and bookings are backed by **Supabase**. The app also
ships with the full catalogue bundled in `lib/data/mock_data.dart`, and falls
back to it whenever Supabase is not configured or not reachable -- so every
flow stays clickable end to end with no key at all.

## Running it

```bash
flutter pub get
flutter run --dart-define=SUPABASE_PUBLISHABLE_KEY=<your key>
```

Without the key the app runs on the bundled catalogue. Tested on
Flutter 3.47 / Dart 3.13. iOS, Android and web targets are generated.

## Supabase

Project: `https://cwfozayeingrqomplcgg.supabase.co`
(set in `lib/core/supabase_config.dart`, overridable with
`--dart-define=SUPABASE_URL=`).

### 1. The key

The publishable (anon) key is **not** committed. Pass it at build time:

| Where | How |
| --- | --- |
| CLI | `flutter run --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...` |
| VS Code | `.vscode/launch.json` -> `toolArgs` (a template is checked in) |
| Android Studio | Run > Edit Configurations > Additional run args |
| CI | read it from a secret and pass the same flag |

`SUPABASE_ANON_KEY` is accepted too, for a project still on a legacy anon JWT.
Find the key under Project Settings > API Keys. Never put the **service role**
key in the app -- it bypasses row level security.

### 2. The schema

`supabase/migrations/` holds the schema and `supabase/seed.sql` the catalogue.
Either paste both into the dashboard SQL editor (migration first), or use the
CLI:

```bash
supabase link --project-ref cwfozayeingrqomplcgg
supabase db push
psql "$(supabase db url)" -f supabase/seed.sql
```

The seed upserts on every primary key, so it is safe to re-run after editing.

### 3. Phone sign-in

The OTP screens call `signInWithOtp` / `verifyOTP`, which needs an SMS
provider under Authentication > Providers > Phone. Until one is attached:

- **hosted** -- add the number under Authentication > Users as a test phone
  with a fixed code; or
- **local** -- `supabase start` picks up `[auth.sms.test_otp]` in
  `supabase/config.toml` (`+91 99999 99999` / `123456`).

A build with no key skips verification entirely, so the screens stay walkable.

### What lives where

| Table | Read by | Written by |
| --- | --- | --- |
| `restaurants`, `menu_items`, `coupons` | Food delivery | dashboard only |
| `hotels` | Hotels | dashboard only |
| `properties` | Real estate | dashboard only |
| `service_providers`, `provider_expertise`, `provider_reviews` | Directory | dashboard only |
| `offers` | Offers tab | dashboard only |
| `profiles` | Profile, home greeting | the signed-in user |
| `bookings` | My Bookings | the signed-in user |
| `favourites` | Saved / Favourites | the signed-in user |

Catalogue tables grant `select` to `anon` and `authenticated` and nothing
else. `profiles`, `bookings` and `favourites` are row-level isolated: a row is
visible and writable only by the user who owns it. A trigger on `auth.users`
creates the profile row at sign-up.

Icons and brand colours cannot travel over the wire, so Supabase stores short
names (`electrical_services`) and hex strings (`#0B4EA2`), which
`lib/data/icon_registry.dart` and `lib/data/remote/mappers.dart` resolve. An
unknown name degrades to a neutral icon instead of crashing a detail screen.

## What is built

**Onboarding & auth**
- Auto-advancing photo carousel (Bike Services / Home Services / Food Delivery)
- Continue with OTP, Continue with Google
- Mobile number entry with a country-code picker
- Six-box OTP screen with a live resend countdown and paste support
- Role picker: *I am a User* / *I am a Service Provider*

**Home**
- Location switcher, notification bell, blue hero card with search
- Category grid (Food Delivery, Hotel Booking, Real Estate, Bike Taxi) plus the
  wide Service Providers tile
- Top Restaurants, Top Hotels, a rental strip and Top Properties for Sale
- Five-tab bottom bar: Home, Services, Bookings, Offers, Profile

**Food delivery**
- Restaurant list with cuisine filters, search and a top-rated sort
- Restaurant detail: hero image, floating info card, coupons, pinned category
  chips, popular/recommended sections, the floating Menu button
- Add-to-cart steppers and the sticky cart bar
- Cart: line items, suggestions, coupon apply/remove, live bill breakdown,
  partner instructions
- Payment method picker, then an order-confirmation screen with a tracker that
  advances on its own
- Its own Explore / Orders / Saved / Profile bar, as in the video

**Hotels**
- Hotel list with category filters and amenity chips
- Hotel detail: gallery header, description, a real date-range picker that
  recalculates nights, fees and the total
- Guest information form with validation, guest steppers and room type
- Confirmation screen; the booking lands in My Bookings

**Real estate**
- Its own shell with Explore / Favorites / Schedule / Profile
- Property cards with beds, baths, area and a working favourite toggle
- Property detail with a swipeable gallery and stat row
- Schedule Visit: month-navigable calendar, morning/afternoon/evening slots,
  confirmation dialog, and the visit is added to My Bookings

**Service providers**
- Directory with trade filters and search
- Partner detail: blue gradient header, about, expertise grid, reviews,
  contact card and operating area

**Bike taxi**
- Pickup row, destination entry with saved places
- Fare estimates per ride type (bike, e-rickshaw, parcel, cab) and a
  searching-for-a-ride sheet

**Bookings, Offers, Profile**
- Bookings with status badges and the Traveler Tip card
- Offer cards with copy-to-clipboard codes
- Profile with stats, grouped settings and log out

## Layout

```
assets/
  images/      59 bundled photos, referenced by lib/data/images.dart
lib/
  core/        theme tokens, shared widgets, app state, Supabase config
  data/        models, bundled catalogue, photo catalogue, icon registry
    remote/      Supabase client, repositories, row mappers
supabase/
  migrations/  schema, RLS policies, sign-up trigger
  seed.sql     the catalogue as SQL
  features/
    auth/        onboarding, phone, OTP, role
    shell/       five-tab shell, services hub, global search
    home/        home screen
    food/        list, detail, cart, payment, order success, side tabs
    hotels/      list, detail, booking details, confirmation
    realestate/  shell, property detail, schedule visit
    providers/   list, partner detail
    biketaxi/    ride booking
    bookings/ offers/ profile/
```

State is plain `ChangeNotifier` + `provider`: `SessionState`, `CartState`,
`FavouritesState`, `BookingsState`, `CatalogState`. Screens read the catalogue
through `CatalogState` rather than the `k...` lists, which is what lets the
dashboard be the source of truth; the lists remain as the offline fallback.

## Notes

- Photos are bundled under `assets/images/` and catalogued in
  `lib/data/images.dart`, so the app renders identically offline and on first
  launch. To swap artwork, drop a replacement over the file of the same name --
  no screen code changes. `AppImage` still accepts an `http` URL if you ever
  want a remote image, and falls back to a branded gradient placeholder rather
  than a broken box. `test/assets_test.dart` fails the build if a catalogue
  entry points at a file that is not there, or if a bundled image goes unused.
- The photos come from Unsplash, under the Unsplash License. They are
  placeholders for a demo -- swap them for licensed artwork before shipping.
- Prices use `rupees()` in `lib/core/theme.dart`, which applies Indian digit
  grouping (1,20,000 rather than 120,000).
- The cart does real coupon maths against the minimum-order rule, so totals
  differ slightly from the fixed numbers shown in the recording.
- Every Supabase call is wrapped: a failure logs and falls back rather than
  throwing into the widget tree. `test/supabase_mapping_test.dart` pins the
  row mapping and the fallback; `test/supabase_seed_test.dart` fails the build
  if the seed points at a missing asset, an unregistered icon, or a table no
  migration creates.
- Images are still bundled assets, and the seed stores those same asset paths.
  Move them to a Storage bucket by replacing the paths with public URLs --
  `AppImage` already handles `http`.
