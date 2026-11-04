import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LocaleState extends Equatable {
  final Locale locale;

  const LocaleState({
    required this.locale,
  }); 

  @override
  List<Object> get props => [locale];

  @override
  String toString() => 'LocaleState(locale: ${locale.languageCode})';
}
