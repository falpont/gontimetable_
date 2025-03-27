import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// IMPORTANT: Replace the placeholders with your actual FCM server key and your device's FCM token.
// WARNING: Embedding your server key in client-side code is insecure and is only for testing purposes.

const String serverKey = '104662925469255792711';
const String deviceToken = 'd83HKyQjlEt_qbxK3lWcla:APA91bGRbldWtXS9JjvIEnQ_bRD6qkjyJHTPZYfdsafWaH3BEPqdsJCSjRkKM9mNVwd4zioLj3Quk3KTwdEEf-AzMEwiD5iDCNVnCM8gehZrU1Sc9mC1nlY';

class SettingsWindow extends StatelessWidget {
  const SettingsWindow({Key? key}) : super(key: key);

  Future<void> sendTestFCM() async {
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };
    final body = json.encode({
      'to': deviceToken,
      'notification': {
        'title': 'Test Notification',
        'body': 'This is a test alarm via FCM',
      },
      'data': {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'status': 'done',
      },
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Test FCM sent successfully: ${response.body}');
      } else {
        print('Failed to send FCM: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await sendTestFCM();
          },
          child: const Text('Send Test FCM'),
        ),
      ),
    );
  }
}

// If you want to run this screen as your main app for testing, you can use the following main function:
// void main() {
//   runApp(MaterialApp(home: SettingsWindow()));
// }