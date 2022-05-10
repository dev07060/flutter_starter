import 'package:flutter_starter/controllers/preference.dart';
import 'package:flutter_starter/ui/components/messageStream.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:flutter_starter/ui/summary_ui.dart';

import '../ui/yt-list.dart';
import 'dialog.dart';

Future straightCommand(String _userInput, bool _isCommand) async {
  if (_userInput.contains("그만")) {
    return bubbleGenerate(
        (stopCommands..shuffle()).first, 2, 'straightCommand');
  } else if (_userInput.contains("안녕")) {
    return bubbleGenerate(
        (helloCommands..shuffle()).first, 2, 'straightCommand');
  } else if (_userInput.contains("결과창")) {
    return Get.to(ResultSummary());
  } else if (_userInput.contains("영상 추천")) {
    return Get.to(YoutubePlayerList());
  }
  return _isCommand = true;
}

Future additionalCommand(String? _botOutput, int _flow) async {
  String? random_word1 = (additionalMessage[16]?[12]?..shuffle())?.first;
  String? random_word2 = (additionalMessage[16]?[11]?..shuffle())?.first;
  if (random_word1!.contains("\n")) {}
  if (_botOutput == bdiDist[16]) {
    print(
        "in func $_botOutput == ${bdiDist[16]},,,${_botOutput == bdiDist[16]}");
    print("ss213$_flow");
    if (_flow == 1) {
      return bubbleGenerate(random_word1, 2, 'additionalCommand');
    } else if (_flow == 0) {
      return bubbleGenerate(random_word2!, 2, 'additionalCommand');
    }
  }
}
