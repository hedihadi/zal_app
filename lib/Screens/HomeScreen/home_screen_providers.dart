import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/AccountScreen/account_screen_providers.dart';
import 'package:zal/Screens/LoginScreen/login_providers.dart';

class SocketNotifier extends AsyncNotifier<ComputerData> {
  bool isProgramRunningAsAdminstrator = true;
  bool isConnected = false;
  bool isComputerConnected = false;
  List<StorageInfo> storageInfos = [];
  Future<ComputerData> _fetchData(String data) async {
    final computerData = ComputerData.construct(decompressGzip(data));
    return computerData;
  }

  Future<void> _fetchDiskData(String data) async {
    String uncompressedData = decompressGzip(data);
    final parsedData = jsonDecode(uncompressedData);
    storageInfos.clear();
    for (final parsedStorage in parsedData) {
      final storageInfo = StorageInfo.fromMap(parsedStorage);
      storageInfos.add(storageInfo);
    }
  }

  @override
  Future<ComputerData> build() async {
    final socket = ref.watch(computerSocketStreamProvider);
    isConnected = ref.watch(isConnectedProvider);
    if ((ref.read(timerProvider).value ?? 0) <= 3) {
      ref.watch(timerProvider);
    }
    final streamData = socket.value;
    if (isConnected == false) {
      return attemptToReturnOldData(NotConnectedToSocketException());
    }
    if (streamData != null) {
      if (streamData.type == StreamDataType.RoomClients) {
        if (List<int>.from(streamData.data).contains(0) == false) {
          isComputerConnected = false;
          return attemptToReturnOldData(ComputerOfflineException());
        }
        isComputerConnected = true;
      }

      if (streamData.type == StreamDataType.DATA) {
        try {
          final data = await _fetchData(streamData.data);
          if (data.cpu.clocks.containsValue(null) && data.cpu.temperature == null) {
            isProgramRunningAsAdminstrator = false;
          } else {
            isProgramRunningAsAdminstrator = true;
            //if program is running as adminstrator, that means we have all the data available, let's save it.
            ref.read(computerSpecsProvider.notifier).saveSettings(data);
          }
          isComputerConnected = true;
          return data;
        } on Exception {
          throw ErrorParsingComputerData(streamData.data);
        }
      } else if (streamData.type == StreamDataType.DiskData) {
        _fetchDiskData(streamData.data);
      }
    }
    return attemptToReturnOldData(DataIsNullException());
  }

  ComputerData attemptToReturnOldData(Exception ifNull) {
    if (state.value != null) {
      return state.value!;
    }
    //dont show any error until at least 3 seconds has passed since launch of the app.
    if ((ref.read(timerProvider).value ?? 0) <= 3) {
      throw TooEarlyToReturnError();
    }
    throw ifNull;
  }

  stressTest(String stressTestType, int seconds, {Map<String, dynamic> extraQuery = const {}}) {
    final Map<String, dynamic> data = {
      'type': stressTestType,
      'seconds': seconds,
    };
    data.addAll(extraQuery);
    ref.read(socketObjectProvider.notifier).state!.sendData("stress_test", jsonEncode(data));
  }
}

///we use this provider to see how much time has passed since the launch of the app,
///if the app is just recently launched, we will not show "not connected to server" errors
///until a few seconds has passed.
final timerProvider = StreamProvider<int>((ref) {
  final stopwatch = Stopwatch()..start();
  return Stream.periodic(const Duration(seconds: 1), (count) {
    return stopwatch.elapsed.inSeconds;
  });
});
final socketProvider = AsyncNotifierProvider<SocketNotifier, ComputerData>(() {
  return SocketNotifier();
});

final isConnectedProvider = StateProvider<bool>((ref) => false);

final computerSocketStreamProvider = StreamProvider<StreamData>((ref) async* {
  StreamController stream = StreamController();
  final socket = ref.watch(socketObjectProvider);
  if (socket != null) {
    socket.socket.on('pc_data', (data) {
      stream.add(StreamData(type: StreamDataType.DATA, data: data));
    });
    socket.socket.onConnect((data) {
      ref.read(isConnectedProvider.notifier).state = true;
      print("connected");
    });
    socket.socket.onDisconnect((data) {
      ref.read(isConnectedProvider.notifier).state = false;
      print("disconnected");
    });

    socket.socket.on('fps_data', (data) {
      stream.add(StreamData(type: StreamDataType.FPS, data: data));
    });
    socket.socket.on('room_clients', (data) {
      stream.add(StreamData(type: StreamDataType.RoomClients, data: data));
    });
    socket.socket.on('disk_data', (data) {
      stream.add(StreamData(type: StreamDataType.DiskData, data: data));
    });
  }

  await for (final value in stream.stream) {
    if (value != null) {
      yield value as StreamData;
    }
  }
});

final socketObjectProvider = StateProvider<SocketObject?>((ref) {
  final socket = ref.watch(_socketProvider);

  return socket.value;
});
final _socketProvider = FutureProvider((ref) async {
  final auth = ref.watch(authProvider);
  if (auth.value != null) {
    final idToken = await auth.value!.getIdToken();
    if (idToken != null) {
      return SocketObject(auth.value!.uid, idToken);
    }
  }
  return null;
});
