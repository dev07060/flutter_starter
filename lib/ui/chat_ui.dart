import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:sliding_panel/sliding_panel.dart';
import 'package:flutter_starter/ui/summary_ui.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'components/components.dart';
import '../controllers/preference.dart';

// ChatMessageModel _chatMessagesModel = ChatMessageModel(id: 0, message: '', bot: '', dist: '');
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  String text = '음성이나 텍스트를 입력해주세요';
  String message = '안녕하세요? \n대화형 문진에 오신걸 환영합니다.';
  bool draggable = true;
  bool isListening = false;
  bool isText = false;
  bool isCommand = false;
  bool isLoading = false;
  int flow = 0;
  int yn = 0;

  PanelController pc;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    pc = PanelController();
    animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
    // Do some action when screen is closed
  }

  String selected =
      "To go back, open the panel, select an option.\nYour favorite food will be shown here.";

  BackPressBehavior behavior = BackPressBehavior.PERSIST;

  List<Widget> get _content => [
        Container(
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: <Widget>[
                const ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage("assets/images/model.png"),
                    backgroundColor: Colors.white24,
                  ),
                  title: Align(
                    alignment: Alignment.center,
                    child: Text('Metanion',
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 20, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        ListTile(
          onTap: () {
            pc.popWithResult(result: 'Sandwich');
          },
          title: Text(
            'Sandwich',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          onTap: () {
            pc.sendResult(result: 'Pasta');
            pc.close();
            // THIS WILL NOT CLOSE THE PANEL, JUST SEND THE RESULT
          },
          title: Text(
            'Pasta',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          onTap: () {
            pc.popWithResult(result: 'Malai Kofta');
          },
          title: Text(
            'Malai Kofta',
            style: Theme.of(context).textTheme.headline6,
          ),
        )
      ];
  final _messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          // onNotification: (food) {
          //   setState(() {
          //     print('You sent ${food.result}');
          //     selected = "You ordered ${food.result}.\n\nNow you can go back.";
          //     behavior = BackPressBehavior.POP;
          //   });
          //   return false;
          // },
          child: SlidingPanel(
            panelController: pc,
            isDraggable: draggable,
            initialState: InitialPanelState.dismissed,
            backdropConfig:
                BackdropConfig(enabled: true, shadowColor: Colors.blue),
            decoration: PanelDecoration(
              margin: EdgeInsets.all(8),
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            content: PanelContent(
              panelContent: _content,
              headerWidget: PanelHeaderWidget(
                headerContent: isText
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
                            setState(() => this.isText = false);
                            setState(() => this.draggable = true);
                            pc.close();
                            _messageTextController.clear();
                            bubbleGenerate(value, 1, '-');
                            toggleKeyboard();
                          },
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.keyboard),
                        tooltip: '키보드 입력 버튼',
                        onPressed: () {
                          setState(() => this.isText = true);
                          setState(() => this.draggable = false);

                          pc.close().then((e) => new Timer(
                              const Duration(milliseconds: 500),
                              () => maxScrolling()));
                        },
                      ),
                decoration: PanelDecoration(
                  margin: EdgeInsets.all(16),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                options: PanelHeaderOptions(
                  centerTitle: true,
                  elevation: 16,
                  leading: !isText
                      ? IconButton(
                          onPressed: () {
                            if (pc.currentState == PanelState.expanded)
                              pc
                                  .close()
                                  .then((currentState) => {maxScrolling()});
                            else
                              pc.expand();
                          },
                          icon: AnimatedIcon(
                            icon: AnimatedIcons.menu_close,
                            progress: animationController.view,
                          ),
                        )
                      : null,
                ),
              ),
              bodyContent: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    MessagesStream(),
                    isText
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    setState(() => isText = false);
                                    setState(() => draggable = true);
                                    pc.close();
                                  },
                                  // child: Text('입력 취소'),
                                ),
                                AvatarGlow(
                                    animate: isListening,
                                    endRadius: 33,
                                    glowColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.5),
                                    child: IconButton(
                                      icon: Icon(Icons.mic_none),
                                      onPressed: () {
                                        // maxScrolling();
                                        setState(() => isText = false);
                                        setState(() => text = '');
                                        _messageTextController.clear();
                                        toggleRecording();
                                      },
                                      // child: Text('음성 입력'),
                                    )),
                                IconButton(
                                  icon: Icon(Icons.arrow_downward),
                                  onPressed: () {
                                    maxScrolling();
                                  },
                                  // child: Text('음성 입력'),
                                )
                              ])
                        : TextButton(
                            child: Text.rich(
                              TextSpan(
                                children: <InlineSpan>[
                                  TextSpan(text: '대화하기'),
                                  WidgetSpan(
                                      child: Icon(
                                    Icons.chat,
                                    color: Colors.grey,
                                    size: 20,
                                  )),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 17),
                            ),
                            onPressed: () {
                              pc.close();
                            },

                            // child: Text('패널 열기'),
                          ),
                    SizedBox(height: 130),
                  ],
                ),
              ),
            ),
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
      await dioConnection(bdi_call, email, text).then((value) => setState(
          () => chat_list = [message = value[0], distType = value[1]]));
      // maxScrolling();
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
            // setState(() async => {message = "지금 듣고 있습니다.", isListening = true});
          } else if (!isListening) {
            Future.delayed(Duration(seconds: 2), () async {
              bubbleGenerate(text, 1, '');
              // maxScrolling();

              await dioConnection(bdi_call, email, text)
                  .then((value) => setState(() => message = value[0]));
              // maxScrolling();
            });
          } else {
            message = "";
          }
        },
      );
}

Future<List> dioConnection(String _end, String _email, String _userMsg) async {
  var formData = FormData.fromMap({
    'input_text': _userMsg,
    'present_bdi': '',
  });
  Dio dio = new Dio();
  print("state_list : ${distType}");

  Response response =
      await dio.post("$url$_end$_email&$state$distType", data: formData);

  String chat = response.data["출력"];
  String bdi = response.data["생성된 질문"]["질문"];
  String dist = response.data["생성된 질문"]["BDI"];
  var next = response.data["분석결과"]["다음 동작"];
  String q_dist = response.data["사용자 입력 BDI 분류"]["분류 결과"];
  state_list.add(next);
  print(state_list);

  if (chat.contains('\n')) chat_list = chat.split('\n');

  int yn = response.data["입력문장긍부정도"]["긍부정구분"]["분류 결과"];
  if (response.statusCode == 200) {
    if (q_dist == "일반") {
      if (chat.contains('\n'))
        for (var i = 0; i < chat_list.length; i++) {
          print(i);
          bubbleGenerate(chat_list[i], 2, dist);
        }
      else
        bubbleGenerate(chat, 2, dist);
      return [chat, next, yn];
      // print(chat_list);
    } else {
      bubbleGenerate(bdi, 2, dist);
      return [bdi, next, yn];
    }
  }
  return null;
}
