import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An address the user saved from the profile.
class SavedAddress extends Equatable {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.address,
  });

  final String id;
  final String label;
  final String address;

  Map<String, dynamic> toJson() =>
      {'id': id, 'label': label, 'address': address};

  factory SavedAddress.fromJson(Map<String, dynamic> j) => SavedAddress(
        id: '${j['id']}',
        label: '${j['label']}',
        address: '${j['address']}',
      );

  @override
  List<Object?> get props => [id, label, address];
}

enum PaymentKind { upi, card }

/// A payment method kept for next time.
///
/// Only what is needed to recognise it is stored: a UPI id, or the last four
/// digits of a card. A full card number is never kept.
class SavedPayment extends Equatable {
  const SavedPayment({
    required this.id,
    required this.kind,
    required this.title,
    required this.detail,
  });

  final String id;
  final PaymentKind kind;

  /// "UPI" or "Card".
  final String title;

  /// The UPI id, or "•••• 4242".
  final String detail;

  Map<String, dynamic> toJson() =>
      {'id': id, 'kind': kind.name, 'title': title, 'detail': detail};

  factory SavedPayment.fromJson(Map<String, dynamic> j) => SavedPayment(
        id: '${j['id']}',
        kind: PaymentKind.values.firstWhere((k) => k.name == j['kind'],
            orElse: () => PaymentKind.upi),
        title: '${j['title']}',
        detail: '${j['detail']}',
      );

  @override
  List<Object?> get props => [id, kind, title, detail];
}

/// The text sizes offered under Appearance.
enum TextSize {
  small('Small', 0.9),
  normal('Default', 1.0),
  large('Large', 1.15);

  const TextSize(this.label, this.scale);
  final String label;
  final double scale;
}

class AppLanguage extends Equatable {
  const AppLanguage(this.code, this.name, this.nativeName);
  final String code;
  final String name;
  final String nativeName;

  static const all = [
    AppLanguage('en', 'English', 'English'),
    AppLanguage('hi', 'Hindi', 'हिन्दी'),
  ];

  @override
  List<Object?> get props => [code];
}

class PreferencesState extends Equatable {
  const PreferencesState({
    this.addresses = const [],
    this.payments = const [],
    this.orderUpdates = true,
    this.bookingUpdates = true,
    this.offers = false,
    this.language = 'en',
    this.textSize = TextSize.normal,
  });

  final List<SavedAddress> addresses;
  final List<SavedPayment> payments;
  final bool orderUpdates;
  final bool bookingUpdates;
  final bool offers;
  final String language;
  final TextSize textSize;

  PreferencesState copyWith({
    List<SavedAddress>? addresses,
    List<SavedPayment>? payments,
    bool? orderUpdates,
    bool? bookingUpdates,
    bool? offers,
    String? language,
    TextSize? textSize,
  }) =>
      PreferencesState(
        addresses: addresses ?? this.addresses,
        payments: payments ?? this.payments,
        orderUpdates: orderUpdates ?? this.orderUpdates,
        bookingUpdates: bookingUpdates ?? this.bookingUpdates,
        offers: offers ?? this.offers,
        language: language ?? this.language,
        textSize: textSize ?? this.textSize,
      );

  @override
  List<Object?> get props => [
        addresses,
        payments,
        orderUpdates,
        bookingUpdates,
        offers,
        language,
        textSize,
      ];
}

/// Settings that belong to this device: saved addresses and payment methods,
/// notification switches, language and text size.
///
/// Kept in [SharedPreferences] rather than the backend, so they survive
/// restarts and work offline. Every change is written straight away.
class PreferencesCubit extends Cubit<PreferencesState> {
  PreferencesCubit() : super(const PreferencesState());

  static const _key = 'preferences.v1';

  SharedPreferences? _prefs;

  /// Reads what was saved. Storage being unavailable is not fatal: the
  /// defaults stay and changes simply are not persisted.
  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final raw = _prefs!.getString(_key);
      if (raw == null) return;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      emit(PreferencesState(
        addresses: [
          for (final a in (j['addresses'] as List? ?? const []))
            SavedAddress.fromJson(a as Map<String, dynamic>),
        ],
        payments: [
          for (final p in (j['payments'] as List? ?? const []))
            SavedPayment.fromJson(p as Map<String, dynamic>),
        ],
        orderUpdates: j['orderUpdates'] as bool? ?? true,
        bookingUpdates: j['bookingUpdates'] as bool? ?? true,
        offers: j['offers'] as bool? ?? false,
        language: j['language'] as String? ?? 'en',
        textSize: TextSize.values.firstWhere(
            (t) => t.name == j['textSize'],
            orElse: () => TextSize.normal),
      ));
    } catch (e) {
      debugPrint('Preferences: could not load — $e');
    }
  }

  Future<void> _save() async {
    final prefs = _prefs;
    if (prefs == null) return;
    final s = state;
    try {
      await prefs.setString(
        _key,
        jsonEncode({
          'addresses': [for (final a in s.addresses) a.toJson()],
          'payments': [for (final p in s.payments) p.toJson()],
          'orderUpdates': s.orderUpdates,
          'bookingUpdates': s.bookingUpdates,
          'offers': s.offers,
          'language': s.language,
          'textSize': s.textSize.name,
        }),
      );
    } catch (e) {
      debugPrint('Preferences: could not save — $e');
    }
  }

  void _set(PreferencesState next) {
    emit(next);
    _save();
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  void addAddress(String label, String address) => _set(state.copyWith(
        addresses: [
          ...state.addresses,
          SavedAddress(id: _newId(), label: label.trim(), address: address.trim()),
        ],
      ));

  void updateAddress(SavedAddress updated) => _set(state.copyWith(
        addresses: [
          for (final a in state.addresses) a.id == updated.id ? updated : a,
        ],
      ));

  void removeAddress(String id) => _set(state.copyWith(
        addresses: state.addresses.where((a) => a.id != id).toList(),
      ));

  void addUpi(String upiId) => _set(state.copyWith(
        payments: [
          ...state.payments,
          SavedPayment(
              id: _newId(),
              kind: PaymentKind.upi,
              title: 'UPI',
              detail: upiId.trim()),
        ],
      ));

  /// Keeps only the last four digits of [cardNumber].
  void addCard(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    final last4 = digits.substring(digits.length - 4);
    _set(state.copyWith(
      payments: [
        ...state.payments,
        SavedPayment(
            id: _newId(),
            kind: PaymentKind.card,
            title: 'Card',
            detail: '•••• $last4'),
      ],
    ));
  }

  void removePayment(String id) => _set(state.copyWith(
        payments: state.payments.where((p) => p.id != id).toList(),
      ));

  void setOrderUpdates(bool v) => _set(state.copyWith(orderUpdates: v));
  void setBookingUpdates(bool v) => _set(state.copyWith(bookingUpdates: v));
  void setOffers(bool v) => _set(state.copyWith(offers: v));
  void setLanguage(String code) => _set(state.copyWith(language: code));
  void setTextSize(TextSize size) => _set(state.copyWith(textSize: size));
}
