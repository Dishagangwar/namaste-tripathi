# Namaste Tripathi

A Flutter rebuild of the city super-app from the reference recording — food
delivery, hotel booking, real estate, bike taxi and a service-provider
directory, all behind one OTP sign-in.

Everything runs on in-memory mock data: there is no backend, no Firebase and
no API keys. Every flow in the video is clickable end to end.

## Running it

```bash
flutter pub get
flutter run
```

Tested on Flutter 3.47 / Dart 3.13. iOS, Android and web targets are generated.

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
  core/        theme tokens, shared widgets, app state (ChangeNotifier)
  data/        models, mock data, the photo catalogue
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
`FavouritesState`, `BookingsState`.

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
