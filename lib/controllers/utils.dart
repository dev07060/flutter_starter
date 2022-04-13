import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Command {
// TODO: create 'how to use' command
  static final all = [email, browser1, browser2];
  static const email = '이메일 써 줘';
  static const browser1 = '열어 줘';
  static const browser2 = '가자';
}

class Utils {
  static void scanText(String rawText) {
    final text = rawText.toLowerCase();

    if (text.contains(Command.email)) {
      final body = _getTextAfterCommand(text: text, command: Command.email);

      openEmail(body: "");
    } else if (text.contains(Command.browser1)) {
      final url = _getTextAfterCommand(text: text, command: Command.browser1);

      openLink(url: "");
    } else if (text.contains(Command.browser2)) {
      final url = _getTextAfterCommand(text: text, command: Command.browser2);

      openLink(url: "");
    }
  }

  static String _getTextAfterCommand({
    required String text,
    required String command,
  }) {
    final indexCommand = text.indexOf(command);
    final indexAfter = indexCommand + command.length;

    if (indexCommand == -1) {
      return "";
    } else {
      return text.substring(indexAfter).trim();
    }
  }

  static Future openLink({
    required String url,
  }) async {
    if (url.trim().isEmpty) {
      // await _launchUrl('https://google.com');
    } else {
      // await _launchUrl('https://$url');
    }
  }

  static Future openEmail({
    required String body,
  }) async {
    final url = 'mailto: ?body=${Uri.encodeFull(body)}';
    // await _launchUrl(url);
    print("이메일");
  }

  // static Future _launchUrl(String url) async {
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   }
  // }
}
