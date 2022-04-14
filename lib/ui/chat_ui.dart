import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
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
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'components/components.dart';
import '../controllers/preference.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'components/safe-area.dart';

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
  int _currentIndex = 0;

  late PanelController? pc;
  late AnimationController? animationController;
  late YoutubePlayerController? vc;

  @override
  void initState() {
    super.initState();
    const url = "https://www.youtube.com/watch?v=GQyWIur03aw";

    vc = YoutubePlayerController(initialVideoId: YoutubePlayer.convertUrlToId(url)!);
    pc = PanelController();
    animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    animationController?.dispose();
    pc?.panel?.dispose();
    // Do some action when screen is closed
  }



  String selected =
      "To go back, open the panel, select an option.\nYour favorite food will be shown here.";

  BackPressBehavior behavior = BackPressBehavior.PERSIST;

  List<Widget> get _content => [
        // TODO: Change the image and status along chatting status
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
                    child: Text('대화 진행중',
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
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: false,
            enlargeCenterPage: true,
            //scrollDirection: Axis.vertical,
            onPageChanged: (index, reason) {
              setState(
                () {
                  _currentIndex = index;
                },
              );
            },
          ),
          items: imagesList
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    margin: EdgeInsets.only(
                      top: 10.0,
                      bottom: 10.0,
                    ),
                    elevation: 6.0,
                    shadowColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                      child: Stack(
                        children: <Widget>[

                          Image.network(
                            item,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                          Center(
                            child: TextButton(
                              onPressed:() {},
                              child:Text(
                              '${titles[_currentIndex]}',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                backgroundColor: Colors.black45,
                                color: Colors.white,
                              ),
                              ),
                            ),
                          ),
                          Positioned(
                              top:20,
                              left:20,
                              child: Text('${_currentIndex + 1}',
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  backgroundColor: Colors.black45,
                                  color: Colors.white,
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        ListTile(
          onTap: () {
            // pc.popWithResult(result: 'Sandwich');
            Get.to(() => SafeAreaExample());
          },
          title: Text(
            '분노 절제 명상',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        // ListTile(
        //   onTap: () {
        //     pc.sendResult(result: 'Pasta');
        //     pc.close();
        //     // THIS WILL NOT CLOSE THE PANEL, JUST SEND THE RESULT
        //   },
        //   title: Text(
        //     '죄책감 떨치기',
        //     style: Theme.of(context).textTheme.headline6,
        //   ),
        // ),
        // ListTile(
        //   onTap: () {
        //     // pc.popWithResult(result: 'Malai Kofta');
        //     // await _launchUrl('https://google.com');
        //   },
        //   title: Text(
        //     '긴장감 불안감 해소',
        //     style: Theme.of(context).textTheme.headline6,
        //   ),
        // )
      ];
  final _messageTextController = TextEditingController();

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
          child: buildSlidingPanel(context),
        ),
      ),
    );
  }

  SlidingPanel buildSlidingPanel(BuildContext context) {
    return SlidingPanel(
      panelController: pc,
      isDraggable: draggable,
      initialState: InitialPanelState.dismissed,
      backdropConfig: BackdropConfig(enabled: true, shadowColor: Colors.blue),
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
                      // print("텍스트 테스트 :: $value");
                      setState(() => this.isText = false);
                      setState(() => this.draggable = true);
                      // pc.close();
                      _messageTextController.clear();
                      bubbleGenerate(value, 1, '-');
                      toggleKeyboard();
                    },
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard),
                      tooltip: '키보드 입력 버튼',
                      onPressed: () {
                        setState(() => this.isText = true);
                        setState(() => this.draggable = false);
                        pc?.close().then((e) => new Timer(
                            const Duration(milliseconds: 500),
                            () => maxScrolling()));
                      },
                    ),
                    AvatarGlow(
                        animate: isListening,
                        endRadius: 33,
                        glowColor: Theme.of(context)
                            .primaryColor
                            .withOpacity(0.5),
                        child: IconButton(
                          icon: !isListening
                              ? Icon(Icons.mic_none)
                              : Icon(Icons.mic),
                          onPressed: () {
                            // maxScrolling();
                            setState(() => isText = false);
                            setState(() => text = '');
                            _messageTextController.clear();
                            toggleRecording();
                          },
                          // child: Text('음성 입력'),
                        )),
                  ],
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
                      if (pc?.currentState == PanelState.collapsed)
                        pc?.close().then((currentState) => {maxScrolling()});
                      else
                        pc?.collapse();
                    },
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.menu_close,
                      progress: animationController!.view,
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
                              pc?.close();
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
                                icon: !isListening
                                    ? Icon(Icons.mic_none)
                                    : Icon(Icons.mic),
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
                      onPressed: () async {
                        pc?.close();

                        await dioConnection(bdi_call, email!, "안녕");
                      },
                    ),
              SizedBox(height: 130),
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
    if(text != ''.trim()) {
      await dioConnection(bdi_call, email!, text).then((value) => setState(
          () => chat_list = [message = value[0], distType = value[1]]));
      print(email);
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
            Future.delayed(Duration(seconds:3), () async {
              await dioConnection(bdi_call, email!, text).then((value) =>
                  setState(() =>
                      chat_list = [message = value[0], distType = value[1]]));
              maxScrolling();
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

  var options = BaseOptions(
    baseUrl: '$url',
    connectTimeout: 10000,
    receiveTimeout: 10000,
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
      if (qDist == "일반") {
        if (chat.contains('\n'))
          for (var i = 0; i < chat_list.length; i++) {
            print(i);
            bubbleGenerate(chat_list[i]!, 2, dist);
          }
        else
          bubbleGenerate(chat, 2, dist);
        return [chat, next, yn];
        // print(chat_list);
      } else {
        bubbleGenerate(chat, 2, dist);
        return [bdi, next, yn];
      }
    } else {
      bubbleGenerate("서버 연결에 실패하였습니다.", 2, "connectionError");
      return [bdi, next, yn];
    }
  } catch (e) {
    print(e);
  }
  return [];
}


Future<String> httpConnection(String _end, String _email, String _userMsg) async {
  var chatUrl = Uri.parse('$url$_end$_email&$state$distType');
  var response = await http.post(chatUrl, body: {
    'input_text': _userMsg,
    'present_bdi': ''
  }).timeout((Duration(seconds: 5)));

  print('Response status: ${response.statusCode}');
  print('Response body: 11111111111111${utf8.decode(response.bodyBytes)}');

  return utf8.decode(response.bodyBytes);
}