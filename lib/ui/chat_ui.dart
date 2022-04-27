import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/ui/settings_ui.dart';
import 'package:flutter_starter/ui/summary_ui.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:grouped_list/grouped_list.dart';
import 'components/components.dart';
import '../controllers/controllers.dart';
import '../constants/constants.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

// ChatMessageModel _chatMessagesModel = ChatMessageModel(id: 0, message: '', bot: '', dist: '');
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 220.0;

  String text = '음성이나 텍스트를 입력해주세요';
  String message = '안녕하세요? \n대화형 문진에 오신걸 환영합니다.';

  bool draggable = true;
  bool isListening = false;
  bool isText = false;
  bool isCommand = false;
  bool isLoading = false;
  bool welcomeMessage = false;

  int flow = 0;
  int yn = 0;
  int _currentIndex = 0;

  AnimationController? animationController;
  final _messageTextController = TextEditingController();

  void clearText() {
    _messageTextController.clear();
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
    clearText;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: Text(
          '대화형 문진',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.menu), onPressed: null),
        backgroundColor: primaryColor,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Get.to(() => SettingsUI());
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
          child: Column(children: <Widget>[
        MessagesStream(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.keyboard),
              tooltip: '키보드 입력 버튼',
              onPressed: () {
                setState(() => this.isText = true);
                setState(() => this.draggable = false);
              },
            ),
            AvatarGlow(
                animate: isListening,
                endRadius: 33,
                glowColor: Theme.of(context).primaryColor.withOpacity(0.5),
                child: IconButton(
                  icon: !isListening ? Icon(Icons.mic_none) : Icon(Icons.mic),
                  onPressed: () {
                    // maxScrolling();
                    setState(() => isText = false);
                    setState(() => text = '');
                    _messageTextController.clear();
                    toggleRecording();
                  },
                )),
          ],
        ),
        buildSlidingPanel(context),
      ])),
    );
  }

  Widget buildSlidingPanel(BuildContext context) {
    final _messageTextController = TextEditingController();

    _panelHeightOpen = MediaQuery.of(context).size.height * .80;
    return Material(
      child: Stack(alignment: Alignment.topCenter, children: <Widget>[
        SlidingUpPanel(
          maxHeight: _panelHeightOpen,
          minHeight: _panelHeightClosed,
          parallaxEnabled: true,
          parallaxOffset: .5,
          isDraggable: draggable,
          panelBuilder: (sc) => _panel(sc),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
          onPanelSlide: (double pos) => setState(() {
            _fabHeight =
                pos * (_panelHeightOpen - _panelHeightClosed) + _initFabHeight;
          }),
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
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
              ],
            ),
            SizedBox(
              height: 18.0,
            ),
            welcomeMessage
                ? Container(
                    width: 330,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20)),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                          fillColor: Colors.white30,
                          filled: true,
                          border: InputBorder.none),
                      onSubmitted: (value) {
                        setState(() => this.text = value.trim());
                        setState(() => this.isText = true);
                        setState(() => this.draggable = true);
                        bubbleGenerate(value, 1, '-');
                        toggleKeyboard();
                      },
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                          onPressed: () async {
                            await welcome(email!);
                            setState(() => {welcomeMessage = true});
                          },
                          child: (Text("대화 시작하기",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14.0,
                              )))),
                    ],
                  ),
            SizedBox(
              height: 36.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                OutlinedButton(
                    onPressed: () {
                      Get.to(ResultSummary());
                    },
                    child: _button(
                        "마음건강", Icons.favorite, Colors.red, Colors.red)),
                OutlinedButton(
                    onPressed: () {},
                    child: _button("힐링영상", Icons.music_video_rounded,
                        Colors.grey, Colors.grey)),
                OutlinedButton(
                    onPressed: () {},
                    child: _button("감정상태", Icons.emoji_emotions, Colors.grey,
                        Colors.grey)),
                OutlinedButton(
                    onPressed: () {
                      _messageTextController.clear();
                    },
                    child: _button(
                        "More", Icons.more_horiz, Colors.grey, Colors.grey)),
              ],
            ),
            SizedBox(
              height: 36.0,
            ),
            Container(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Images",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(
                    height: 12.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 36.0,
            ),
            Container(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("About",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(
                    height: 12.0,
                  ),
                  Text(
                    "",
                    softWrap: true,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 24,
            ),
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
            color: Colors.white,
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
          style: TextStyle(color: Colors.black),
        ),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  // function for user typing keyboard to send message
  // (It also includes : dio connection(http connection), create chat bubbles)
  Future toggleKeyboard() async {
    additionalCommand(distType, flow);
    straightCommand(text, isCommand);
    if (text != ''.trim()) {
      await dioConnection(bdi_call, email!, text).then((value) => setState(
          () => chat_list = [message = value?[0], distType = value?[1]]));
      maxScrolling();
    } else {
      setState(() => {isText = false});
    }
  }

  // voice recognition function (it also includes : dio connection(http request), create chat bubbles)
  Future toggleRecording() => SpeechApi.toggleRecording(
        onResult: (text) => setState(() => this.text = text),
        onListening: (isListening) {
          setState(() => this.isListening = isListening);

          if (!isListening) {
            Future.delayed(Duration(seconds: 3), () async {
              await dioConnection(bdi_call, email!, text).then((value) =>
                  setState(() =>
                      chat_list = [message = value?[0], distType = value?[1]]));
              maxScrolling();
            });
          } else {
            message = "";
          }
        },
      );
}

Future<List?> welcome(String _email) async {
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

    String chat = response.data["출력"];
    String bdi = response.data["생성된 질문"]["질문"];
    String dist = response.data["생성된 질문"]["BDI"];
    String next = response.data["분석결과"]["다음 동작"];
    String qDist = response.data["사용자 입력 BDI 분류"]["분류 결과"];
    state_list!.add(next);
    print(state_list);

    if (chat.contains('\n')) chat_list = chat.split('\n');

    int yn = response.data["입력문장긍부정도"]["긍부정구분"]["분류 결과"];
    if (response.statusCode == 200) {
      if (chat.contains('\n'))
        for (var i = 0; i < chat_list.length; i++) {
          print(i);
          bubbleGenerate(chat_list[i]!, 2, dist);
        }
      else
        bubbleGenerate(chat, 2, dist);
      return [chat, next, yn];
    }
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
  try {
    Response response =
        await dio.post('$_end$_email&$state$distType', data: formData);

    String chat = response.data["출력"];
    String bdi = response.data["생성된 질문"]["질문"];
    String dist = response.data["생성된 질문"]["BDI"];
    String next = response.data["분석결과"]["다음 동작"];
    String qDist = response.data["사용자 입력 BDI 분류"]["분류 결과"];
    state_list!.add(next);
    print(state_list);

    if (chat.contains('\n')) chat_list = chat.split('\n');

    int yn = response.data["입력문장긍부정도"]["긍부정구분"]["분류 결과"];
    if (response.statusCode == 200) {
      if (chat.contains('\n'))
        for (var i = 0; i < chat_list.length; i++) {
          print(i);
          bubbleGenerate(chat_list[i]!, 2, dist);
        }
      else
        bubbleGenerate(chat, 2, dist);
      return [chat, next, yn];
    }
    return [chat, next, yn];
  } catch (e) {
    return null;
  }
}
