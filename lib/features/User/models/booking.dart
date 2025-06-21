import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Booking {
  final int id;
  final int totalHours;
  final int startAt;
  final double price;
  final String location;
  final int serviceId;
  final int status;
  final String note;
  final Service service;

  // New pricing fields
  final String? pricingType;
  final double? durationValue;

  Booking({
    required this.id,
    required this.totalHours,
    required this.startAt,
    required this.note,
    required this.status,
    required this.serviceId,
    required this.location,
    required this.price,
    required this.service,
    this.pricingType,
    this.durationValue,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int? ?? 0,
      totalHours: json['total_hours'] as int? ?? 0,
      startAt: json['start_at'] as int? ?? 0,
      price: _parseDouble(json['price']) ?? 0.0,
      location: json['location'] as String? ?? '',
      serviceId: json['service_id'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      note: json['note'] as String? ?? '',
      service: Service.fromJson(json['service'] as Map<String, dynamic>? ?? {}),
      pricingType: json['pricing_type'] as String?,
      durationValue: _parseDouble(json['duration_value']),
    );
  }

  // Helper method to safely parse double values
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'total_hours': totalHours,
        'start_at': startAt,
        'note': note,
        'status': status,
        'service_id': serviceId,
        'location': location,
        'price': price,
        'service': service.toJson(),
        'pricing_type': pricingType,
        'duration_value': durationValue,
      };

  String getStatusText() {
    switch (status) {
      case 1:
        return 'inProgress';
      case 2:
        return 'completed';
      case 3:
        return 'canceled';
      default:
        return 'unknownStatus';
    }
  }

  String get formattedStartDate {
    final date = DateTime.fromMillisecondsSinceEpoch(startAt * 1000);
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String get formattedStartTime {
    final date = DateTime.fromMillisecondsSinceEpoch(startAt * 1000);
    return DateFormat('HH:mm').format(date);
  }

  // New helper methods for pricing display
  String getFormattedDuration(BuildContext context) {
    // Get pricing type from service or order
    final servicePricingType = service.pricingType ?? pricingType ?? 'hourly';

    // If we have new pricing data, use it
    if (durationValue != null) {
      switch (servicePricingType) {
        case 'hourly':
          final value = durationValue!;
          return '${value == value.toInt() ? value.toInt() : value} ${value == 1 ? AppLocalizations.of(context)!.hour : AppLocalizations.of(context)!.hours}';
        case 'daily':
          final value = durationValue!;
          return '${value == value.toInt() ? value.toInt() : value} ${value == 1 ? AppLocalizations.of(context)!.day : AppLocalizations.of(context)!.days}';
        case 'fixed':
          return AppLocalizations.of(context)!.fixedPrice;
        default:
          break;
      }
    }

    // Fallback based on service pricing type and total hours
    switch (servicePricingType) {
      case 'fixed':
        return AppLocalizations.of(context)!.fixedPrice;
      case 'daily':
        // Assume 8 hours per day, so divide total_hours by 8
        final days = totalHours / 8;
        return '${days == days.toInt() ? days.toInt() : days} ${days == 1 ? AppLocalizations.of(context)!.day : AppLocalizations.of(context)!.days}';
      default:
        // Default to hourly
        return '$totalHours ${totalHours == 1 ? AppLocalizations.of(context)!.hour : AppLocalizations.of(context)!.hours}';
    }
  }

  String getServiceRateDisplay(BuildContext context) {
    final servicePricingType = service.pricingType ?? pricingType ?? 'hourly';

    switch (servicePricingType) {
      case 'hourly':
        return '\$${service.costPerHour.toStringAsFixed(2)}/${AppLocalizations.of(context)!.hour}';
      case 'daily':
        if (service.costPerDay != null) {
          return '\$${service.costPerDay!.toStringAsFixed(2)}/${AppLocalizations.of(context)!.day}';
        } else {
          // Fallback to hourly if daily rate not available
          return '\$${service.costPerHour.toStringAsFixed(2)}/${AppLocalizations.of(context)!.hour}';
        }
      case 'fixed':
        if (service.fixedPrice != null) {
          return '\$${service.fixedPrice!.toStringAsFixed(2)}';
        } else {
          // Fallback to hourly if fixed price not available
          return '\$${service.costPerHour.toStringAsFixed(2)}/${AppLocalizations.of(context)!.hour}';
        }
      default:
        return '\$${service.costPerHour.toStringAsFixed(2)}/${AppLocalizations.of(context)!.hour}';
    }
  }
}

class Service {
  final int id;
  final String fullName;
  final String picture;
  final String service;
  final int subcategoryId;
  final double costPerHour;
  final Subcategory subcategory;

  // New pricing fields
  final double? costPerDay;
  final double? fixedPrice;
  final String? pricingType;

  Service({
    required this.id,
    required this.fullName,
    required this.picture,
    required this.service,
    required this.subcategoryId,
    required this.costPerHour,
    required this.subcategory,
    this.costPerDay,
    this.fixedPrice,
    this.pricingType,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int? ?? 0,
      fullName: json['full_name'] as String? ?? '',
      picture: json['picture'] as String? ?? '',
      service: json['service'] as String? ?? '',
      subcategoryId: json['subcategory_id'] as int? ?? 0,
      costPerHour: Booking._parseDouble(json['cost_per_hour']) ?? 0.0,
      subcategory: Subcategory.fromJson(
          json['subcategory'] as Map<String, dynamic>? ?? {}),
      costPerDay: Booking._parseDouble(json['cost_per_day']),
      fixedPrice: Booking._parseDouble(json['fixed_price']),
      pricingType: json['pricing_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'picture': picture,
        'service': service,
        'subcategory_id': subcategoryId,
        'cost_per_hour': costPerHour,
        'subcategory': subcategory.toJson(),
        'cost_per_day': costPerDay,
        'fixed_price': fixedPrice,
        'pricing_type': pricingType,
      };
}

class Subcategory {
  final int id;
  final String name;

  Subcategory({
    required this.id,
    required this.name,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
