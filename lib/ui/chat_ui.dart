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
import 'package:sliding_up_panel/sliding_up_panel.dart';
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

  int flow = 0;
  int yn = 0;
  int _currentIndex = 0;

  AnimationController? animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this);
    _fabHeight = _initFabHeight;
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
            autoPlay: true,
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
                            child: Text(
                              '${titles[_currentIndex]}',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                backgroundColor: Colors.black45,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        // ListTile(
        //   onTap: () {
        //     // pc.popWithResult(result: 'Sandwich');
        //     Get.to(() => SafeAreaExample());
        //   },
        //   title: Text(
        //     '분노 절제 명상',
        //     style: Theme.of(context).textTheme.headline6,
        //   ),
        // ),
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
        ListTile(
          onTap: () {
            // pc.popWithResult(result: 'Malai Kofta');
            // await _launchUrl('https://google.com');
          },
          title: Text(
            '긴장감 불안감 해소',
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
          onNotification: (food) {
            setState(() {
              print('You sent ${food.result}');
              selected = "You ordered ${food.result}.\n\nNow you can go back.";
              behavior = BackPressBehavior.POP;
            });
            return false;
          },
          child: buildSlidingPanel(context),
        ),
      ),
    );
  }

  SlidingUpPanel buildSlidingPanel(BuildContext context) {
    return SlidingUpPanel(
        maxHeight: _panelHeightOpen,
        minHeight: _panelHeightClosed,
        parallaxEnabled: true,
        parallaxOffset: .5,
        isDraggable: draggable,
        panelBuilder: (sc) => _panel(sc),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
        onPanelSlide: (double pos) => setState(() {
              _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                  _initFabHeight;
            }),
        body: isText
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
                    },
                  ),
                  AvatarGlow(
                      animate: isListening,
                      endRadius: 33,
                      glowColor:
                          Theme.of(context).primaryColor.withOpacity(0.5),
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
              ));
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Explore Pittsburgh",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 24.0,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 36.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _button("Popular", Icons.favorite, Colors.blue),
                _button("Food", Icons.restaurant, Colors.red),
                _button("Events", Icons.event, Colors.amber),
                _button("More", Icons.more_horiz, Colors.green),
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
                    """Pittsburgh is a city in the state of Pennsylvania in the United States, and is the county seat of Allegheny County. A population of about 302,407 (2018) residents live within the city limits, making it the 66th-largest city in the U.S. The metropolitan population of 2,324,743 is the largest in both the Ohio Valley and Appalachia, the second-largest in Pennsylvania (behind Philadelphia), and the 27th-largest in the U.S.\n\nPittsburgh is located in the southwest of the state, at the confluence of the Allegheny, Monongahela, and Ohio rivers. Pittsburgh is known both as "the Steel City" for its more than 300 steel-related businesses and as the "City of Bridges" for its 446 bridges. The city features 30 skyscrapers, two inclined railways, a pre-revolutionary fortification and the Point State Park at the confluence of the rivers. The city developed as a vital link of the Atlantic coast and Midwest, as the mineral-rich Allegheny Mountains made the area coveted by the French and British empires, Virginians, Whiskey Rebels, and Civil War raiders.\n\nAside from steel, Pittsburgh has led in manufacturing of aluminum, glass, shipbuilding, petroleum, foods, sports, transportation, computing, autos, and electronics. For part of the 20th century, Pittsburgh was behind only New York City and Chicago in corporate headquarters employment; it had the most U.S. stockholders per capita. Deindustrialization in the 1970s and 80s laid off area blue-collar workers as steel and other heavy industries declined, and thousands of downtown white-collar workers also lost jobs when several Pittsburgh-based companies moved out. The population dropped from a peak of 675,000 in 1950 to 370,000 in 1990. However, this rich industrial history left the area with renowned museums, medical centers, parks, research centers, and a diverse cultural district.\n\nAfter the deindustrialization of the mid-20th century, Pittsburgh has transformed into a hub for the health care, education, and technology industries. Pittsburgh is a leader in the health care sector as the home to large medical providers such as University of Pittsburgh Medical Center (UPMC). The area is home to 68 colleges and universities, including research and development leaders Carnegie Mellon University and the University of Pittsburgh. Google, Apple Inc., Bosch, Facebook, Uber, Nokia, Autodesk, Amazon, Microsoft and IBM are among 1,600 technology firms generating \$20.7 billion in annual Pittsburgh payrolls. The area has served as the long-time federal agency headquarters for cyber defense, software engineering, robotics, energy research and the nuclear navy. The nation's eighth-largest bank, eight Fortune 500 companies, and six of the top 300 U.S. law firms make their global headquarters in the area, while RAND Corporation (RAND), BNY Mellon, Nova, FedEx, Bayer, and the National Institute for Occupational Safety and Health (NIOSH) have regional bases that helped Pittsburgh become the sixth-best area for U.S. job growth.
                  """,
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

  Widget _button(String label, IconData icon, Color color) {
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
              color: Color.fromRGBO(0, 0, 0, 0.15),
              blurRadius: 8.0,
            )
          ]),
        ),
        SizedBox(
          height: 12.0,
        ),
        Text(label),
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

Future<String> httpConnection(
    String _end, String _email, String _userMsg) async {
  var chatUrl = Uri.parse('$url$_end$_email&$state$distType');
  var response = await http.post(chatUrl, body: {
    'input_text': _userMsg,
    'present_bdi': ''
  }).timeout((Duration(seconds: 5)));

  print('Response status: ${response.statusCode}');
  print('Response body: 11111111111111${utf8.decode(response.bodyBytes)}');

  return utf8.decode(response.bodyBytes);
}
