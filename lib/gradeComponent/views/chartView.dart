import 'dart:math';

import 'package:campus_flutter/gradeComponent/viewModels/gradeViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartView extends StatefulWidget {
  const ChartView({super.key, required this.studyID, required this.title});

  final String title;
  final String studyID;

  @override
  State<StatefulWidget> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  late Map<double, int> data;

  @override
  void initState() {
    data = Provider.of<GradeViewModel>(context, listen: false)
        .chartDataForDegree(widget.studyID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
        title: ChartTitle(text: "${widget.title} ${widget.studyID}"),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: data.values.reduce(max).toDouble(),
            interval: 1),
        series: <ChartSeries<MapEntry<double, int>, String>>[
          ColumnSeries<MapEntry<double, int>, String>(
            dataSource: data.entries.toList(),
            xValueMapper: (MapEntry<double, int> data, _) =>
                data.key.toString(),
            yValueMapper: (MapEntry<double, int> data, _) => data.value,
            pointColorMapper: (MapEntry<double, int> data, _) =>
                GradeViewModel.getColor(data.key),
          )
        ]);
  }
}
