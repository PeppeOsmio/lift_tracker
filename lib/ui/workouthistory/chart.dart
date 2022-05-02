import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lift_tracker/ui/styles.dart';

class Chart extends StatelessWidget {
  const Chart(
      {Key? key,
      required this.values,
      required this.getTooltips,
      required this.color})
      : super(key: key);
  final List<double> values;
  final List<LineTooltipItem> Function(List<LineBarSpot>) getTooltips;
  final Color color;
  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    double ySpacing;
    for (int i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }

    if (values.length > 1) {
      double sum = 0;
      int count = 0;
      for (int i = 0; i < values.length; i++) {
        for (int j = 0; j < values.length; j++) {
          if (j != i) {
            sum += (values[i] - values[j]).abs();
            count++;
          }
        }
      }
      ySpacing = sum / count;
    }
    ySpacing = values[0];
    return LineChart(LineChartData(
      maxX: values.length > 5
          ? values.length.toDouble() - 1
          : values.length.toDouble() - 0.5,
      minX: values.length > 5 ? 0 : -0.5,
      maxY: values.reduce(max) + values.reduce(max) * 0.1,
      minY: values.length > 1 ? 0 : values[0] / 2,
      lineTouchData: LineTouchData(
          enabled: true,
          getTouchedSpotIndicator: (_, list) {
            return list
                .map((e) => TouchedSpotIndicatorData(
                    FlLine(strokeWidth: 0), FlDotData(show: true)))
                .toList();
          },
          touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Palette.elementsDark,
              fitInsideHorizontally: true,
              getTooltipItems: (lineBarSpotList) {
                return getTooltips(lineBarSpotList);
              })),
      titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
      lineBarsData: [
        LineChartBarData(
            spots: spots,
            isCurved: false,
            color: color,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [color.withAlpha(50), color.withAlpha(1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ))
      ],
      gridData: FlGridData(
          horizontalInterval: ySpacing,
          verticalInterval: 1,
          show: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(strokeWidth: 1, color: Palette.elementsDark);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(strokeWidth: 1, color: Palette.elementsDark);
          }),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: Palette.elementsDark, width: 3)),
    ));
  }
}
