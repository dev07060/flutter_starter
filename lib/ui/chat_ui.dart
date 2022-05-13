import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/ui/settings_ui.dart';
import 'package:flutter_starter/ui/summary_ui.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'components/components.dart';
import '../controllers/controllers.dart';
import '../constants/constants.dart';
import 'ui.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';

// ChatMessageModel _chatMessagesModel = ChatMessageModel(id: 0, message: '', bot: '', dist: '');
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  Timer? _timer;

  var _time = 0;
  var _isRunning = false;

  void _start() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _time++;
      });
    });
  }

  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 100.0;

  double level = 0.0;
  bool _hasSpeech = false;
  bool _logEvents = false;

  final TextEditingController _pauseForController =
      TextEditingController(text: '3');
  final TextEditingController _listenForController =
      TextEditingController(text: '30');

  String _currentLocaleId = '';
  List<LocaleName> _localeNames = [];

  String text = '음성이나 텍스트를 입력해주세요';
  String message = '안녕하세요? \n대화형 문진에 오신걸 환영합니다.';
  bool draggable = true;
  bool isText = false;
  bool isCommand = false;
  bool isLoading = false;
  bool welcomeMessage = false;
  bool isListening = false;

  int flow = 0;
  int yn = 0;
  int _currentIndex = 0;

  AnimationController? animationController;

  final _messageTextController = TextEditingController();

  void clearText() {
    _messageTextController.clear();
  }

  void startListening() {
    _logEvent('start listening');
    lastWords = '';
    lastError = '';
    final pauseFor = int.tryParse(_pauseForController.text);
    final listenFor = int.tryParse(_listenForController.text);
    // Note that `listenFor` is the maximum, not the minimun, on some
    // systems recognition will be stopped before this value is reached.
    // Similarly `pauseFor` is a maximum not a minimum and may be ignored
    // on some devices.
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: listenFor ?? 30),
        pauseFor: Duration(seconds: pauseFor ?? 3),
        partialResults: true,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setState(() {});
  }

  void resultListener(SpeechRecognitionResult result) async {
    _logEvent(
        'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');

    setState(() {
      lastWords = '${result.recognizedWords} - ${result.finalResult}';
    });
    if (result.finalResult) {
      bubbleGenerate(result.recognizedWords, 1, '');

      await dioConnection(bdi_call, email!, result.recognizedWords).then(
          (value) => setState(
              () => chat_list = [message = value?[0], distType = value?[1]]));
    }
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    setState(() {
      this.level = level;
    });
  }

  void stopListening() {
    _logEvent('stop');
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    _logEvent('cancel');
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      print('$eventTime $eventDescription');
    }
  }

  void errorListener(SpeechRecognitionError error) {
    _logEvent(
        'Received error status: $error, listening: ${speech.isListening}');
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    _logEvent(
        'Received listener status: $status, listening: ${speech.isListening}');
    setState(() {
      lastStatus = '$status';
    });
  }

  @override
  void initState() {
    animationController = AnimationController(vsync: this);
    _fabHeight = _initFabHeight;
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    _timer?.cancel();

    super.dispose();
  }

  Future<void> initSpeechState() async {
    _logEvent('Initialize');
    try {
      var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: true,
      );

      if (hasSpeech) {
        // Get the list of languages installed on the supporting platform so they
        // can be displayed in the UI for selection by the user.
        _localeNames = await speech.locales();

        var systemLocale = await speech.systemLocale();
        _currentLocaleId = systemLocale?.localeId ?? '';
      }
      if (!mounted) return;

      setState(() {
        _hasSpeech = hasSpeech;
      });
    } catch (e) {
      setState(() {
        lastError = 'Speech recognition failed: ${e.toString()}';
        _hasSpeech = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: welcomeMessage
          ? !isText
              ? FloatingActionButton(
                  backgroundColor: Colors.grey[300],
                  mini: true,
                  child: Icon(Icons.keyboard),
                  onPressed: () => {
                        setState(() => {isText = true})
                      })
              : FloatingActionButton(
                  backgroundColor: Colors.grey[300],
                  mini: true,
                  child: Icon(Icons.mic_none),
                  onPressed: () => {
                        setState(() => {isText = false})
                      })
          : FloatingActionButton(
              backgroundColor: Colors.blueGrey,
              mini: true,
              child: Icon(Icons.arrow_right, color: Colors.white),
              onPressed: () async {
                await welcome(email!);
                setState(() => {welcomeMessage = true});
              }),
      backgroundColor: Colors.blueGrey[200],
      body: SafeArea(
          child: Column(children: <Widget>[
        MessagesStream(),
        buildSlidingPanel(context),
      ])),
    );
  }

  Widget buildSlidingPanel(BuildContext context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;
    return Material(
      child: Stack(alignment: Alignment.topCenter, children: <Widget>[
        SlidingUpPanel(
          maxHeight: _panelHeightOpen,
          minHeight: !welcomeMessage
              ? _panelHeightClosed
              : _hasSpeech
                  ? 160
                  : 150,
          parallaxEnabled: true,
          parallaxOffset: .5,
          isDraggable: draggable,
          panelBuilder: (sc) => _panel(sc),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
          onPanelSlide: (double pos) => setState(() {
            _fabHeight =
                pos * (_panelHeightOpen - _panelHeightClosed) + _initFabHeight;
          }),
          collapsed: welcomeMessage
              ? Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200], borderRadius: radius),
                  child: Column(children: [
                    SizedBox(height: 10),
                    AnimatedCrossFade(
                      crossFadeState: isText
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 500),
                      reverseDuration: const Duration(milliseconds: 500),
                      firstCurve: Curves.easeIn,
                      secondCurve: Curves.bounceOut,
                      firstChild: Container(
                        width: 330,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(20)),
                        child: TextField(
                          enableSuggestions: true,
                          autocorrect: true,
                          enabled: isText ? true : false,
                          controller: _messageTextController,
                          autofocus: true,
                          cursorColor: Colors.cyan,
                          cursorHeight: 20,
                          decoration: InputDecoration(
                            disabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.white30,
                            filled: true,
                          ),
                          onSubmitted: (value) {
                            setState(() => this.text = value.trim());
                            setState(() => this.isText = true);
                            setState(() => this.draggable = true);
                            _messageTextController.clear();
                            bubbleGenerate(value, 1, '-');
                            toggleKeyboard();
                          },
                        ),
                      ),
                      secondChild: SpeechControlWidget(
                          _hasSpeech,
                          speech.isListening,
                          startListening,
                          stopListening,
                          cancelListening),
                    ),
                    SizedBox(height: 10),
                    _hasSpeech
                        ? SizedBox(height: 10)
                        : Container(
                            child:
                                InitSpeechWidget(_hasSpeech, initSpeechState)),
                    Padding(
                      padding: EdgeInsets.all(0),
                      child: SizedBox(
                          child: RecognitionResultsWidget(
                              lastWords: lastWords,
                              level: level,
                              isText: isText),
                          height: 70),
                    ),
                  ]),
                )
              : Container(
                  decoration: BoxDecoration(
                      color: Colors.blueGrey, borderRadius: radius),
                  child: Center(
                      child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 32.0,
                          fontFamily: 'Horizon',
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            RotateAnimatedText('안녕하세요'),
                            RotateAnimatedText('클릭하시면'),
                            RotateAnimatedText('대화가 시작됩니다'),
                          ],
                          onTap: () async {
                            await welcome(email!);
                            setState(() => {welcomeMessage = true});
                            // setState(() => {_hasSpeech = true});
                          },
                          stopPauseOnTap: true,
                          repeatForever: true,
                        ),
                      ),
                    ],
                  )),
                ),
        ),
      ]),
    );
  }

  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: <Widget>[
            SizedBox(
              height: 12.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.blueGrey[200],
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
              ],
            ),
            SizedBox(
              height: 18.0,
            ),
            welcomeMessage
                ? Column(children: <Widget>[
                    SizedBox(
                      height: 30.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(width: 0.0, color: Colors.white),
                            ),
                            onPressed: () {
                              Get.to(ResultSummary());
                            },
                            child: Padding(
                              padding: EdgeInsets.only(top: 17),
                              child: _button("마음건강", Icons.favorite, Colors.red,
                                  Colors.red),
                            )),
                        OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(width: 0.0, color: Colors.white),
                            ),
                            onPressed: () {
                              Get.to(YoutubePlayerList());
                            },
                            child: Padding(
                              padding: EdgeInsets.only(top: 17),
                              child: _button("맞춤영상", Icons.music_video_rounded,
                                  Colors.blue[400]!, Colors.blue[400]!),
                            )),
                        OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(width: 0.0, color: Colors.white),
                            ),
                            onPressed: () {
                              Get.to(HomePage());
                            },
                            child: Padding(
                              padding: EdgeInsets.only(top: 17),
                              child: _button("감정상태", Icons.emoji_emotions,
                                  Colors.grey, Colors.grey),
                            )),
                        OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(width: 0.0, color: Colors.white),
                            ),
                            onPressed: () {
                              Get.to(SettingsUI());
                            },
                            child: Padding(
                              padding: EdgeInsets.only(top: 17),
                              child: _button("설정", Icons.settings, Colors.white,
                                  Colors.grey),
                            )),
                      ],
                    ),
                  ])
                : Text(""),

            // SizedBox(
            //   height: 36.0,
            // ),
            // Container(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: <Widget>[],
            //   ),
            // ),
          ],
        ));
  }

  Widget _button(String label, IconData icon, Color color, Color shadowColor) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Icon(
            icon,
            color: label == '설정' ? Colors.grey[600] : Colors.white,
          ),
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 20.0,
            )
          ]),
        ),
        SizedBox(
          height: 12.0,
        ),
        Text(
          label,
          style: GoogleFonts.gowunDodum(
            textStyle: (TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[900],
            )),
          ),
        ),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  // function for user typing keyboard to send message
  // (It also includes : dio connection(http connection), create chat bubbles)
  Future toggleKeyboard() async {
    if (text != ''.trim()) {
      await dioConnection(bdi_call, email!, text).then((value) => setState(
          () => chat_list = [message = value?[0], distType = value?[1]]));
      maxScrolling();
      return text;
    }
  }
}

Future<List?> welcome(String _email) async {
  print("uid: ${currentUser?.uid}");

  var formData = FormData.fromMap({
    'input_text': "안녕",
    'present_bdi': '',
  });

  var options = BaseOptions(
    baseUrl: '$url',
    connectTimeout: 7000,
    receiveTimeout: 5000,
  );

  Dio dio = new Dio(options);
  print("state_list : $distType");
  try {
    Response response =
        await dio.post('bdiscale?email=$_email&state=start', data: formData);

    String? chat = response.data["출력"];
    String bdi = response.data["생성된 질문"]["질문"];
    String dist = response.data["생성된 질문"]["BDI"];
    String next = response.data["분석결과"]["다음 동작"];
    String qDist = response.data["사용자 입력 BDI 분류"]["분류 결과"];
    state_list!.add(next);
    print(state_list);

    if (chat!.contains('\n')) chat_list = chat.split('\n');

    int yn = response.data["입력문장긍부정도"]["긍부정구분"]["분류 결과"];
    if (response.statusCode == 200) {
      if (chat.contains('\n')) {
        for (var i = 0; i < chat_list.length; i++) {
          // Timer(const Duration(seconds: 1), () => {});
          await Future.delayed(const Duration(milliseconds: 2500), () {
            print(i);
          });

          bubbleGenerate(chat_list[i]!, 2 + i, dist);
        }
      } else {
        bubbleGenerate(chat, 2, dist);
        return [chat, next, yn];
      }
    }
    return [chat, next, yn];
  } catch (e) {
    return null;
  }
}

Future<List?> dioConnection(String _end, String _email, String _userMsg) async {
  var formData = FormData.fromMap({
    'input_text': _userMsg,
    'present_bdi': '',
  });

  var options = BaseOptions(
    baseUrl: '$url',
    connectTimeout: 7000,
    receiveTimeout: 5000,
  );

  Dio dio = new Dio(options);
  print("state_list : $distType");
  straightCommand(_userMsg, true);
  try {
    Response response =
        await dio.post('$_end$_email&$state$distType', data: formData);

    String chat = response.data["출력"];
    String dist = response.data["생성된 질문"]["BDI"];
    String next = response.data["분석결과"]["다음 동작"];
    int yn = response.data["입력문장긍부정도"]["긍부정구분"]["분류 결과"];

    // String bdi = response.data["생성된 질문"]["질문"];
    // String qDist = response.data["사용자 입력 BDI 분류"]["분류 결과"];

    state_list!.add(next);
    print(state_list);

    if (chat.contains('\n')) chat_list = chat.split('\n');

    if (response.statusCode == 200) {
      if (chat.contains('\n')) {
        for (var i = 0; i < chat_list.length; i++) {
          await Future.delayed(const Duration(milliseconds: 2500), () {
            print(i);
          });
          // Timer(const Duration(seconds: 1), () => {});
          bubbleGenerate(chat_list[i]!, 2 + i, dist);
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 2500), () {
          print("");
        });
        bubbleGenerate(chat, 2, dist);
        return [chat, next, yn];
      }
    }
    return [chat, next, yn];
  } catch (e) {
    return null;
  }
}
