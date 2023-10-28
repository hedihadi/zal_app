import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

enum StorageType { SSD, HDD }

enum stressTestType { Ram, Cpu, Gpu }

enum SortBy { Name, Memory, Cpu }

enum DataType { Hardwares, TaskManager }

enum StreamDataType { FPS, DATA, RoomClients, DiskData }

enum QrCodeSwitchState { camera, text }

///this is solely used in home_screen for gpus widget
class ComputerDataWithBuildContext {
  final ComputerData computerData;
  final BuildContext context;
  ComputerDataWithBuildContext({
    required this.computerData,
    required this.context,
  });
}

class StreamData {
  StreamDataType type;
  dynamic data;
  StreamData({
    required this.type,
    required this.data,
  });
}

class FpsData {
  String? processName;
  List<double> fpsList;
  double fps;
  double fps01Low;
  double fps001Low;
  FpsData({
    required this.processName,
    required this.fpsList,
    required this.fps,
    required this.fps01Low,
    required this.fps001Low,
  });

  FpsData copyWith({
    String? processName,
    List<double>? fpsList,
    double? fps,
    double? fps01Low,
    double? fps001Low,
    DateTime? date,
  }) {
    return FpsData(
      processName: processName ?? this.processName,
      fpsList: fpsList ?? this.fpsList,
      fps: fps ?? this.fps,
      fps01Low: fps01Low ?? this.fps01Low,
      fps001Low: fps001Low ?? this.fps001Low,
    );
  }
}

class FpsRecord {
  FpsData fpsData;
  String presetName;

  ///how long the fps was running, in formatted text.
  String presetDuration;
  String? note;

  FpsRecord({
    required this.fpsData,
    required this.presetName,
    required this.presetDuration,
    this.note,
  });
}

///a class that contains fps and time, this is used to represent fps data on a line chart.
class FpsTime {
  double fps;
  DateTime time;
  FpsTime({
    required this.fps,
    required this.time,
  });
}

///we use this class to store the computer specs
class ComputerSpecs {
  String motherboardName;
  String ramSize;
  List<String> gpusName;
  String cpuName;

  List<String> storages;
  List<String> monitors;
  ComputerSpecs({
    required this.motherboardName,
    required this.ramSize,
    required this.gpusName,
    required this.cpuName,
    required this.storages,
    required this.monitors,
  });
  factory ComputerSpecs.fromComputerData(ComputerData data) {
    return ComputerSpecs(
      motherboardName: data.motherboard.name,
      ramSize: "${(data.ram.memoryAvailable + data.ram.memoryUsed).toStringAsFixed(2)}GB",
      gpusName: data.gpus.map((e) => e.name).toList(),
      cpuName: data.cpu.name,
      storages: data.storages.map((e) => '${(e.size / 1000 / 1000 / 1000).round()} GB ${e.type.name}').toList(),
      monitors: data.monitors.map((e) => '${e.width} x ${e.height}${e.primary ? ' primary' : ''}').toList(),
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'motherboardName': motherboardName});
    result.addAll({'ramSize': ramSize});
    result.addAll({'gpusName': gpusName});
    result.addAll({'cpuName': cpuName});
    result.addAll({'storages': storages});
    result.addAll({'monitors': monitors});

    return result;
  }

  factory ComputerSpecs.fromMap(Map<String, dynamic> map) {
    return ComputerSpecs(
      motherboardName: map['motherboardName'] ?? '',
      ramSize: map['ramSize'] ?? '',
      gpusName: map['gpusName'] ?? '',
      cpuName: map['cpuName'] ?? '',
      storages: List<String>.from(map['storages']),
      monitors: List<String>.from(map['monitors']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ComputerSpecs.fromJson(String source) => ComputerSpecs.fromMap(json.decode(source));
}

class NetworkSpeed {
  ///in bytes
  final int download;

  ///in bytes
  final int upload;

  NetworkSpeed({
    required this.download,
    required this.upload,
  });

  factory NetworkSpeed.fromMap(Map<String, dynamic> map) {
    return NetworkSpeed(
      download: map['download']?.toInt() ?? 0,
      upload: map['upload']?.toInt() ?? 0,
    );
  }
}

class ComputerData {
  late Ram ram;
  late Cpu cpu;
  late List<Gpu> gpus;
  late List<Storage> storages;
  late List<Monitor> monitors;
  late Motherboard motherboard;
  late Battery battery;
  List<NetworkInterface>? networkInterfaces;
  List<TaskmanagerProcess>? taskmanagerProcesses;
  late NetworkSpeed networkSpeed;
  ComputerData();

  ComputerData.construct(String data) {
    final parsedData = jsonDecode(data.replaceAll("'", '"'));
    ram = Ram.fromMap(parsedData['ram']);
    cpu = Cpu.fromMap(parsedData['cpu']);
    gpus = List<Gpu>.from(List<Map<String, dynamic>>.from(parsedData['gpu']).map((e) => Gpu.fromMap(e)).toList());
    motherboard = Motherboard.fromMap(parsedData['motherboard']);
    battery = Battery.fromMap(parsedData['battery']);
    storages = Map<String, dynamic>.from(parsedData['storages']).entries.toList().map((e) => Storage.fromMap(e.key, e.value)).toList();
    storages.sort((a, b) => a.diskNumber.compareTo(b.diskNumber));
    monitors = List<Map<String, dynamic>>.from(parsedData['monitors']).map((e) => Monitor.fromMap(e)).toList();
    if (parsedData.containsKey("taskmanager")) {
      taskmanagerProcesses =
          Map<String, dynamic>.from(parsedData['taskmanager']).entries.toList().map((e) => TaskmanagerProcess.fromMap(e.key, e.value)).toList();
    }
    if (parsedData.containsKey("networkInterface")) {
      networkInterfaces = List<Map<String, dynamic>>.from(parsedData['networkInterface']).map((e) => NetworkInterface.fromMap(e)).toList();
    }
    networkSpeed = NetworkSpeed.fromMap(parsedData['networkSpeed']);
  }
}

class NetworkInterface {
  final String name;
  final String description;
  final bool isEnabled;
  final String id;
  final int bytesSent;
  final int bytesReceived;
  final bool isPrimary;
  NetworkInterface({
    required this.name,
    required this.description,
    required this.isEnabled,
    required this.id,
    required this.bytesSent,
    required this.bytesReceived,
    required this.isPrimary,
  });

  factory NetworkInterface.fromMap(Map<String, dynamic> map) {
    return NetworkInterface(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      isEnabled: (map['status'] ?? "Down") != "Down",
      id: map['id'] ?? '',
      bytesSent: map['bytesSent']?.toInt() ?? 0,
      bytesReceived: map['bytesReceived']?.toInt() ?? 0,
      isPrimary: map['isPrimary'] ?? false,
    );
  }

  factory NetworkInterface.fromJson(String source) => NetworkInterface.fromMap(json.decode(source));
}

class Battery {
  ///is the laptop being charged or not.
  bool isCharging;

  ///the amount of charge the battery has left, it's between 0 and 100
  int batteryPercentage;

  ///the remaining time before the battery runs out, in seconds.
  int lifeRemaining;

  ///whether the pc has a battery or not
  bool hasBattery;
  Battery({
    required this.isCharging,
    required this.batteryPercentage,
    required this.lifeRemaining,
    required this.hasBattery,
  });

  factory Battery.fromMap(Map<String, dynamic> map) {
    return Battery(
      isCharging: map['isCharging'] ?? false,
      batteryPercentage: map['life']?.toInt() ?? 0,
      lifeRemaining: map['lifeRemaining']?.toInt() ?? 0,
      hasBattery: map['hasBattery'] ?? false,
    );
  }

  factory Battery.fromJson(String source) => Battery.fromMap(json.decode(source));
}

class Cpu {
  /// name of the cpu
  String name;

  /// in celcious
  double? temperature;

  /// power in watts
  double power;

  /// watts used by each core
  SplayTreeMap<String, double> powers = SplayTreeMap();

  /// clock speed in mhz for each core
  SplayTreeMap<String, double?> clocks = SplayTreeMap();

  /// overall load of the cpu in percentage;
  double load;

  /// load percentage of each core
  SplayTreeMap<String, double> loads = SplayTreeMap();

  /// voltage of each core
  SplayTreeMap<String, double> voltages = SplayTreeMap();

  //static information about the cpu
  CpuInfo cpuInfo;
  Cpu({
    required this.name,
    required this.temperature,
    required this.power,
    required this.powers,
    required this.clocks,
    required this.load,
    required this.loads,
    required this.voltages,
    required this.cpuInfo,
  });

  factory Cpu.fromMap(Map<String, dynamic> map) {
    SplayTreeMap<String, double?> clocks = SplayTreeMap<String, double?>();
    for (final clock in Map<String, dynamic>.from(map['clocks']).entries) {
      if (clock.value == "NaN") {
        clocks[clock.key] = null;
      } else {
        clocks[clock.key] = clock.value;
      }
    }
    double? temperature = map['temperature']?.toDouble();
    if (temperature == null || temperature < 0.1) {
      temperature = null;
    }
    final cpu = Cpu(
      name: map['name'] ?? '',
      temperature: temperature,
      power: map['power']?.toDouble() ?? 0.0,
      powers: SplayTreeMap<String, double>.from(map['powers']),
      clocks: clocks,
      load: map['load']?.toDouble() ?? 0.0,
      loads: SplayTreeMap<String, double>.from(map['loads']),
      voltages: SplayTreeMap<String, double>.from(map['voltages']),
      cpuInfo: CpuInfo.fromMap(map['info']),
    );

    cpu.loads = SplayTreeMap<String, double>.from(map['loads'], (a, b) => extractFirstNumber(a).compareTo(extractFirstNumber(b)));
    cpu.clocks.removeWhere((key, value) => key.contains('Core') == false);
    if (cpu.clocks.containsValue(null) == false) {
      cpu.clocks = SplayTreeMap<String, double>.from(cpu.clocks, (a, b) => extractFirstNumber(a).compareTo(extractFirstNumber(b)));
    }
    return cpu;
  }
  static int extractFirstNumber(String input) {
    RegExp regExp = RegExp(r'\d+');
    Match? match = regExp.firstMatch(input);
    if (match != null) {
      String numberString = match.group(0) ?? '-1';
      int? number = int.tryParse(numberString);
      if (number != null) {
        return number;
      }
    }
    return -1;
  }

  factory Cpu.fromJson(String source) => Cpu.fromMap(json.decode(source));
  double getAverageClock() {
    if (clocks.values.toList().contains(null)) return 0;

    final List<double> numbersList = List<double>.from(clocks.values.toList());
    if (numbersList.isEmpty) {
      return 0.0; // Return 0 if the list is empty to avoid division by zero
    }
    double sum = numbersList.reduce((value, element) => value + element);
    return sum / numbersList.length;
  }

  CpuCoreInfo getCpuCoreinfo(int index) {
    final clocksList = clocks.entries.toList();
    final loadsList = loads.entries.toList();
    final voltagesList = voltages.entries.toList();
    final powersList = powers.entries.toList();

    final clock = clocksList.length > (index) ? clocksList[index].value : null;
    final load = loadsList.length > (index) ? loadsList[index].value : null;
    final voltage = voltagesList.length > (index) ? voltagesList[index].value : null;
    final power = powersList.length > (index) ? powersList[index].value : null;
    return CpuCoreInfo(clock: clock, load: load, voltage: voltage, power: power);
  }
}

class CpuCoreInfo {
  double? clock;
  double? load;
  double? voltage;
  double? power;
  CpuCoreInfo({
    required this.clock,
    required this.load,
    required this.voltage,
    required this.power,
  });
}

class CpuInfo {
  String name;
  String socket;
  int speed;
  int busSpeed;
  int l2Cache;
  int l3Cache;
  int cores;
  int threads;
  CpuInfo({
    required this.name,
    required this.socket,
    required this.speed,
    required this.busSpeed,
    required this.l2Cache,
    required this.l3Cache,
    required this.cores,
    required this.threads,
  });

  factory CpuInfo.fromMap(Map<String, dynamic> map) {
    return CpuInfo(
      name: map['name'] ?? '',
      socket: map['socket'] ?? '',
      speed: map['speed']?.toInt() ?? 0,
      busSpeed: map['busSpeed']?.toInt() ?? 0,
      l2Cache: map['l2Cache']?.toInt() ?? 0,
      l3Cache: map['l3Cache']?.toInt() ?? 0,
      cores: map['cores']?.toInt() ?? 0,
      threads: map['threads']?.toInt() ?? 0,
    );
  }
  factory CpuInfo.fromJson(String source) => CpuInfo.fromMap(json.decode(source));
}

class Motherboard {
  String name;
  double temperature;
  Motherboard({
    required this.name,
    required this.temperature,
  });

  factory Motherboard.fromMap(Map<String, dynamic> map) {
    return Motherboard(
      name: map['name'] ?? '',
      temperature: map['temperature']?.toDouble() ?? 0.0,
    );
  }

  factory Motherboard.fromJson(String source) => Motherboard.fromMap(json.decode(source));
}

class Gpu {
  /// name of the gpu
  String name;

  /// core speed in mhz
  double coreSpeed;

  /// memory speed in mhz
  double memorySpeed;
  double fanSpeedPercentage;

  /// core load in percentage
  double corePercentage;

  ///power used by gpu in watts
  double power;

  ///memory used in megabytes
  double dedicatedMemoryUsed;

  ///in celcious
  double temperature;
  double voltage;
  int fps;
  Gpu({
    required this.name,
    required this.coreSpeed,
    required this.memorySpeed,
    required this.fanSpeedPercentage,
    required this.corePercentage,
    required this.power,
    required this.dedicatedMemoryUsed,
    required this.temperature,
    required this.voltage,
    required this.fps,
  });

  factory Gpu.fromMap(Map<String, dynamic> map) {
    return Gpu(
      name: map['name'] ?? '',
      coreSpeed: map['coreSpeed']?.toDouble() ?? 0.0,
      memorySpeed: map['memorySpeed']?.toDouble() ?? 0.0,
      fanSpeedPercentage: map['fanSpeedPercentage']?.toDouble() ?? 0.0,
      corePercentage: map['corePercentage']?.toDouble() ?? 0.0,
      power: map['power']?.toDouble() ?? 0.0,
      dedicatedMemoryUsed: map['dedicatedMemoryUsed']?.toDouble() ?? 0.0,
      temperature: map['temperature']?.toDouble() ?? 0.0,
      voltage: map['voltage']?.toDouble() ?? 0.0,
      fps: (map['fps'] ?? 0).round(),
    );
  }

  factory Gpu.fromJson(String source) => Gpu.fromMap(json.decode(source));

  factory Gpu.max(Gpu oldGpu, Gpu newGpu) {
    return Gpu(
      name: newGpu.name,
      coreSpeed: oldGpu.coreSpeed < newGpu.coreSpeed ? newGpu.coreSpeed : oldGpu.coreSpeed,
      memorySpeed: oldGpu.memorySpeed < newGpu.memorySpeed ? newGpu.memorySpeed : oldGpu.memorySpeed,
      fanSpeedPercentage: oldGpu.fanSpeedPercentage < newGpu.fanSpeedPercentage ? newGpu.fanSpeedPercentage : oldGpu.fanSpeedPercentage,
      corePercentage: oldGpu.corePercentage < newGpu.corePercentage ? newGpu.corePercentage : oldGpu.corePercentage,
      power: oldGpu.power < newGpu.power ? newGpu.power : oldGpu.power,
      dedicatedMemoryUsed: oldGpu.dedicatedMemoryUsed < newGpu.dedicatedMemoryUsed ? newGpu.dedicatedMemoryUsed : oldGpu.dedicatedMemoryUsed,
      temperature: oldGpu.temperature < newGpu.temperature ? newGpu.temperature : oldGpu.temperature,
      voltage: oldGpu.voltage < newGpu.voltage ? newGpu.voltage : oldGpu.voltage,
      fps: oldGpu.fps < newGpu.fps ? newGpu.fps : oldGpu.fps,
    );
  }
}

class Ram {
  double memoryUsed;
  double memoryAvailable;
  double memoryUsedPercentage;
  List<RamPiece> ramPieces;
  Ram({
    required this.memoryUsed,
    required this.memoryAvailable,
    required this.memoryUsedPercentage,
    required this.ramPieces,
  });

  factory Ram.fromMap(Map<String, dynamic> map) {
    return Ram(
      memoryUsed: map['memoryUsed']?.toDouble() ?? 0.0,
      memoryAvailable: map['memoryAvailable']?.toDouble() ?? 0.0,
      memoryUsedPercentage: map['memoryUsedPercentage']?.toDouble() ?? 0.0,
      ramPieces: List<Map<String, dynamic>>.from(map['pieces']).map((e) => RamPiece.fromMap(e)).toList(),
    );
  }

  factory Ram.fromJson(String source) => Ram.fromMap(json.decode(source));

  factory Ram.max(Ram oldRam, Ram newRam) {
    return Ram(
      memoryUsed: oldRam.memoryUsed < newRam.memoryUsed ? newRam.memoryUsed : oldRam.memoryUsed,
      memoryAvailable: oldRam.memoryAvailable < newRam.memoryAvailable ? newRam.memoryAvailable : oldRam.memoryAvailable,
      memoryUsedPercentage: oldRam.memoryAvailable < newRam.memoryUsedPercentage ? newRam.memoryUsedPercentage : oldRam.memoryUsedPercentage,
      ramPieces: oldRam.ramPieces,
    );
  }
}

class RamPiece {
  int capacity;
  String manufacturer;
  String partNumber;
  int speed;
  RamPiece({
    required this.capacity,
    required this.manufacturer,
    required this.partNumber,
    required this.speed,
  });

  factory RamPiece.fromMap(Map<String, dynamic> map) {
    return RamPiece(
      capacity: map['capacity']?.toInt() ?? 0,
      manufacturer: map['manufacturer'] ?? '',
      partNumber: ((map['partNumber'] ?? '') as String).replaceAll("  ", ""),
      speed: map['speed']?.toInt() ?? 0,
    );
  }
}

class SocketObject {
  late Socket socket;
  Timer? timer;
  SocketObject(String uid, String idToken) {
    socket = io(
      //'https://api.zalapp.com',
      'http://192.168.0.107:5000',
      <String, dynamic>{
        'transports': ['websocket'],
        'query': {
          'EIO': '3',
          'uid': uid,
          'idToken': idToken,
          'type': 1,
        },
      },
    );

    socket.on('connection', (_) {
      print('connect ${_.toString()}');
    });
    socket.on('connect_error', (_) {
      var a = _.message.toString();
      print('error ${_.toString()}');
    });
    socket.onConnect((_) {
      //join the room
      // joinRoom();
      //send a keep_alive event so the pc starts sending data
      //socket.emit("keep_alive", "");
    });

    //send keep_alive event every 9 seconds so the computer's socket won't go into sleep mode
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      //socket.emit("keep_alive", "");
    });
  }

  sendData(String to, String data) {
    socket.emit(to, {'data': data});
  }

  // initiateTaskmanager() {
  //   if (timer != null) {
  //     socket.emit("taskmanager_keep_alive", "hi");
  //     timer = Timer.periodic(Duration(seconds: 9), (Timer t) {
  //       socket.emit("taskmanager_keep_alive", "hi");
  //     });
  //   }
  // }

  endTaskManager() {
    timer?.cancel();
    timer = null;
  }
}

class Storage {
  String name;
  double size;
  StorageType type;
  double readRate;
  double writeRate;
  double freeSpace;
  List<String> partitions;
  int diskNumber;
  double temperature;
  Storage({
    required this.name,
    required this.size,
    required this.readRate,
    required this.writeRate,
    required this.freeSpace,
    required this.partitions,
    required this.type,
    required this.diskNumber,
    required this.temperature,
  });

  factory Storage.fromMap(String name, Map<String, dynamic> map) {
    return Storage(
      name: name,
      size: map['size']?.toDouble() ?? 0.0,
      readRate: map['readRate']?.toDouble() ?? 0.0,
      writeRate: map['writeRate']?.toDouble() ?? 0.0,
      freeSpace: map['freeSpace']?.toDouble() ?? 0.0,
      partitions: List<String>.from(map['partitions']),
      type: map['mediaType'] == 'HDD' ? StorageType.HDD : StorageType.SSD,
      diskNumber: map['diskNumber'] ?? -1,
      temperature: map['temperature']?.toDouble() ?? 0.0,
    );
  }
}

class TaskmanagerProcess {
  ///this contains the list of processes,
  ///sometimes a program runs multiple processes,
  ///for example, firefox has more than 8 processes when you use it, we combine all the processes and get a sum of the usage for that program.
  List<int> pids;
  String name;

  ///in megabytes
  double memoryUsage;
  double cpuPercent;
  Uint8List? icon;

  ///in megabytes per second
  double diskReadRate;

  ///in megabytes per second
  double diskWriteRate;

  ///in megabytes per second
  double networkReadRate;

  ///in megabytes per second
  double networkWriteRate;

  ///sum of read/write
  double networkUsage;

  ///sum of read/write
  double diskUsage;
  TaskmanagerProcess({
    required this.pids,
    required this.name,
    required this.memoryUsage,
    required this.cpuPercent,
    required this.diskReadRate,
    required this.diskWriteRate,
    required this.networkReadRate,
    required this.networkWriteRate,
    required this.networkUsage,
    required this.diskUsage,
    this.icon,
  });

  factory TaskmanagerProcess.fromMap(String name, Map<String, dynamic> data) {
    Uint8List? icon;
    if (data['icon'] != null) {
      icon = base64Decode(data['icon']);
    }
    return TaskmanagerProcess(
      pids: List<int>.from(data['pids'] ?? []),
      name: name,
      memoryUsage: data['memoryUsage']?.toDouble() ?? 0.0,
      cpuPercent: data['cpuPercent']?.toDouble() ?? 0.0,
      icon: icon,
      diskReadRate: data['diskReadRate']?.toDouble() ?? 0.0,
      diskWriteRate: data['diskWriteRate']?.toDouble() ?? 0.0,
      networkReadRate: data['networkReadRate']?.toDouble() ?? 0.0,
      networkWriteRate: data['networkWriteRate']?.toDouble() ?? 0.0,
      networkUsage: 0,
      diskUsage: 0,
      //networkUsage: (data['networkReadRate'] + data['networkWriteRate'])?.toDouble() ?? 0.0,
      //diskUsage: (data['diskReadRate'] + data['diskWriteRate'])?.toDouble() ?? 0.0,
    );
  }
}

class Monitor {
  String name;
  bool primary;
  int height;
  int width;
  int bitsPerPixel;
  Monitor({
    required this.name,
    required this.primary,
    required this.height,
    required this.width,
    required this.bitsPerPixel,
  });

  factory Monitor.fromMap(Map<String, dynamic> map) {
    return Monitor(
      name: map['name'] ?? '',
      primary: map['primary'] ?? false,
      height: map['height']?.toInt() ?? 0,
      width: map['width']?.toInt() ?? 0,
      bitsPerPixel: map['bitsPerPixel']?.toInt() ?? 0,
    );
  }
  factory Monitor.fromJson(String source) => Monitor.fromMap(json.decode(source));
}

class Settings {
  bool personalizedAds;
  bool useCelcius;
  bool sendAnalaytics;
  String? primaryGpuName;
  Settings({
    required this.personalizedAds,
    required this.useCelcius,
    required this.sendAnalaytics,
    required this.primaryGpuName,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    result.addAll({'sendAnalaytics': sendAnalaytics});
    result.addAll({'personalizedAds': personalizedAds});
    result.addAll({'useCelcius': useCelcius});
    result.addAll({'primaryGpuName': primaryGpuName});

    return result;
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      personalizedAds: map['personalizedAds'] ?? true,
      useCelcius: map['useCelcius'] ?? true,
      sendAnalaytics: map['sendAnalaytics'] ?? true,
      primaryGpuName: map['primaryGpuName'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Settings.fromJson(String source) => Settings.fromMap(json.decode(source));

  Settings copyWith({bool? personalizedAds, bool? useCelcius, bool? sendAnalaytics, String? primaryGpuName}) {
    return Settings(
      personalizedAds: personalizedAds ?? this.personalizedAds,
      useCelcius: useCelcius ?? this.useCelcius,
      sendAnalaytics: sendAnalaytics ?? this.sendAnalaytics,
      primaryGpuName: primaryGpuName ?? this.primaryGpuName,
    );
  }

  factory Settings.defaultSettings() {
    return Settings.fromMap({});
  }
}

class StorageInfo {
  Map<String, dynamic> info;
  List<Map<String, dynamic>>? smartAttributes;
  StorageInfo({
    required this.info,
    required this.smartAttributes,
  });

  factory StorageInfo.fromMap(Map<String, dynamic> map) {
    return StorageInfo(
      info: Map<String, dynamic>.from(map['info']),
      smartAttributes: map['smartAttributes'] == null ? null : List<Map<String, dynamic>>.from(map['smartAttributes']),
    );
  }

  factory StorageInfo.fromJson(String source) => StorageInfo.fromMap(json.decode(source));
}

class DataIsNullException implements Exception {
  DataIsNullException();
}

class ComputerOfflineException implements Exception {
  ComputerOfflineException();
}

class NotConnectedToSocketException implements Exception {
  NotConnectedToSocketException();
}

class ErrorParsingComputerData implements Exception {
  final String data;
  ErrorParsingComputerData(this.data);
}

class TooEarlyToReturnError implements Exception {
  TooEarlyToReturnError();
}
