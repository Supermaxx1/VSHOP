import 'package:flutter/material.dart';
import '../services/printer_service.dart';

class PrinterProvider extends ChangeNotifier {
  final PrinterService _printerService = PrinterService();

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;
  bool _isScanning = false;
  bool _isConnecting = false;
  String _connectionStatus = 'Printing Disabled';

  List<BluetoothDevice> get devices => _devices;
  BluetoothDevice? get selectedDevice => _selectedDevice;
  bool get isConnected => _isConnected;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  String get connectionStatus => _connectionStatus;

  Future<void> scanForDevices() async {
    _setScanning(true);
    try {
      _devices = await _printerService.getBluetoothDevices();
      notifyListeners();
    } catch (e) {
      debugPrint('Error scanning for devices: $e');
    } finally {
      _setScanning(false);
    }
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    _setConnecting(true);
    _setConnectionStatus('Connecting...');

    try {
      final success = await _printerService.connectToPrinter(device.address);

      if (success) {
        _selectedDevice = device;
        _isConnected = true;
        _setConnectionStatus('Connected to ${device.name}');
      } else {
        _setConnectionStatus('Failed to connect');
      }

      notifyListeners();
      return success;
    } catch (e) {
      _setConnectionStatus('Connection error');
      debugPrint('Error connecting to device: $e');
      return false;
    } finally {
      _setConnecting(false);
    }
  }

  Future<void> disconnect() async {
    try {
      await _printerService.disconnect();
      _selectedDevice = null;
      _isConnected = false;
      _setConnectionStatus('Disconnected');
      notifyListeners();
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    }
  }

  Future<bool> testPrint() async {
    try {
      return await _printerService.printTestPage();
    } catch (e) {
      debugPrint('Error test printing: $e');
      return false;
    }
  }

  void _setScanning(bool scanning) {
    _isScanning = scanning;
    notifyListeners();
  }

  void _setConnecting(bool connecting) {
    _isConnecting = connecting;
    notifyListeners();
  }

  void _setConnectionStatus(String status) {
    _connectionStatus = status;
    notifyListeners();
  }
}
