import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sentimen_mobile/app/data/models/scrape_news.dart';
import 'package:sentimen_mobile/app/data/models/sentiment_analysis.dart';
import 'package:sentimen_mobile/app/data/models/sentiment_statistics.dart';
import 'package:sentimen_mobile/app/services/base_client.dart';
import 'package:sentimen_mobile/config/environment/environment.dart';

class IndexController extends GetxController {
  var sentimentResults = <SentimentAnalysis>[].obs;
  var scrapedNewsList = <ScrapedNews>[].obs;
  var sentimentSummary = Rxn<SentimentStatistics>();
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var searchQuery = ''.obs;
  var selectedCategory = ''.obs;
  var errorMessage = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await fetchSentimentAnalysis();
    await fetchScrapedNews();
    await fetchSentimentStatistics();
  }

  Future<void> applyDateFilter(DateTime? start, DateTime? end) async {
    startDate.value = start;
    endDate.value = end;
    await fetchSentimentStatistics(startDate: start, endDate: end);
    await fetchSentimentAnalysis(startDate: start, endDate: end);
  }

  List<SentimentAnalysis> get filteredNews {
    final query = searchQuery.value.toLowerCase();
    final category = selectedCategory.value;

    return sentimentResults.where((item) {
      final matchQuery = item.title.toLowerCase().contains(query);
      final matchCategory =
          category == '' || category == 'Semua' || item.category == category;
      return matchQuery && matchCategory;
    }).toList();
  }

  Map<String, int> get sentimentCount {
    final count = {'Positif': 0, 'Negatif': 0, 'Netral': 0};
    for (var item in filteredNews) {
      final label = mapSentimentLabel(item.sentimentLabel);
      if (count.containsKey(label)) {
        count[label] = count[label]! + 1;
      }
    }
    return count;
  }

  String mapSentimentLabel(String raw) {
    switch (raw.toLowerCase()) {
      case 'positive':
        return 'Positif';
      case 'negative':
        return 'Negatif';
      case 'neutral':
        return 'Netral';
      default:
        return raw;
    }
  }

  Future<void> fetchScrapedNews({int skip = 0, int limit = 10}) async {
    EasyLoading.show(status: 'Please wait...');
    try {
      await BaseClient.safeApiCall(
        Environment.scrapedData,
        queryParameters: {
          "skip": skip,
          "limit": limit,
        },
        RequestType.get,
        onSuccess: (response) {
          final List results = response.data['results'] ?? [];
          scrapedNewsList.value =
              results.map((e) => ScrapedNews.fromJson(e)).toList();
        },
        onError: (error) {
          errorMessage.value = error.message;
        },
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> fetchSentimentAnalysis({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    EasyLoading.show(status: 'Please wait...');
    try {
      final params = <String, dynamic>{};
      if (startDate != null && endDate != null) {
        params["start_date"] = DateFormat('yyyy-MM-dd').format(startDate);
        params["end_date"] = DateFormat('yyyy-MM-dd').format(endDate);
      }

      await BaseClient.safeApiCall(
        Environment.sentimentAnalysis,
        RequestType.get,
        queryParameters: params.isEmpty ? null : params,
        onSuccess: (response) {
          final List results = (response.data['results'] ?? []) as List;
          sentimentResults.value =
              results.map((e) => SentimentAnalysis.fromJson(e)).toList();
        },
        onError: (error) {
          errorMessage.value = error.message;
        },
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> fetchSentimentStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    EasyLoading.show(status: 'Please wait...');
    try {
      final params = <String, dynamic>{};
      if (startDate != null && endDate != null) {
        params["start_date"] = DateFormat('yyyy-MM-dd').format(startDate);
        params["end_date"] = DateFormat('yyyy-MM-dd').format(endDate);
      }

      await BaseClient.safeApiCall(
        Environment.sentimentStatistics,
        RequestType.get,
        queryParameters: params.isEmpty ? null : params,
        onSuccess: (response) {
          try {
            sentimentSummary.value = SentimentStatistics.fromJson(
              Map<String, dynamic>.from(response.data ?? {}),
            );
          } catch (e) {
            errorMessage.value = "Data format tidak sesuai: $e";
          }
        },
        onError: (error) {
          errorMessage.value = error.message;
        },
      );
    } finally {
      EasyLoading.dismiss();
    }
  }
}
