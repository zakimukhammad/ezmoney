import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';
import '../../../utils/formatters.dart';

class StatsView extends GetView<HomeController> {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(
              () => SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Daily', label: Text('Daily')),
                  ButtonSegment(value: 'Weekly', label: Text('Weekly')),
                  ButtonSegment(value: 'Monthly', label: Text('Monthly')),
                ],
                selected: {controller.statsType.value},
                onSelectionChanged: (Set<String> newSelection) {
                  controller.statsType.value = newSelection.first;
                  controller.loadStats();
                },
              ),
            ),
          ),

          // Chart
          Expanded(
            flex: 2,
            child: Obx(() {
              if (controller.groupedStats.isEmpty) {
                return const Center(child: Text("No expenses for this period"));
              }
              return PieChart(
                PieChartData(
                  sections: controller.groupedStats.entries.map((e) {
                    return PieChartSectionData(
                      value: e.value,
                      title: e.key,
                      color:
                          Colors.primaries[controller.groupedStats.keys
                                  .toList()
                                  .indexOf(e.key) %
                              Colors.primaries.length],
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              );
            }),
          ),

          // List
          Expanded(
            flex: 2,
            child: Obx(
              () => ListView(
                children: controller.groupedStats.entries.map((e) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Colors.primaries[controller.groupedStats.keys
                                  .toList()
                                  .indexOf(e.key) %
                              Colors.primaries.length],
                      radius: 10,
                    ),
                    title: Text(e.key),
                    trailing: Text(CurrencyFormatter.format(e.value)),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
