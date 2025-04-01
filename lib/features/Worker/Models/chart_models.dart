import 'package:flutter/material.dart';

class ChartData {
  final String label;
  final int value;
  final Color color;

  const ChartData(this.label, this.value, this.color);
}

class ServiceChartData {
  final String category;
  final int visible;
  final int hidden;

  const ServiceChartData(this.category, this.visible, this.hidden);
}
