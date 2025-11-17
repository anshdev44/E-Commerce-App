import 'dart:io';
import 'package:flutter/foundation.dart';

/// Centralized backend URL configuration
/// 
/// IMPORTANT: For physical devices, replace the IP address below with your computer's actual IP address.
/// 
/// HOW TO FIND YOUR COMPUTER'S IP ADDRESS:
/// 
/// Windows:
///   1. Open Command Prompt (CMD)
///   2. Type: ipconfig
///   3. Look for "IPv4 Address" under your active network adapter (usually Wi-Fi or Ethernet)
///   4. It will look like: 192.168.x.x or 10.0.x.x
/// 
/// Mac/Linux:
///   1. Open Terminal
///   2. Type: ifconfig
///   3. Look for "inet" under your active network interface (usually en0 or eth0)
///   4. It will look like: 192.168.x.x or 10.0.x.x
/// 
/// IMPORTANT NOTES:
/// - Make sure your phone and computer are on the SAME Wi-Fi network
/// - The backend server must be running on your computer
/// - For Android Emulator: Use '10.0.2.2' instead of your IP
/// - For iOS Simulator: Use 'localhost' instead of your IP
/// 
/// Examples:
///   - If your IP is 192.168.1.100, change computerIpAddress to: '192.168.1.100'
///   - If your IP is 192.168.0.50, change computerIpAddress to: '192.168.0.50'
class BackendConfig {
  // ⚠️ CHANGE THIS to your computer's actual IP address
  // Find it by running: ipconfig (Windows) or ifconfig (Mac/Linux)
  // Make sure your phone and computer are on the same Wi-Fi network!
  static const String computerIpAddress = '192.168.1.16';
  static const int port = 8000;

  /// Get the backend URL based on the current platform
  static String getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:$port';
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Always use IP address for mobile devices (both physical and emulator)
      // For Android emulator, if this doesn't work, change to '10.0.2.2'
      return 'http://$computerIpAddress:$port';
    } else {
      return 'http://$computerIpAddress:$port';
    }
  }
}

