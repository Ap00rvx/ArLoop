import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthTestWidget extends StatefulWidget {
  const AuthTestWidget({super.key});

  @override
  State<AuthTestWidget> createState() => _AuthTestWidgetState();
}

class _AuthTestWidgetState extends State<AuthTestWidget> {
  String _status = 'Checking tokens...';
  String _userToken = 'Not found';
  String _storeOwnerToken = 'Not found';
  String _detectedRole = 'Unknown';

  @override
  void initState() {
    super.initState();
    _checkTokens();
  }

  Future<void> _checkTokens() async {
    try {
      const storage = FlutterSecureStorage();

      // Check user token
      final userToken = await storage.read(key: "auth_token");
      setState(() {
        _userToken = userToken ?? 'Not found';
      });

      // Check store owner token
      final storeOwnerToken = await storage.read(key: "store_owner_token");
      setState(() {
        _storeOwnerToken = storeOwnerToken ?? 'Not found';
      });

      // Determine role
      String role = await _getRole();
      setState(() {
        _detectedRole = role;
        _status = 'Tokens checked successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<String> _getRole() async {
    try {
      const storage = FlutterSecureStorage();

      // Check for user token first
      final userToken = await storage.read(key: "auth_token");
      if (userToken != null &&
          userToken.isNotEmpty &&
          !JwtDecoder.isExpired(userToken)) {
        final decodedToken = JwtDecoder.decode(userToken);
        final role = decodedToken['role'] as String?;
        if (role != null && role.isNotEmpty) {
          return role;
        }
      }

      // Check for store owner token
      final storeOwnerToken = await storage.read(key: "store_owner_token");
      if (storeOwnerToken != null &&
          storeOwnerToken.isNotEmpty &&
          !JwtDecoder.isExpired(storeOwnerToken)) {
        final decodedToken = JwtDecoder.decode(storeOwnerToken);
        final role = decodedToken['role'] as String?;
        if (role != null && role.isNotEmpty) {
          return role;
        }
        // If no role specified in store owner token, assume storeOwner
        return "storeOwner";
      }

      return "null";
    } catch (e) {
      return "error: $e";
    }
  }

  Future<void> _clearAllTokens() async {
    try {
      const storage = FlutterSecureStorage();
      await storage.delete(key: "auth_token");
      await storage.delete(key: "store_owner_token");

      setState(() {
        _status = 'All tokens cleared';
        _userToken = 'Cleared';
        _storeOwnerToken = 'Cleared';
        _detectedRole = 'null';
      });
    } catch (e) {
      setState(() {
        _status = 'Error clearing tokens: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $_status',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Detected Role: $_detectedRole',
                      style: TextStyle(
                        fontSize: 14,
                        color: _detectedRole == 'storeOwner'
                            ? Colors.green
                            : _detectedRole == 'user'
                            ? Colors.blue
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'User Token:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _userToken.length > 50
                          ? '${_userToken.substring(0, 50)}...'
                          : _userToken,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Store Owner Token:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _storeOwnerToken.length > 50
                          ? '${_storeOwnerToken.substring(0, 50)}...'
                          : _storeOwnerToken,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _checkTokens,
                  child: const Text('Refresh'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _clearAllTokens,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Clear All Tokens'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
