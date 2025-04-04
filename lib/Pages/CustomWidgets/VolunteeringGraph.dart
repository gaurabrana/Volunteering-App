import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../Models/VolunteeringHistory.dart';

class YearVolunteeringHistoryLineGraph extends StatefulWidget {
  const YearVolunteeringHistoryLineGraph({super.key, required this.volunteeringHistory, required this.financialYear});

  final List<VolunteeringHistory> volunteeringHistory;
  final int financialYear;

  @override
  State<YearVolunteeringHistoryLineGraph> createState() => _YearVolunteeringHistoryLineGraphState();
}

class _YearVolunteeringHistoryLineGraphState extends State<YearVolunteeringHistoryLineGraph> {
  List<Color> gradientColors = [
    Color(0xFF8643FF),
    Color(0xFF4136F1),
  ];
  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 10,
            ),
            child: LineChart(
              mainData(widget.volunteeringHistory),
            ),
          ),
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'avg',
              style: TextStyle(
                fontSize: 12,
                color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData mainData(List<VolunteeringHistory> volunteeringHistory) {
    int startYear = 2000 + widget.financialYear;
    DateTime financialYearStart = DateTime(startYear - 1, 4, 1);
    DateTime financialYearEnd = DateTime(startYear, 3, 31);

    List<VolunteeringHistory> financialYearEntries = volunteeringHistory
        .where((entry) => entry.date.isAfter(financialYearStart) && entry.date.isBefore(financialYearEnd.add(Duration(days: 1))))
        .toList();

    double maxY = 0;
    List<FlSpot> spots = [];
    for (int month = 1; month <= 12; month++) {
      int financialYearMonth = (4 + month - 1) % 12;

      List<VolunteeringHistory> monthEntries = financialYearEntries.where((entry) => entry.date.month == financialYearMonth).toList();

      double totalHours = monthEntries.isNotEmpty ? monthEntries.map((entry) => entry.hours.toDouble()).reduce((a, b) => a + b) : 0;

      if (totalHours > maxY) {
        maxY = totalHours;
      }

      spots.add(FlSpot(month.toDouble(), totalHours));
    }

    Widget bottomTitleWidgets(double value, TitleMeta meta) {
      const style = TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 16,
      );
      String text;
      switch (value.toInt()) {
        case 1:
          text = 'A';
          break;
        case 2:
          text = 'M';
          break;
        case 3:
          text = 'J';
          break;
        case 4:
          text = 'J';
          break;
        case 5:
          text = 'A';
          break;
        case 6:
          text = 'S';
          break;
        case 7:
          text = 'O';
          break;
        case 8:
          text = 'N';
          break;
        case 9:
          text = 'D';
          break;
        case 10:
          text = 'J';
          break;
        case 11:
          text = 'F';
          break;
        case 12:
          text = 'M';
          break;
        default:
          return Container();
      }

      return Text(text, style: style, textAlign: TextAlign.left);
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 2,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
        getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
      ),
      minX: 1,
      maxX: 12,
      minY: 0,
      maxY: maxY,
      baselineY: 0,
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.shade100),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
            ),
          ),
        ),
      ],
    );
  } //todo line dips below 0
// todo maybe add company average comparisons
}
