import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'wire.dart';

part 'api_service.g.dart';

/// The app's HTTP API, declared rather than hand-written.
///
/// Retrofit generates the implementation from these annotations, so every
/// path, verb and body lives in one place instead of being spelled out as a
/// string at each call site. A mistyped path is a change to this file now,
/// not a 404 found at runtime inside one repository.
///
/// It is handed the same [Dio] the demo backend is attached to as an
/// interceptor, so the generated client reaches the in-app fake exactly as
/// it would a real server. Nothing here knows which it is talking to.
///
/// The return types are the thin wrappers in `wire.dart`, whose `fromJson`
/// calls the same mappers the Supabase repositories use. Retrofit requires a
/// `fromJson`, and it cannot take `List<dynamic>` or `Map<String, dynamic>`:
/// for those the generator emits `dynamic.fromJson(...)`, which does not
/// compile.
@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String? baseUrl}) = _ApiService;

  // -------------------------------------------------------------- catalogue

  @GET('/catalog/restaurants')
  Future<List<RestaurantWire>> restaurants();

  @GET('/catalog/hotels')
  Future<List<HotelWire>> hotels();

  @GET('/catalog/properties')
  Future<List<PropertyWire>> properties();

  @GET('/catalog/providers')
  Future<List<ProviderWire>> providers();

  @GET('/catalog/offers')
  Future<List<OfferWire>> offers();

  @GET('/catalog/coupons')
  Future<List<CouponWire>> coupons();

  // ------------------------------------------------------------------- auth

  @POST('/auth/otp')
  Future<void> sendOtp(@Body() Map<String, dynamic> body);

  @POST('/auth/verify')
  Future<void> verifyOtp(@Body() Map<String, dynamic> body);

  @POST('/auth/google')
  Future<void> signInWithGoogle();

  @POST('/auth/signout')
  Future<void> signOut();

  // ---------------------------------------------------------------- profile

  @GET('/profile')
  Future<ProfileWire> profile();

  @PATCH('/profile')
  Future<void> saveProfile(@Body() Map<String, dynamic> body);

  // ----------------------------------------------------------------- config

  @GET('/config')
  Future<AppConfigWire> config();

  // --------------------------------------------------------------- bookings

  @GET('/bookings')
  Future<List<BookingWire>> bookings();

  @POST('/bookings')
  Future<BookingWire> addBooking(@Body() Map<String, dynamic> body);

  // ----------------------------------------------------------------- orders

  @GET('/orders')
  Future<List<OrderWire>> orders();

  @POST('/orders')
  Future<OrderWire> placeOrder(@Body() Map<String, dynamic> body);

  // ------------------------------------------------------------------ rides

  @GET('/rides')
  Future<List<RideWire>> rides();

  @POST('/rides')
  Future<RideWire> bookRide(@Body() Map<String, dynamic> body);

  // ------------------------------------------------------------- favourites

  @GET('/favourites')
  Future<FavouritesWire> favourites();

  @POST('/favourites')
  Future<void> addFavourite(@Body() Map<String, dynamic> body);

  @DELETE('/favourites')
  Future<void> removeFavourite(@Body() Map<String, dynamic> body);
}
