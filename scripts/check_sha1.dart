import 'dart:io';

void main() async {
  print('=== SHA-1 Fingerprint Checker ===\n');

  // Check if keytool is available
  try {
    final result = await Process.run('keytool', ['-help']);
    if (result.exitCode != 0) {
      print('❌ keytool not found. Please install Java JDK.');
      return;
    }
  } catch (e) {
    print('❌ keytool not found. Please install Java JDK and add it to PATH.');
    return;
  }

  print('📱 Getting SHA-1 fingerprints...\n');

  // Debug keystore (for development)
  await getSHA1('Debug Keystore', [
    '-list',
    '-v',
    '-keystore',
    Platform.isWindows
        ? '${Platform.environment['USERPROFILE']}\\.android\\debug.keystore'
        : '${Platform.environment['HOME']}/.android/debug.keystore',
    '-alias',
    'androiddebugkey',
    '-storepass',
    'android',
    '-keypass',
    'android',
  ]);

  // Release keystore (if exists)
  final releaseKeystore = Platform.isWindows
      ? '${Directory.current.path}\\android\\app\\release.keystore'
      : '${Directory.current.path}/android/app/release.keystore';

  if (File(releaseKeystore).existsSync()) {
    print('\n' + '=' * 50);
    print('Found release keystore, getting SHA-1...');
    await getSHA1('Release Keystore', [
      '-list',
      '-v',
      '-keystore',
      releaseKeystore,
      '-alias',
      'release', // or your alias name
      '-storepass',
      'your_store_password', // Replace with actual password
    ]);
  }

  print('\n' + '=' * 50);
  print('📋 Next Steps:');
  print('1. Copy the SHA-1 fingerprint(s) above');
  print('2. Go to https://console.developers.google.com/');
  print('3. Select your project');
  print('4. Go to "Credentials" → "OAuth 2.0 Client IDs"');
  print('5. Edit your Android client ID');
  print('6. Add the SHA-1 fingerprint');
  print('7. Make sure package name matches: com.example.arloop');
  print('8. Save and wait a few minutes for changes to propagate');
}

Future<void> getSHA1(String keystoreType, List<String> args) async {
  try {
    final result = await Process.run('keytool', args);

    if (result.exitCode == 0) {
      final output = result.stdout.toString();
      final sha1Regex = RegExp(r'SHA1:\s*([A-F0-9:]{59})');
      final match = sha1Regex.firstMatch(output);

      if (match != null) {
        print('✅ $keystoreType SHA-1: ${match.group(1)}');
      } else {
        print('❌ Could not extract SHA-1 from $keystoreType');
      }
    } else {
      print('❌ Failed to get $keystoreType SHA-1:');
      print(result.stderr);
    }
  } catch (e) {
    print('❌ Error getting $keystoreType SHA-1: $e');
  }
}
