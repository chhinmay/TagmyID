import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TagMyIdProApp());
}

class TagMyIdProApp extends StatelessWidget {
  const TagMyIdProApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TagMyId Pro Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TagMyIdHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TagMyIdDeviceService {
  static const MethodChannel _channel = MethodChannel('com.tagmyid.device/api');

  Future<bool> initializeDevice() async {
    try {
      final bool result = await _channel.invokeMethod('initializeDevice');
      return result;
    } on PlatformException catch (e) {
      debugPrint("Failed to initialize device: '${e.message}'.");
      return false;
    }
  }

  Future<String?> scanDeviceData() async {
    try {
      final String? data = await _channel.invokeMethod('scanData');
      return data;
    } on PlatformException catch (e) {
      debugPrint("Failed to scan data: '${e.message}'.");
      return null;
    }
  }

  Future<void> releaseDevice() async {
    try {
      await _channel.invokeMethod('releaseDevice');
    } on PlatformException catch (e) {
      debugPrint("Failed to release device: '${e.message}'.");
    }
  }
}

class TagMyIdHomeScreen extends StatefulWidget {
  const TagMyIdHomeScreen({Key? key}) : super(key: key);

  @override
  State<TagMyIdHomeScreen> createState() => _TagMyIdHomeScreenState();
}

class _TagMyIdHomeScreenState extends State<TagMyIdHomeScreen> {
  final TagMyIdDeviceService _deviceService = TagMyIdDeviceService();
  
  bool _isInitialized = false;
  String _scanResult = "Ready to scan hardware data.";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initDevice();
  }

  Future<void> _initDevice() async {
    setState(() => _isLoading = true);
    bool success = await _deviceService.initializeDevice();
    setState(() {
      _isInitialized = success;
      _isLoading = false;
    });
  }

  Future<String?> _performScan() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device is not initialized!')),
      );
      return null;
    }

    setState(() {
      _isLoading = true;
      _scanResult = "Scanning RFID / Barcode...";
    });

    String? result = await _deviceService.scanDeviceData();

    setState(() {
      _scanResult = result ?? "Scan failed or returned empty.";
      _isLoading = false;
    });
    return result;
  }

  @override
  void dispose() {
    _deviceService.releaseDevice();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TagMyId Pro Hardware Console'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Hardware Status:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(
                      children: [
                        Icon(
                          _isInitialized ? Icons.check_circle : Icons.error,
                          color: _isInitialized ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isInitialized ? "Connected" : "Disconnected",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isInitialized ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scanned Payload Output:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14),
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : SelectableText(
                                _scanResult,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _performScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.qr_code_scanner, size: 24),
              label: const Text('Start Hardware Scan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
