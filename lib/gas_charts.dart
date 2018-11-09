import 'dart:core';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:gas_app/firebase_user_data.dart';
import 'package:gas_app/firebase_user_auth.dart';

class GasCharts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PageController _pageController = new PageController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Gas Charts'),
      ),
      body: Center(
        child: UserAuth.signedIn()
            ? UserSubmissionStream(builder: (context, List<UserSubmission> submissions) {
                if (submissions != null && submissions.length > 0) {
                  return PageView(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      // Gas Station Pie Chart
                      charts.PieChart(
                        getStationVisitCount(submissions),
                        animate: true,
                        defaultRenderer: charts.ArcRendererConfig(
                          arcRendererDecorators: [
                            charts.ArcLabelDecorator(
                              labelPosition: charts.ArcLabelPosition.auto,
                            ),
                          ],
                        ),
                      ),
                      // charts.TimeSeriesChart(
                      //   getGasPriceVsDate(entries),
                      //   animate: false,
                      //   defaultRenderer: charts.LineRendererConfig(includePoints: true),
                      //   primaryMeasureAxis: charts.NumericAxisSpec(
                      //     renderSpec: charts.GridlineRendererSpec(
                      //       // Tick and Label styling here.
                      //       labelStyle: charts.TextStyleSpec(
                      //         color: charts.MaterialPalette.white,
                      //       ),
                      //     ),
                      //   ),
                      //   secondaryMeasureAxis: charts.DateTimeAxisSpec(
                      //     renderSpec: charts.SmallTickRendererSpec(
                      //       labelStyle: charts.TextStyleSpec(color: charts.Color.white),
                      //     ),
                      //   ),
                      //   behaviors: [
                      //     charts.SlidingViewport(),
                      //     charts.PanAndZoomBehavior(),
                      //   ],
                      // ),
                      charts.TimeSeriesChart(
                        getGasPricePerStationVsDate(submissions),
                        animate: false,
                        defaultRenderer: charts.LineRendererConfig(includePoints: true),
                        domainAxis: charts.DateTimeAxisSpec(
                          renderSpec: charts.SmallTickRendererSpec(
                            // Tick and Label styling here.
                            labelStyle: charts.TextStyleSpec(
                              color: charts.MaterialPalette.white,
                            ),
                          ),
                        ),

                        // Assign a custom style for the measure axis.
                        primaryMeasureAxis: charts.NumericAxisSpec(
                          renderSpec: charts.GridlineRendererSpec(
                            // Tick and Label styling here.
                            labelStyle: charts.TextStyleSpec(
                              color: charts.MaterialPalette.white,
                            ),
                          ),
                        ),
                        behaviors: [
                          charts.SeriesLegend(),
                          charts.SlidingViewport(),
                          charts.PanAndZoomBehavior(),
                        ],
                      ),
                      charts.TimeSeriesChart(
                        getMPGVsDate(submissions),
                        animate: false,
                        defaultRenderer: charts.LineRendererConfig(includePoints: true),
                        primaryMeasureAxis: charts.NumericAxisSpec(
                          renderSpec: charts.GridlineRendererSpec(
                            // Tick and Label styling here.
                            labelStyle: charts.TextStyleSpec(
                              color: charts.MaterialPalette.white,
                            ),
                          ),
                        ),
                        behaviors: [
                          charts.SlidingViewport(),
                          charts.PanAndZoomBehavior(),
                        ],
                      ),
                      charts.TimeSeriesChart(
                        getMilesPerUSDVsDate(submissions),
                        animate: false,
                        defaultRenderer: charts.LineRendererConfig(includePoints: true),
                        primaryMeasureAxis: charts.NumericAxisSpec(
                          renderSpec: charts.GridlineRendererSpec(
                            // Tick and Label styling here.
                            labelStyle: charts.TextStyleSpec(
                              color: charts.MaterialPalette.white,
                            ),
                          ),
                        ),
                        behaviors: [
                          charts.SlidingViewport(),
                          charts.PanAndZoomBehavior(),
                        ],
                        // Set an initial viewport to demonstrate the sliding viewport behavior on
                        // initial chart load.
                      ),
                    ],
                  );
                } else {
                  return Center(child: Text('No submissions found.'));
                }
              })
            : Center(
                child: MaterialButton(
                  child: Text('Sign In'),
                  color: Colors.blueGrey,
                  onPressed: () {
                    showSignInPage(context);
                  },
                ),
              ),
      ),
    );
  }
}

List<charts.Series<UserSubmission, DateTime>> getGasPriceVsDate(List<UserSubmission> data) {
  return [
    charts.Series<UserSubmission, DateTime>(
      id: 'Gas Price vs Date',
      domainFn: (UserSubmission point, _) => point.date,
      measureFn: (UserSubmission point, _) => point.gasPrice,
      data: data,
    ),
  ];
}

List<charts.Series<UserSubmission, DateTime>> getMPGVsDate(List<UserSubmission> data) {
  return [
    charts.Series<UserSubmission, DateTime>(
      id: 'Stations',
      domainFn: (UserSubmission point, _) => point.date,
      measureFn: (UserSubmission point, _) => point.milesPerGallon,
      data: data,
    ),
  ];
}

List<charts.Series<UserSubmission, DateTime>> getMilesPerUSDVsDate(List<UserSubmission> data) {
  return [
    charts.Series<UserSubmission, DateTime>(
      id: 'Stations',
      domainFn: (UserSubmission point, _) => point.date,
      measureFn: (UserSubmission point, _) => point.milesPerUSD,
      data: data,
    ),
  ];
}

List<charts.Series<MapEntry<String, int>, int>> getStationVisitCount(List<UserSubmission> data) {
  Map<String, int> map = {};
  for (var p in data) {
    map.update(p.station, (value) => value + 1, ifAbsent: () => 1);
  }

  return [
    charts.Series<MapEntry<String, int>, int>(
      id: 'Stations',
      data: map.entries.toList(),
      domainFn: (entry, index) => index,
      measureFn: (entry, _) => entry.value,
      labelAccessorFn: (entry, _) => '${entry.key} : ${entry.value}',
      insideLabelStyleAccessorFn: (_, __) => charts.TextStyleSpec(color: charts.Color.black, fontSize: 12),
      outsideLabelStyleAccessorFn: (_, __) => charts.TextStyleSpec(color: charts.Color.white, fontSize: 15),
    ),
  ];
}

List<charts.Series<UserSubmission, DateTime>> getGasPricePerStationVsDate(List<UserSubmission> data) {
  Map<String, List<UserSubmission>> map = {};
  for (var p in data) {
    map.putIfAbsent(p.station, () => new List<UserSubmission>());
    map[p.station].add(p);
  }

  return map.entries.map<charts.Series<UserSubmission, DateTime>>((mapEntry) {
    return charts.Series<UserSubmission, DateTime>(
      id: mapEntry.key,
      data: mapEntry.value,
      domainFn: (entry, _) => entry.date,
      measureFn: (entry, _) => entry.gasPrice,
      insideLabelStyleAccessorFn: (_, __) => charts.TextStyleSpec(color: charts.Color.black, fontSize: 12),
      outsideLabelStyleAccessorFn: (_, __) => charts.TextStyleSpec(color: charts.Color.white, fontSize: 15),
    );
  }).toList();
}
