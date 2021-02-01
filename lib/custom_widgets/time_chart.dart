import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TimeChart extends StatelessWidget {
  const TimeChart({Key key}) : super(key: key);

  // Lerps between a [LinearGradient] colors, based on [t]
  Color lerpGradient(List<Color> colors, List<double> stops, double t) {
    if (stops == null || stops.length != colors.length) {
      stops = [];

      // provided gradientColorStops is invalid and we calculate it here
      colors.asMap().forEach((index, color) {
        final percent = 1.0 / colors.length;
        stops.add(percent * index);
      });
    }

    for (var s = 0; s < stops.length - 1; s++) {
      final leftStop = stops[s], rightStop = stops[s + 1];
      final leftColor = colors[s], rightColor = colors[s + 1];
      if (t <= leftStop) {
        return leftColor;
      } else if (t < rightStop) {
        final sectionT = (t - leftStop) / (rightStop - leftStop);
        return Color.lerp(leftColor, rightColor, sectionT);
      }
    }
    return colors.last;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    var indicatorList = [5, 10, 15, 20];
    var allSpots = List<FlSpot>.generate(25, (index) {
      return FlSpot(index.toDouble(), (index ~/ 5).toDouble());
    });

    final lineBars = [
      LineChartBarData(
        spots: allSpots,
        showingIndicators: indicatorList,
        dotData: FlDotData(show: false), // 顯示點點
        barWidth: 2,
        isCurved: false,
        colors: [
          Colors.blue,
          Colors.indigo,
          Colors.deepPurple,
        ],
        belowBarData: BarAreaData(
          show: true,
          colors: [
            Colors.blue.withOpacity(0.25),
            Colors.indigo.withOpacity(0.25),
            Colors.deepPurple.withOpacity(0.25),
          ],
        ),
        shadow: Shadow(
          blurRadius: 8,
          color: Colors.black,
        ),
        colorStops: [0.4, 0.8, 0.9],
      ),
    ];

    return Container(
      padding: EdgeInsets.only(top: 28.0),
      height: 300.0,
      width: 400.0,
      child: LineChart(
        LineChartData(
          lineBarsData: lineBars,
          titlesData: FlTitlesData(
            leftTitles: SideTitles(showTitles: false),
            bottomTitles: SideTitles(
              showTitles: true,
              getTitles: (val) => (val % 4 == 0 ? '${val.toInt()}' : ''),
              getTextStyles: (value) => TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo[400],
                fontSize: 18,
              ),
            ),
          ),
          axisTitleData: FlAxisTitleData(
            leftTitle: AxisTitle(showTitle: true, titleText: '更換次數'),
            bottomTitle: AxisTitle(showTitle: true, titleText: '時間'),
            topTitle: AxisTitle(showTitle: true, titleText: '${now.month}/${now.day}', textAlign: TextAlign.left),
          ),
          lineTouchData: LineTouchData(
            enabled: false,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.indigo,
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                return lineBarsSpot.map((lineBarSpot) {
                  return LineTooltipItem(
                    lineBarSpot.y.toString(),
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
            ),
            getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(color: Colors.transparent),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 4.5,
                      color: lerpGradient(barData.colors, barData.colorStops, percent / 100),
                      strokeWidth: 1.5,
                      strokeColor: Colors.black,
                    ),
                  ),
                );
              }).toList();
            },
          ),
          showingTooltipIndicators: indicatorList.map((index) {
            return ShowingTooltipIndicators(index, [
              LineBarSpot(lineBars[0], 1, lineBars[0].spots[index]),
            ]);
          }).toList(),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.indigo),
          ),
        ),
      ),
    );
  }
}
