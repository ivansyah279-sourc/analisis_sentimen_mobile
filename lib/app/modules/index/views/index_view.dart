import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:intl/intl.dart';
import 'package:sentimen_mobile/app/data/models/sentimen.dart';
import 'package:sentimen_mobile/app/modules/index/controllers/index_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class IndexView extends StatelessWidget {
  final IndexController controller = Get.put(IndexController());

  IndexView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (picked != null) {
                controller.applyDateFilter(picked.start, picked.end);
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.startDate.value = null;
            controller.endDate.value = null;
            await controller.fetchSentimentStatistics();
            await controller.fetchSentimentAnalysis();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final summary = controller.sentimentSummary.value;
                      if (summary == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatCard(
                              "Total Documents",
                              summary.totalDocuments.toString(),
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              "Positive Sentiments",
                              "${summary.percentages['positive']!.toStringAsFixed(1)}%",
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              "Negative Sentiments",
                              "${summary.percentages['negative']!.toStringAsFixed(1)}%",
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              "Netral Sentiments",
                              "${summary.percentages['neutral']!.toStringAsFixed(1)}%",
                            ),
                            // _buildStatCard(
                            //   "Average Confidence",
                            //   summary.averageConfidence.toStringAsFixed(2),
                            // ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 32),
                Obx(() {
                  final summary = controller.sentimentSummary.value;
                  if (summary == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final distribution = summary.sentimentDistribution;
                  final data = distribution.entries
                      .map(
                        (e) => Sentiment(e.key, e.value.toDouble()),
                      )
                      .toList();

                  return SfCircularChart(
                    title: const ChartTitle(text: 'Tren Sentimen'),
                    legend: const Legend(isVisible: true),
                    series: <CircularSeries>[
                      PieSeries<Sentiment, String>(
                        dataSource: data,
                        xValueMapper: (Sentiment d, _) => d.sentiment,
                        yValueMapper: (Sentiment d, _) => d.count,
                        dataLabelMapper: (Sentiment d, _) =>
                            '${d.sentiment}: ${d.count.toInt()}',
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                        emptyPointSettings: const EmptyPointSettings(
                          mode: EmptyPointMode.zero,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  );
                }),
                const SizedBox(height: 32),
                Text("Hasil Analisis Sentimen",
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Obx(() {
                  final news = controller.filteredNews;
                  if (news.isEmpty) {
                    return const Text("Tidak ada data.");
                  }
                  return SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: news.length,
                      itemBuilder: (context, index) {
                        final item = news[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Container(
                            width: 240,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Text(
                                  "Sentimen: ${controller.mapSentimentLabel(item.sentimentLabel)}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "Score: ${item.sentimentScore}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "Tingkat Keyakinan: ${item.confidenceScore}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade700),
        borderRadius: BorderRadius.circular(8),
        color: Colors.black, // Biar background card-nya jelas
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
