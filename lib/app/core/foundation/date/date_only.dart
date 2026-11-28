import 'package:flutter/material.dart';

/// Date-only conversion helpers. Values are represented as local midnight;
/// API values use PostgreSQL's `date` format and never carry a UTC offset.
abstract final class DateOnly {
  static DateTime normalize(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static String toApiString(DateTime value) {
    final date = normalize(value);
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Returns null for null, malformed, or impossible calendar dates.
  static DateTime? fromApiString(String? value) {
    if (value == null || !RegExp(r'^\d{4}-\d{2}-\d{2}
      return null;
    }
    final parts = value.split('-').map(int.parse).toList(growable: false);
    final date = DateTime(parts[0], parts[1], parts[2]);
    if (date.year != parts[0] ||
        date.month != parts[1] ||
        date.day != parts[2]) {
      return null;
    }
    return date;
  }

  /// Formats using the active Material locale (Arabic or English).
  static String format(BuildContext context, DateTime value) =>
      MaterialLocalizations.of(context).formatMediumDate(normalize(value));
}
).hasMatch(value)) {
      return null;
    }
    final parts = value.split('-').map(int.parse).toList(growable: false);
    final date = DateTime(parts[0], parts[1], parts[2]);
    if (date.year != parts[0] ||
        date.month != parts[1] ||
        date.day != parts[2]) {
      return null;
    }
    return date;
  }

  /// Formats using the active Material locale (Arabic or English).
  static String format(BuildContext context, DateTime value) =>
      MaterialLocalizations.of(context).formatMediumDate(normalize(value));
}
