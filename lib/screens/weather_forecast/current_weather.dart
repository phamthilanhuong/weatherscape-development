import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather/weather.dart';
import 'package:weatherscape/config.dart';
import 'package:weatherscape/controllers/location_controller.dart';
import 'package:weatherscape/screens/weather_forecast/daily_weather.dart';
import 'package:weatherscape/controllers/weather_controller.dart';
import 'package:weatherscape/utils/unit_util.dart';
import 'package:weatherscape/utils/widget_util.dart';
import '../../utils/weather_icon.dart';
import 'line_chart_widget.dart';

class CurrentWeather extends ConsumerWidget {
  bool isExpanded;

  CurrentWeather({Key? key, this.isExpanded = true}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final weatherDataValue = ref.watch(currentWeatherControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        weatherDataValue.when(
          data: (weatherData) => isExpanded
              ? CurrentWeatherContentsExpanded(data: weatherData)
              : CurrentWeatherContentsShrinked(data: weatherData),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              var exceptionMessage = e.toString().contains("404")
                  ? "City not found"
                  : "Can't get weather data";
              WidgetTool.showNotifDialog(context, "Error", exceptionMessage);
            });
            return Center(
                child: Text(
              "Can't get weather data",
              style: textTheme.bodyText2,
            ));
          },
        ),
      ],
    );
  }
}

class CurrentWeatherContentsExpanded extends ConsumerWidget {
  const CurrentWeatherContentsExpanded({Key? key, required this.data})
      : super(key: key);
  final Weather data;
  final units = AppConfig.units;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    String temp = UnitUtil.getTemp(temp: data.temperature!, unit: units);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        WeatherIconImage(iconCode: data.weatherIcon!, size: 120),
        Text(temp, style: textTheme.headline2),
        ref.watch(todayMaxMinController).when(
              data: (maxMin) => Text(
                  "Highest: ${UnitUtil.getTemp(temp: maxMin[0]!, unit: units)} / Lowest: ${UnitUtil.getTemp(temp: maxMin[1]!, unit: units)}",
                  style: textTheme.bodyText2),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(),
            ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('UV Chart'),
            IconButton(
              icon: const Icon(Icons.warning),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: Text('UV page'), centerTitle: true),
                      body: Padding(
                        padding: const EdgeInsets.all(8),
                        child: PageView(
                          children: [
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              color: const Color(0xff020227),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: UVChart(
                                  uvData: [1, 2, 5, 13, 4, 3],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        )
      ],
    );
  }
}

class CurrentWeatherContentsShrinked extends ConsumerWidget {
  const CurrentWeatherContentsShrinked({Key? key, required this.data})
      : super(key: key);
  final Weather data;
  final units = AppConfig.units;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    String temp = UnitUtil.getTemp(temp: data.temperature!, unit: units);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WeatherIconImage(iconCode: data.weatherIcon!, size: 40),
            Text(temp, style: textTheme.bodyMedium),
          ],
        )
      ],
    );
  }
}

class CurrentWeatherContents extends ConsumerWidget {
  const CurrentWeatherContents({Key? key, required this.data})
      : super(key: key);
  final Weather data;
  final units = AppConfig.units;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    String temp = UnitUtil.getTemp(temp: data.temperature!, unit: units);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(ref.watch(cityProvider), style: textTheme.headline4),
        WeatherIconImage(iconCode: data.weatherIcon!, size: 120),
        Text(temp, style: textTheme.headline2),
        ref.watch(todayMaxMinController).when(
              data: (maxMin) => Text(
                  "Highest: ${UnitUtil.getTemp(temp: maxMin[0]!, unit: units)} / Lowest: ${UnitUtil.getTemp(temp: maxMin[1]!, unit: units)}",
                  style: textTheme.bodyText2),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(),
            ),
      ],
    );
  }
}
