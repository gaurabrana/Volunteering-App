import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../Models/VolunteeringEvent.dart';

class VolunteeringTypePieChart extends StatefulWidget {
  const VolunteeringTypePieChart({Key? key, required this.volunteeringEvents}) : super(key: key);

  final List<VolunteeringEvent> volunteeringEvents;

  @override
  State<VolunteeringTypePieChart> createState() => VolunteeringTypePieChartState();
}

class VolunteeringTypePieChartState extends State<VolunteeringTypePieChart> {
  List<Color> gradientColors = [
    const Color(0xFF165BAA),
    const Color(0xFF0B1354),
    const Color(0xFFA2568A),
    const Color(0xFFF765A3),
    const Color(0xFFFFA4B6),
  ];

  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    List<Widget> indicators = [];
    List<String> uniqueEventTypes = [];

    for (var event in widget.volunteeringEvents) {
      if (!uniqueEventTypes.contains(event.type)) {
        uniqueEventTypes.add(event.type);
        indicators.add(Indicator(
          color: gradientColors[(uniqueEventTypes.length % gradientColors.length) - 1],
          text: event.type,
          isSquare: true,
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.5,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 0,
              centerSpaceRadius: 30,
              sections: showingSections(),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: indicators,
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    Map<String, int> typeCount = {};
    widget.volunteeringEvents.forEach((event) {
      if (typeCount.containsKey(event.type)) {
        typeCount[event.type] = typeCount[event.type]! + 1;
      } else {
        typeCount[event.type] = 1;
      }
    });

    int totalEvents = widget.volunteeringEvents.length;

    return typeCount.entries.map((entry) {
      final String type = entry.key;
      final int count = entry.value;
      final double percentage = (count / totalEvents) * 100;

      final isTouched = touchedIndex != -1 && type == widget.volunteeringEvents[touchedIndex].type;
      final fontSize = isTouched ? 20.0 : 12.0;
      final radius = isTouched ? 50.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      // Determine the color based on the type index
      final colorIndex = typeCount.keys.toList().indexOf(type) % gradientColors.length;
      final color = gradientColors[colorIndex];

      return PieChartSectionData(
        color: color,
        value: percentage.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    }).toList();
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
    this.keyTextColor = Colors.black,
  });

  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;
  final Color keyTextColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor ?? keyTextColor,
          ),
        )
      ],
    );
  }
}
