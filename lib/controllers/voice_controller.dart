import 'package:flutter/material.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';


class VoiceController extends GetxController {
  var isListening = false.obs;
  var speechText = 'speech.comment'.tr.obs;

  SpeechToText ?speechToText;
  @override
  void onInit() {
    super.onInit();
    speechToText = SpeechToText();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
  }

  @override
  void listen() async{
    if(!isListening.value)
      {
        bool available = await speechToText!.initialize(
          onStatus: (val) {},
          onError: (val) {},
        );
        if(available){
          isListening.value = true;
          speechToText?.listen(
            onResult: (val){
              speechText.value = val.recognizedWords;
            }
          );
        }else{
          isListening.value=false;
          speechToText?.stop();
          speechText.value='';
      }
    }
  }
}