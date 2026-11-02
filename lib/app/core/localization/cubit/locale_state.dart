import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LocaleState extends Equatable {
  final Locale locale;

  const LocaleState({
    required this.locale,
  }); 

  // /// الحالة الابتدائية
  // factory LocaleState.initial() =>
  //     const LocaleState(locale: Locale('ar'));

  // /// نسخ الحالة مع تعديل قيمة معينة
  // LocaleState copyWith({
  //   Locale? locale,
  // }) {
  //   return LocaleState(
  //     locale: locale ?? this.locale,
  //   );
  // }

  @override
  List<Object> get props => [locale];

  @override
  String toString() => 'LocaleState(locale: ${locale.languageCode})';
}
