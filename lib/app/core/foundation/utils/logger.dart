import 'dart:developer';
import 'package:flutter/foundation.dart';

class Logger {
  static bool get _enabled => kDebugMode;

  static void info(
    Object? message, {
    String name = 'APP',
  }) {
    if (!_enabled) return;

    log(
      message.toString(),
      name: name,
      level: 800,
      time: DateTime.now(),
    );
  }

  static void warning(
    Object? message, {
    String name = 'APP',
  }) {
    if (!_enabled) return;

    log(
      message.toString(),
      name: name,
      level: 900,
      time: DateTime.now(),
    );
  }

  static void error(
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'APP',
  }) {
    if (!_enabled) return;

    log(
      message.toString(),
      name: name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
  }

  static void debug(
    Object? message, {
    String name = 'APP',
  }) {
    if (!_enabled) return;

    log(
      message.toString(),
      name: name,
      level: 700,
      time: DateTime.now(),
    );
  }
}