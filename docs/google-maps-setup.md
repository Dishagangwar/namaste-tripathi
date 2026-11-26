# Google Maps setup

The "Delivering to" picker on the home screen has a map (`LocationPickerScreen`).
It needs a Google Maps API key. The key is not committed.

1. In Google Cloud, enable **Maps SDK for Android** and **Maps SDK for iOS**.
2. Create an API key and restrict it (Android: package `com.namastetripathi.app` + SHA-1; iOS: bundle ID).
3. Android: add `MAPS_API_KEY=...` to `android/local.properties` (gitignored), or set the `MAPS_API_KEY` env var in CI.
4. iOS: create `ios/Flutter/Secrets.xcconfig` (gitignored) containing `MAPS_API_KEY = ...`, then run `cd ios && pod install`.

Address lookup uses the device's native geocoder, so it needs no extra key.
Without a key the map renders blank/grey; the rest of the app is unaffected.
