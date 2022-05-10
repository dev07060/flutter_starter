import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';

double minSoundLevel = 50000;
double maxSoundLevel = -50000;
String lastWords = '';
String lastError = '';
String lastStatus = '';

final SpeechToText speech = SpeechToText();

class SpeechControlWidget extends StatelessWidget {
  const SpeechControlWidget(this.hasSpeech, this.isListening,
      this.startListening, this.stopListening, this.cancelListening,
      {Key? key})
      : super(key: key);

  final bool hasSpeech;
  final bool isListening;
  final void Function() startListening;
  final void Function() stopListening;
  final void Function() cancelListening;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        TextButton(
          onPressed: !hasSpeech || isListening ? null : startListening,
          child: Text('말하기'),
        ),
        TextButton(
          onPressed: isListening ? stopListening : null,
          child: Text('정지'),
        ),
        TextButton(
          onPressed: isListening ? cancelListening : null,
          child: Text('취소'),
        )
      ],
    );
  }
}

/// Controls to start and stop speech recognition
class InitSpeechWidget extends StatelessWidget {
  const InitSpeechWidget(this.hasSpeech, this.initSpeechState, {Key? key})
      : super(key: key);

  final bool hasSpeech;
  final Future<void> Function() initSpeechState;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextButton(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 7 / 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(15.0),
                  topRight: Radius.circular(3.0),
                ),
                color: Colors.yellow[200],
              ),
              padding: EdgeInsets.symmetric(
                vertical: 7,
                horizontal: 16,
              ),
              child: Text(
                "메타니언과 대화 해볼래요!",
                style: GoogleFonts.gowunDodum(
                  textStyle: (TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[900],
                  )),
                ),
              ),
            ),
            onPressed: hasSpeech ? null : initSpeechState,
          ),
          // TextButton(
          //   onPressed: hasSpeech ? null : initSpeechState,
          //   child: Icon(Icons.mic),
          // ),
        ],
      ),
      SizedBox(height: 20)
    ]);
  }
}

/// Displays the most recently recognized words and the sound level.
class RecognitionResultsWidget extends StatelessWidget {
  const RecognitionResultsWidget({
    Key? key,
    required this.lastWords,
    required this.level,
    required this.isText,
  }) : super(key: key);

  final String lastWords;
  final double level;
  final bool isText;

  void _speechText() {}
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Center(
        //   child: Text(
        //     'Recognized Words',
        //     style: TextStyle(fontSize: 22.0),
        //   ),
        // ),
        Expanded(
          child: Stack(
            children: <Widget>[
              Container(
                color: Theme.of(context).selectedRowColor,
                child: Center(
                  child: Text(
                    '',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned.fill(
                bottom: 10,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: !isText
                        ? BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: .36,
                                  spreadRadius: level * 2.5,
                                  color: Colors.red.withOpacity(.33)),
                              BoxShadow(
                                  blurRadius: .36,
                                  spreadRadius: level * 1.6,
                                  color: Colors.red.withOpacity(.30)),
                              BoxShadow(
                                  blurRadius: .36,
                                  spreadRadius: level * 0.8,
                                  color: Colors.grey.withOpacity(.35))
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          )
                        : null,
                    child: IconButton(
                      icon: !isText
                          ? Icon(Icons.mic, color: Colors.red[400])
                          : Icon(Icons.keyboard),
                      onPressed: !isText ? () => null : () => {},
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SessionOptionsWidget extends StatelessWidget {
  const SessionOptionsWidget(
      this.currentLocaleId,
      this.switchLang,
      this.localeNames,
      this.logEvents,
      this.switchLogging,
      this.pauseForController,
      this.listenForController,
      {Key? key})
      : super(key: key);

  final String currentLocaleId;
  final void Function(String?) switchLang;
  final void Function(bool?) switchLogging;
  final TextEditingController pauseForController;
  final TextEditingController listenForController;
  final List<LocaleName> localeNames;
  final bool logEvents;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: [
              Text('Language: '),
              DropdownButton<String>(
                onChanged: (selectedVal) => switchLang(selectedVal),
                value: currentLocaleId,
                items: localeNames
                    .map(
                      (localeName) => DropdownMenuItem(
                        value: localeName.localeId,
                        child: Text(localeName.name),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          Row(
            children: [
              Text('pauseFor: '),
              Container(
                  padding: EdgeInsets.only(left: 8),
                  width: 80,
                  child: TextFormField(
                    controller: pauseForController,
                  )),
              Container(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('listenFor: ')),
              Container(
                  padding: EdgeInsets.only(left: 8),
                  width: 80,
                  child: TextFormField(
                    controller: listenForController,
                  )),
            ],
          ),
          Row(
            children: [
              Text('Log events: '),
              Checkbox(
                value: logEvents,
                onChanged: switchLogging,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
