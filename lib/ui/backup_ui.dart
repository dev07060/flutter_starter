import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:sliding_panel/sliding_panel.dart';
import 'package:flutter_starter/ui/summary_ui.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'components/components.dart';

// ChatMessageModel _chatMessagesModel = ChatMessageModel(id: 0, message: '', bot: '', dist: '');
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  String text = '음성이나 텍스트를 입력해주세요';
  String message = '안녕하세요? \n대화형 문진에 오신걸 환영합니다.';
  String distType = '';

  bool isListening = false;
  bool isText = false;
  bool isCommand = false;
  bool isLoading = false;
  int flow = 0;
  int yn = 0;

  PanelController? pc;
  AnimationController? animationController;

  @override
  void initState() {
    super.initState();
    pc = PanelController();
    animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    this.isListening = false;
    animationController?.dispose();
    // Do some action when screen is closed
  }

  String selected =
      "To go back, open the panel, select an option.\nYour favorite food will be shown here.";

  BackPressBehavior behavior = BackPressBehavior.PERSIST;

  List<Widget> get _content => [
        ListTile(
          onTap: () {
            pc?.popWithThrowResult(result: 'Pizza').then((_) {
              setState(() {
                selected = "You ordered Pizza.\n\nNow you can go back.";
                behavior = BackPressBehavior.POP;
              });
            });
          },
          title: Text(
            'Pizza',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          onTap: () {
            pc?.popWithResult(result: 'Sandwich');
          },
          title: Text(
            'Sandwich',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          onTap: () {
            pc?.sendResult(result: 'Pasta');
            // THIS WILL NOT CLOSE THE PANEL, JUST SEND THE RESULT
          },
          title: Text(
            'Pasta',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          onTap: () {
            pc?.popWithResult(result: 'Malai Kofta');
          },
          title: Text(
            'Malai Kofta',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          onTap: () {
            pc?.popWithResult(result: 'French Fries');
          },
          title: Text(
            'French Fries',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          onTap: () {
            pc?.popWithResult(result: 'Samosas');
          },
          title: Text(
            'Samosas',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          onTap: () {
            pc?.popWithResult(result: 'Toast');
          },
          title: Text(
            'Toast',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          onTap: () {
            pc?.popWithResult(result: 'Frankie');
          },
          title: Text(
            'Frankie',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          onTap: () {
            pc?.popWithResult(result: 'Burger');
          },
          title: Text(
            'Burger',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          onTap: () {
            pc?.popWithResult(result: 'Salad');
          },
          title: Text(
            'Salad',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          onTap: () {
            pc?.popWithResult(result: 'Chips');
          },
          title: Text(
            'Chips',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          onTap: () {
            pc?.popWithResult(result: 'Cookies');
          },
          title: Text(
            'Cookies',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
      ];
  final _messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterTop,
      floatingActionButton: AvatarGlow(
        animate: isListening,
        endRadius: 75,
        glowColor: Theme.of(context).primaryColor.withOpacity(0.5),
        child: FloatingActionButton(
          child: Icon(isListening ? Icons.mic : Icons.mic_none, size: 36),
          onPressed: () {
            setState(() => isText = false);
            setState(() => text = '');
            _messageTextController.clear();
            toggleRecording();
          },
          backgroundColor: darkblueColor,
        ),
      ),
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '대화형 문진',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
        backgroundColor: primaryColor,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.analytics),
              onPressed: () {
                Get.to(() => ResultSummary());
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: NotificationListener<SlidingPanelResult>(
          onNotification: (food) {
            setState(() {
              print('You sent ${food.result}');
              selected = "You ordered ${food.result}.\n\nNow you can go back.";
              behavior = BackPressBehavior.POP;
            });
            return false;
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessagesStream(),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: primaryColor,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          children: <Widget>[
                            const ListTile(
                              leading: CircleAvatar(
                                radius: 33,
                                backgroundImage:
                                    AssetImage("assets/images/model.png"),
                                backgroundColor: Colors.white24,
                              ),
                              title: Text('MetaDoc',
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black)),
                              subtitle: Text('듣고 있습니다',
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.black54)),
                            ),
                            isListening
                                ? LinearProgressIndicator(
                                    backgroundColor: Colors.pink[100],
                                  )
                                : LinearProgressIndicator(
                                    value: 0,
                                  ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 10, bottom: 15, left: 10, right: 10),
                              child: Text(message,
                                  style: TextStyle(
                                      fontSize: 22, color: Colors.black),
                                  maxLines: 3),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 14, right: 14),
                              child: Center(
                                child: SubstringHighlight(
                                  text: text,
                                  terms: Command.all,
                                  textStyle: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textStyleHighlight: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            isText
                                ? Container(
                                    width: 330,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: TextField(
                                      autofocus: true,
                                      decoration: InputDecoration(
                                          fillColor: Colors.white30,
                                          filled: true,
                                          border: InputBorder.none),
                                      onSubmitted: (value) {
                                        setState(
                                            () => this.text = value.trim());
                                        setState(() => this.isText = false);
                                        // text = "";
                                        _messageTextController.clear();
                                        bubbleGenerate(value.trim(), 1, '-');
                                        maxScrolling();
                                        // straightCommand(value, isText);
                                        toggleKeyboard();
                                      },
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.keyboard),
                                    tooltip: '키보드 입력 버튼',
                                    onPressed: () {
                                      setState(() => this.isText = true);
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names

  // function for user typing keyboard to send message
  // (It also includes : dio connection(http connection), create chat bubbles)
  Future toggleKeyboard() async {
    additionalCommand(distType, flow);
    straightCommand(text, isCommand);
    // if submittied with empty textField, block connection
    if (text != ''.trim()) {
      await dioConnection(bdi_call, email!, text).then((value) => setState(
          () => [message = value![0], distType = value![1], flow = value[2]]));
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

          if (text == '') {
            setState(() async => {message = "지금 듣고 있습니다.", isListening = true});
          } else if (!isListening) {
            Future.delayed(Duration(seconds: 2), () async {
              bubbleGenerate(text, 1, '');
              maxScrolling();

              await dioConnection(bdi_call, email!, text)
                  .then((value) => setState(() => message = value![0]));
              maxScrolling();
            });
          } else {
            message = "";
          }
        },
      );
}

Future<List?> dioConnection(String _end, String _email, String _userMsg) async {
  var formData = FormData.fromMap({
    'input_text': _userMsg,
    'present_bdi': '',
  });

  Dio dio = new Dio();
  Response response = await dio.post("$url$_end$_email", data: formData);
  String chat = response.data["분석결과"]["시스템응답"];
  String bdi = response.data["생성된 질문"]["질문"];
  String dist = response.data["생성된 질문"]["BDI"];
  String q_dist = response.data["사용자 입력 BDI 분류"]["분류 결과"];
  int yn = response.data["입력문장긍부정도"]["긍부정구분"]["분류 결과"];
  if (_userMsg != ''.trim()) {
    if (q_dist == "일반") {
      bubbleGenerate(chat, 2, dist);
      return [chat, dist, yn];
    } else {
      bubbleGenerate(bdi, 2, dist);
      return [bdi, dist, yn];
    }
  }
  return null;
}
