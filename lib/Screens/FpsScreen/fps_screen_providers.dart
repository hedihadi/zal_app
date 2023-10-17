import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/utils.dart';
import 'package:screenshot/screenshot.dart';
import 'package:zal/Screens/HomeScreen/home_screen_providers.dart';
import '../../Functions/models.dart';

class FpsDataNotifier extends AutoDisposeAsyncNotifier<FpsData> {
  Future<FpsData> _fetchData(FpsData fpsData, String data) async {
    final uncompressedString = decompressGzip(data);
    final parsedData = jsonDecode(uncompressedString);
    for (final string in parsedData) {
      final parsedString = Map<String, dynamic>.from(jsonDecode(string)).entries.first;
      final msBetweenDisplayChange = double.parse(parsedString.value);
      final processName = parsedString.key;
      if (fpsData.chosenProcessName != null && fpsData.chosenProcessName == processName) {
        fpsData.fpsList.add((1000 / msBetweenDisplayChange).toPrecision(2));
      } else {
        fpsData.fpsList.add((1000 / msBetweenDisplayChange).toPrecision(2));
      }
    }
    fpsData.fpsList.sort((a, b) => a.compareTo(b));
    double fps1Percent = calculatePercentile(fpsData.fpsList, 0.01);
    double fps01Percent = calculatePercentile(fpsData.fpsList, 0.001);

    //double fps01Percent = calculatePercentile(fpsList, 0.1);
    double totalFPS = fpsData.fpsList.reduce((a, b) => a + b);
    double averageFPS = totalFPS / fpsData.fpsList.length;

    return fpsData.copyWith(fps: averageFPS.toPrecision(2), fps01Low: fps1Percent.toPrecision(2), fps001Low: fps01Percent.toPrecision(2));
  }

  void chooseProcessName(String name) {
    ref.read(socketObjectProvider.notifier).state!.sendData('start_fps', name);
    state = AsyncData(state.value!.copyWith(chosenProcessName: name));
  }

  FpsData fetchProcesses(FpsData fpsData, String data) {
    final uncompressedString = decompressGzip(data);
    final parsedData = List<String>.from(jsonDecode(uncompressedString));
    return fpsData.copyWith(processNames: parsedData);
  }

  void reset() {
    state = AsyncData(state.value!.copyWith(fpsList: [], fps: 0, fps001Low: 0, fps01Low: 0, timestamp: Timestamp.now()));
  }

  double calculatePercentile(List<double> data, double percentile) {
    double realIndex = (percentile) * (data.length - 1);
    int index = realIndex.toInt();
    double frac = realIndex - index;
    if (index + 1 < data.length) {
      return data[index] * (1 - frac) + data[index + 1] * frac;
    } else {
      return data[index];
    }
  }

  @override
  Future<FpsData> build() async {
    final socket = ref.watch(computerSocketStreamProvider);
    final streamData = socket.value;
    final FpsData fpsData = state.value ??
        FpsData(
          processNames: [],
          chosenProcessName: null,
          fpsList: [],
          fps: 0,
          fps01Low: 0,
          fps001Low: 0,
          timestamp: Timestamp.now(),
        );

    if (streamData!.type == StreamDataType.DATA) {
      return fpsData;
    }
    if (streamData.type == StreamDataType.FpsProcesses) {
      return fetchProcesses(fpsData, streamData.data);
    }

    return _fetchData(fpsData, streamData.data);
  }
}

final fpsDataProvider = AsyncNotifierProvider.autoDispose<FpsDataNotifier, FpsData>(() {
  return FpsDataNotifier();
});

class FpsPresetsNotifier extends StateNotifier<List<FpsPreset>> {
  // We initialize the list of todos to an empty list
  FpsPresetsNotifier() : super([]);
  void addPreset(FpsData fpsData, String presetName, String? note) {
    state = [
      FpsPreset(
          fpsData: fpsData,
          presetDuration: formatTime(((Timestamp.now().millisecondsSinceEpoch - fpsData.timestamp.millisecondsSinceEpoch) / 1000).round()),
          presetName: presetName,
          note: note),
      ...state,
    ];
  }

  void removePreset(FpsPreset fpsPreset) {
    state = state.where((element) => element != fpsPreset).toList();
  }
}

final fpsPresetsProvider = StateNotifierProvider<FpsPresetsNotifier, List<FpsPreset>>((ref) {
  return FpsPresetsNotifier();
});
