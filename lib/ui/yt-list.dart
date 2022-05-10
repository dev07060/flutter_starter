import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../constants/video_list.dart';

/// Creates [YoutubePlayerDemoApp] widget.
// class YoutubePlayerList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Youtube Player Flutter',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         appBarTheme: const AppBarTheme(
//           color: Colors.blueAccent,
//           textTheme: TextTheme(
//             headline6: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w300,
//               fontSize: 20.0,
//             ),
//           ),
//         ),
//         iconTheme: const IconThemeData(
//           color: Colors.blueAccent,
//         ),
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

/// Homepage
class YoutubePlayerList extends StatefulWidget {
  @override
  _YoutubePlayerListState createState() => _YoutubePlayerListState();
}

class _YoutubePlayerListState extends State<YoutubePlayerList> {
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;

  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  double _volume = 30;
  bool _muted = false;
  bool _isPlayerReady = false;
  bool _isFavorite = false;
  bool _isExcept = false;

  late Timer _timer;
  bool _isRunning = false;
  int _timerCount = 0;
  int _ms = 1000;

  final List<Map<String, String>> elements = [
    {
      'factor': 'video.category1'.tr,
      'title': 'video_title1'.tr,
      'id': 'vid_1'.tr,
      'thumbnail': 'video_thumbnail1'.tr
    },
    {
      'factor': 'video.category2'.tr,
      'title': 'video_title2'.tr,
      'id': 'vid_2'.tr,
      'thumbnail': 'video_thumbnail2'.tr
    },
    {
      'factor': 'video.category3'.tr,
      'title': 'video_title3'.tr,
      'id': 'vid_3'.tr,
      'thumbnail': 'video_thumbnail3'.tr
    },
    {
      'factor': 'video.category4'.tr,
      'title': 'video_title4'.tr,
      'id': 'vid_4'.tr,
      'thumbnail': 'video_thumbnail4'.tr
    },
    {
      'factor': 'video.category5'.tr,
      'title': 'video_title5'.tr,
      'id': 'vid_5'.tr,
      'thumbnail': 'video_thumbnail5'.tr
    },
    {
      'factor': 'video.category6'.tr,
      'title': 'video_title6'.tr,
      'id': 'vid_6'.tr,
      'thumbnail': 'video_thumbnail6'.tr
    },
    // {'Factor': 'F', '제목': '힐링영상', 'id': ''},
  ];
  final List<String> _ids = [
    'vid_1'.tr,
    'vid_2'.tr,
    'vid_3'.tr,
    'vid_4'.tr,
    'vid_5'.tr,
    'vid_6'.tr,
  ];
  void _start() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timerCount++;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: _ids.first,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _controller.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () {
              log('Settings Tapped!');
            },
          ),
        ],
        onReady: () {
          _isPlayerReady = true;
          if (_playerState != PlayerState.playing) {
            setState(() {
              _timerCount = 0;
            });
          } else if (_playerState != PlayerState.unknown) {
            _start;
          } else {
            _start;
            // _timer = Timer.periodic(Duration(milliseconds: _ms), (timer) {
            //   setState(() {
            //     _timerCount++;
            //   });
            // });
          }
          ;
        },
        onEnded: (data) {
          _countTime(_timerCount);
          _controller
              .load(_ids[(_ids.indexOf(data.videoId) + 1) % _ids.length]);
          _showSnackBar('Next Video Started!', 'notice');
          setState(() {
            _timerCount = 0;
          });
        },
      ),
      builder: (context, player) => Scaffold(
        // appBar: AppBar(
        //   leading: Padding(
        //     padding: const EdgeInsets.only(left: 12.0),
        //     child: Image.asset(
        //       'assets/ypf.png',
        //       fit: BoxFit.fitWidth,
        //     ),
        //   ),
        //   title: const Text(
        //     'Youtube Player Flutter',
        //     style: TextStyle(color: Colors.white),
        //   ),
        //   actions: [
        //     IconButton(
        //       icon: const Icon(Icons.video_library),
        //       onPressed: () {},
        //     ),
        //   ],
        // ),

        body: ListView(
          children: [
            player,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _isPlayerReady
                      ? () => {
                            _countTime(_timerCount),
                            _controller.load(_ids[
                                (_ids.indexOf(_controller.metadata.videoId) -
                                        1) %
                                    _ids.length]),
                            setState(() {
                              _timerCount = 0;
                            }),
                          }
                      : null,
                ),
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  onPressed: _isPlayerReady
                      ? () {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                            setState(() {
                              _isRunning = false;
                            });
                            _timer.cancel();
                            print(_isRunning);
                          } else if (_playerState == PlayerState.paused) {
                            _controller.play();
                            setState(() {
                              _isRunning = true;
                            });
                            _timer = Timer.periodic(Duration(milliseconds: _ms),
                                (timer) {
                              setState(() {
                                _timerCount++;
                              });
                            });
                            // print(_isRunning);
                          }
                        }
                      : () {},
                ),
                IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: () => {
                          _countTime(_timerCount),
                          _controller.load(_ids[
                              (_ids.indexOf(_controller.metadata.videoId) + 1) %
                                  _ids.length]),
                          setState(() {
                            _timerCount = 0;
                          }),
                        }),
                IconButton(
                    color: _isFavorite ? Colors.red : null,
                    icon: _isFavorite
                        ? Icon(Icons.favorite)
                        : Icon(Icons.favorite_outline),
                    onPressed: !_isExcept
                        ? () => {
                              setState(() {
                                !_isFavorite
                                    ? _isFavorite = true
                                    : _isFavorite = false;
                              }),
                              _isFavorite
                                  ? _showSnackBar('찜 컨텐츠로 저장되었습니다', 'notice')
                                  : _showSnackBar('찜 컨텐츠에서 삭제되었습니다', 'notice'),
                            }
                        : () {
                            _showSnackBar('먼저 제외 컨텐츠에서 삭제하세요', 'warning');
                          }),
                IconButton(
                    color: _isExcept ? Colors.blue[400] : null,
                    icon: _isExcept
                        ? Icon(Icons.thumb_down)
                        : Icon(Icons.thumb_down_outlined),
                    onPressed: !_isFavorite
                        ? () => {
                              setState(() {
                                !_isExcept
                                    ? _isExcept = true
                                    : _isExcept = false;
                              }),
                              _isExcept
                                  ? _showSnackBar('제외 컨텐츠로 저장되었습니다', 'notice')
                                  : _showSnackBar('제외 컨텐츠에서 삭제되었습니다', 'notice'),
                            }
                        : () {
                            _showSnackBar('먼저 찜 컨텐츠에서 삭제하세요', 'warning');
                          }),
              ],
            ),
            _space,
            _space,
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                        onPressed: _isPlayerReady
                            ? () {
                                _muted
                                    ? _controller.unMute()
                                    : _controller.mute();
                                setState(() {
                                  _muted = !_muted;
                                });
                              }
                            : null,
                      ),
                      Expanded(
                        child: Slider(
                          inactiveColor: Colors.transparent,
                          value: _volume,
                          min: 0.0,
                          max: 100.0,
                          divisions: 10,
                          label: '${(_volume).round()}',
                          onChanged: _isPlayerReady
                              ? (value) {
                                  setState(() {
                                    _volume = value;
                                  });
                                  _controller.setVolume(_volume.round());
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                  _space,
                  _text('제목', _videoMetaData.title),
                  _space,
                  _text('채널명', _videoMetaData.author),
                  _space,
                  // _text('비디오 길이(초)', "${_videoMetaData.duration.inSeconds}"),
                  // _space,
                  // _text('재생 시간(초)', "${_timerCount}"),

                  // _text('Video Id', _videoMetaData.videoId),
                  // _space,
                  // Row(
                  //   children: [],
                  // ),
                  // _space,
                  // TextField(
                  //   enabled: _isPlayerReady,
                  //   controller: _idController,
                  //   decoration: InputDecoration(
                  //     border: InputBorder.none,
                  //     hintText: 'Enter youtube \<video id\> or \<link\>',
                  //     fillColor: Colors.blueAccent.withAlpha(20),
                  //     filled: true,
                  //     hintStyle: const TextStyle(
                  //       fontWeight: FontWeight.w300,
                  //       color: Colors.blueAccent,
                  //     ),
                  //   ),
                  // ),
                  //
                  // _space,
                  // Row(
                  //   children: [
                  //     _loadCueButton('LOAD'),
                  //     const SizedBox(width: 10.0),
                  //     _loadCueButton('CUE'),
                  //   ],
                  // ),
                  // _space,

                  // AnimatedContainer(
                  //   duration: const Duration(milliseconds: 800),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(20.0),
                  //     color: _getStateColor(_playerState),
                  //   ),
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Text(
                  //     _playerState.toString(),
                  //     style: const TextStyle(
                  //       fontWeight: FontWeight.w300,
                  //       color: Colors.white,
                  //     ),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
                ],
              ),
            ),
            SizedBox(height: 350, child: _listBuild(context))
          ],
        ),
      ),
    );
  }

  Widget _listBuild(BuildContext context) => GroupedListView<dynamic, String>(
      useStickyGroupSeparators: true,
      elements: elements,
      groupBy: (element) => element['factor']!,
      groupSeparatorBuilder: (value) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          color: Colors.blue[200],
          child: Text(
            value,
            style: GoogleFonts.gowunDodum(
              textStyle: (TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[900],
              )),
            ),
          )),
      itemBuilder: (context, element) => Card(
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12.0),
              leading: Image(
                  image: NetworkImage(
                element['thumbnail'],
              )),
              title: TextButton(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Text(
                    element['title']!,
                    style: GoogleFonts.gowunDodum(
                      textStyle: (TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[900],
                      )),
                    ),
                  ),
                ),
                onPressed: () {
                  _controller.load(element['id']!);
                },
              ),
            ),
          ));

  Widget _text(String title, String value) {
    return RichText(
      text: TextSpan(
        text: '$title : ',
        style: GoogleFonts.gowunDodum(
          textStyle: (TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[900],
          )),
        ),
        // const TextStyle(
        //     color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
        children: [
          TextSpan(
            text: value,
            style: GoogleFonts.gowunDodum(
              textStyle: (TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[900],
              )),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStateColor(PlayerState state) {
    switch (state) {
      case PlayerState.unknown:
        return Colors.grey[700]!;
      case PlayerState.unStarted:
        return Colors.pink;
      case PlayerState.ended:
        return Colors.red;
      case PlayerState.playing:
        return Colors.blueAccent;
      case PlayerState.paused:
        return Colors.orange;
      case PlayerState.buffering:
        return Colors.yellow;
      case PlayerState.cued:
        return Colors.blue[900]!;
      default:
        return Colors.blue;
    }
  }

  Widget get _space => const SizedBox(height: 10);

  Widget _loadCueButton(String action) {
    return Expanded(
      child: MaterialButton(
        color: Colors.blueAccent,
        onPressed: _isPlayerReady
            ? () {
                if (_idController.text.isNotEmpty) {
                  var id = YoutubePlayer.convertUrlToId(
                        _idController.text,
                      ) ??
                      '';
                  if (action == 'LOAD') _controller.load(id);
                  if (action == 'CUE') _controller.cue(id);
                  FocusScope.of(context).requestFocus(FocusNode());
                } else {
                  _showSnackBar('Source can\'t be empty!', 'warning');
                }
              }
            : null,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
            action,
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  int? _countTime(int time) {
    if (time < _videoMetaData.duration.inSeconds) {
      double fifth = _videoMetaData.duration.inSeconds / 5;
      int a = fifth.toInt() * 1;
      int b = fifth.toInt() * 2;
      int c = fifth.toInt() * 3;
      int d = fifth.toInt() * 4;
      int e = fifth.toInt() * 5;

      if (time <= a) {
        log("5구간 점수 : 1/5");
        log("감상 시간 (재생시간 / 영상길이): $time / ${_videoMetaData.duration.inSeconds}");
        return 1;
      } else if (time <= b) {
        log("5구간 점수 : 2/5");
        log("감상 시간 (재생시간 / 영상길이): $time / ${_videoMetaData.duration.inSeconds}");
        return 2;
      } else if (time <= c) {
        log("5구간 점수 : 3/5");
        log("감상 시간 (재생시간 / 영상길이): $time / ${_videoMetaData.duration.inSeconds}");
        return 3;
      } else if (time <= d) {
        log("5구간 점수 : 4/5");
        log("감상 시간 (재생시간 / 영상길이): $time / ${_videoMetaData.duration.inSeconds}");
        return 4;
      } else if (time <= e) {
        log("5구간 점수 : 5/5");
        log("감상 시간 (재생시간 / 영상길이): $time / ${_videoMetaData.duration.inSeconds}");
        return 5;
      } else {
        return null;
      }

      log("5구간 : $a, $b, $c, $d, $e");
      log("감상 시간 (재생시간 / 영상길이): $fifth / ${_videoMetaData.duration.inSeconds}");
      return fifth.toInt();
    } else if (time >= _videoMetaData.duration.inSeconds) {
      print("시간 초과");
      return 5;
    }
  }

  void _showSnackBar(String message, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 1000),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: action == 'notice'
            ? Colors.blueAccent
            : action == 'warning'
                ? Colors.red[400]
                : Colors.green[400],
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }
}
