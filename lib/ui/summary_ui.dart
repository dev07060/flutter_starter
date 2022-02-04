import 'package:flutter/material.dart';
import 'package:flutter_starter/ui/ui.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_starter/controllers/controllers.dart';
import 'package:firebase_auth/firebase_auth.dart';

final List<String> imagesList = [
  'https://i.insider.com/5eea8a48f0f419386721f9e8?width=1136&format=jpeg',
  'https://s3.ap-northeast-2.amazonaws.com/img.kormedi.com/news/article/__icsFiles/artimage/2015/08/22/c_km601/684186_540_2.jpg',
  'https://i.ytimg.com/vi/dq7gXN0QZco/hqdefault.jpg',
  'https://cdn.mindgil.com/news/photo/201812/67622_4_1642.jpg'
];
final List<String> titles = [
  ' 5000보 걷기 ',
  ' 혼자 음악 듣기 ',
  ' 컬러링북 ',
  ' 5분 명상 ',
];

class ResultSummary extends StatefulWidget {
  const ResultSummary({Key key}) : super(key: key);

  @override
  _SegmentsPageState createState() => _SegmentsPageState();
}

class _SegmentsPageState extends State<ResultSummary> {
  double cardClickElevation = 0;
  int _currentIndex = 0;
  int touchedGroupIndex = -1;
  final Color leftBarColor = Colors.blue[200];
  final double width = 11;
  var request = "${url}api/result/";

  bool _showCharts = false;
  double _pointerValue = 0;
  int total = 63;
  double _aft = 0;
  double _cgt = 0;
  double _smt = 0;
  Map<String, dynamic> _scores;
  Map<String, dynamic> _rank;
  List _chart = [];
  List _date = [];
  bool isLoading = false;
  Map<String, dynamic> resultList;

  List<BarChartGroupData> showingBarGroups;
  List<BarChartGroupData> rawBarGroups;

  List<BarChartGroupData> showingCogGroups;
  List<BarChartGroupData> rawCogBarGroups;

  List<BarChartGroupData> showingAftGroups;
  List<BarChartGroupData> rawAftBarGroups;

  @override
  void initState() {
    super.initState();
    this.fetchResult();
    this._showCharts = false;
  }

  fetchResult() async {
    Dio dio = Dio();
    Response response;

    isLoading = true;

    response = await dio.get("$request$email");
    if (response.statusCode == 200) {
      var items = response.data;

      setState(() {
        resultList = items;
        _pointerValue = resultList["bdisum"].toDouble();
        _aft = resultList["aft"].toDouble();
        _smt = resultList["smt"].toDouble();
        _cgt = resultList["cgt"].toDouble();
        _chart = resultList["value"];
        _date = resultList["value_date"];
        _scores = resultList["scores"];
        _rank = resultList["rank"];
        isLoading = false;
      });

      setState(() {
        Map<String, dynamic> resultList;
        isLoading = false;
      });

      print(_chart);
    }
  }

  void dispose() {
    super.dispose();
  }

  List<BarChartGroupData> showingGroups() => List.generate(_chart.length, (i) {
        switch (i) {
          // case 0:
          //   return makeGroupData(0, _chart[6].toDouble() ?? 0);
          case 5:
            return makeGroupData(5, _chart[5].toDouble() ?? 0);
          case 4:
            return makeGroupData(4, _chart[4].toDouble() ?? 0);
          case 3:
            return makeGroupData(3, _chart[3].toDouble() ?? 0);
          case 2:
            return makeGroupData(2, _chart[2].toDouble() ?? 0);
          case 1:
            return makeGroupData(1, _chart[1].toDouble() ?? 0);
          case 0:
            return makeGroupData(0, _chart[0].toDouble() ?? 0);
          default:
            return throw Error();
        }
      });

  List<BarChartGroupData> cogGroups() => List.generate(3, (i) {
        switch (i) {
          case 2:
            return makeFactorGroupData(
                2, _scores['cognitive'][2].toDouble() ?? 0);
          case 1:
            return makeFactorGroupData(
                1, _scores['cognitive'][1].toDouble() ?? 0);
          case 0:
            return makeFactorGroupData(
                0, _scores['cognitive'][0].toDouble() ?? 0);
          default:
            return throw Error();
        }
      });

  List<BarChartGroupData> aftGroups() =>
      List.generate(_scores['affect'].length, (i) {
        switch (i) {
          case 5:
            return makeFactorGroupData(5, _scores['affect'][5].toDouble() ?? 0);
          case 4:
            return makeFactorGroupData(4, _scores['affect'][4].toDouble() ?? 0);
          case 3:
            return makeFactorGroupData(3, _scores['affect'][3].toDouble() ?? 0);
          case 2:
            return makeFactorGroupData(2, _scores['affect'][2].toDouble() ?? 0);
          case 1:
            return makeFactorGroupData(1, _scores['affect'][1].toDouble() ?? 0);
          case 0:
            return makeFactorGroupData(0, _scores['affect'][0].toDouble() ?? 0);
          default:
            return throw Error();
        }
      });

  @override
  Widget build(BuildContext context) {
    final size = min(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height) -
        50;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(''),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
              color: Colors.black,
              icon: Icon(Icons.settings),
              onPressed: () {
                Get.to(() => SettingsUI());
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            !isLoading
                // Healthy mind meter
                ? Padding(
                    padding: EdgeInsets.only(left: size / 18, right: size / 18),
                    child: Card(
                      elevation: 6,
                      shadowColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          )),
                      child: Column(children: [
                        SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(right: 60.0),
                          child: Text(resultList["description"],
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                        SizedBox(height: 15),
                        SliderTheme(
                          data: !isLoading
                              ? SliderThemeData(
                                  trackHeight: 10,
                                  thumbColor: _pointerValue > 28
                                      ? Colors.red[200]
                                      : _pointerValue > 20 && _pointerValue < 28
                                          ? Colors.orange[100]
                                          : Colors.green[200],
                                  activeTickMarkColor: Colors.white,
                                  showValueIndicator: ShowValueIndicator.always,
                                  activeTrackColor: _pointerValue > 10 &&
                                          _pointerValue < 18
                                      ? Colors.greenAccent
                                      : _pointerValue > 18 && _pointerValue < 28
                                          ? Colors.orangeAccent
                                          : _pointerValue > 28 &&
                                                  _pointerValue < 38
                                              ? Colors.redAccent
                                              : _pointerValue > 38 &&
                                                      _pointerValue < 63
                                                  ? Colors.red[600]
                                                  : Colors.blueAccent,
                                  inactiveTrackColor: Colors.grey,
                                  inactiveTickMarkColor: Colors.white,
                                  thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 10),
                                )
                              : SliderThemeData(
                                  trackHeight: 10,
                                  thumbColor: Colors.white,
                                  activeTickMarkColor: Colors.white,
                                  activeTrackColor: Colors.grey,
                                  inactiveTrackColor: Colors.grey,
                                  inactiveTickMarkColor: Colors.white,
                                  thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 10),
                                ),
                          child: AbsorbPointer(
                            child: Slider(
                                label: _pointerValue.toString(),
                                divisions: 6,
                                value: _pointerValue,
                                min: 0,
                                max: 63,
                                onChanged: (value) {
                                  setState(() {
                                    _pointerValue = value;
                                  });
                                }),
                          ),
                        ),
                        Text(resultList["solution"],
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: 30)
                      ]),
                    ),
                  )
                : SizedBox(
                    width: 330.0,
                    height: 200.0,
                    child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.white,
                        child: Card(
                          elevation: 6,
                          shadowColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side: BorderSide(
                                color: Colors.grey.withOpacity(0.2),
                                width: 1,
                              )),
                        )),
                  ),
            SizedBox(height: 24),
            Container(
              width: 700,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    // 인지영역 요소
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("원인을 파악했어요 🕵🏻‍♂️",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("우울증을 느낄 요소가 많았어요",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w600)),
                    ),
                    SizedBox(height: 10),
                    !isLoading
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Brian님과 대화 중에 수집한 정보에 의하면 \n${_rank['cognitive'][0]}, ${_rank['cognitive'][1]}과 같은 우울증의 원인 요소들을 \n많이 느끼고 계신거 같아 보여요.\n주변 환경, 과거의 일이 관련이 있는 경우가 많아요",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              softWrap: true,
                            ),
                          )
                        : SizedBox(
                            width: size,
                            height: 30.0,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey[300],
                                highlightColor: Colors.white,
                                child: Card(
                                  elevation: 6,
                                  shadowColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      side: BorderSide(
                                        color: Colors.grey.withOpacity(0.2),
                                        width: 1,
                                      )),
                                )),
                          ),
                    SizedBox(height: 24),
                    !isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: GestureDetector(
                                onTap: () => {
                                  setState(() => {cardClickElevation = 0})
                                },
                                child: Card(
                                  elevation: cardClickElevation,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(35)),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        SizedBox(height: 12),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text("요소별 측정치",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                        ),
                                        Expanded(
                                          child: BarChart(
                                            BarChartData(
                                              maxY: 4,
                                              barTouchData: BarTouchData(
                                                touchTooltipData:
                                                    BarTouchTooltipData(
                                                  tooltipBgColor:
                                                      Colors.grey[600],
                                                  tooltipPadding:
                                                      const EdgeInsets.only(
                                                          left: 5,
                                                          right: 4,
                                                          top: 4,
                                                          bottom: 1),
                                                  tooltipMargin: 8,
                                                  getTooltipItem: (
                                                    BarChartGroupData group,
                                                    int groupIndex,
                                                    BarChartRodData rod,
                                                    int rodIndex,
                                                  ) =>
                                                      BarTooltipItem(
                                                    rod.y.toStringAsFixed(1),
                                                    const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              titlesData: FlTitlesData(
                                                show: true,
                                                rightTitles: SideTitles(
                                                    showTitles: false),
                                                topTitles: SideTitles(
                                                    showTitles: false),
                                                bottomTitles: SideTitles(
                                                  showTitles: true,
                                                  getTextStyles: (context,
                                                          value) =>
                                                      const TextStyle(
                                                          color:
                                                              Color(0xff7589a2),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                  margin: 20,
                                                  getTitles: (double value) {
                                                    switch (value.toInt()) {
                                                      case 7:
                                                        return _rank[
                                                                    'cognitive']
                                                                [7] ??
                                                            0.0;
                                                      case 6:
                                                        return _rank[
                                                                    'cognitive']
                                                                [6] ??
                                                            0.0;
                                                      case 5:
                                                        return _rank[
                                                                    'cognitive']
                                                                [5] ??
                                                            0.0;
                                                      case 4:
                                                        return _rank[
                                                                    'cognitive']
                                                                [4] ??
                                                            0.0;
                                                      case 3:
                                                        return _rank[
                                                                    'cognitive']
                                                                [3] ??
                                                            0.0;
                                                      case 2:
                                                        return _rank[
                                                                    'cognitive']
                                                                [2] ??
                                                            0;
                                                      case 1:
                                                        return _rank[
                                                                    'cognitive']
                                                                [1] ??
                                                            0;
                                                      case 0:
                                                        return _rank[
                                                                    'cognitive']
                                                                [0] ??
                                                            0;
                                                      default:
                                                        return '';
                                                    }
                                                  },
                                                ),
                                                leftTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              borderData: FlBorderData(
                                                show: false,
                                              ),
                                              barGroups: cogGroups(),
                                              gridData: FlGridData(show: false),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                              width: 300.0,
                              height: 350.0,
                              child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300],
                                  highlightColor: Colors.white,
                                  child: Card(
                                    elevation: 6,
                                    shadowColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        side: BorderSide(
                                          color: Colors.grey.withOpacity(0.2),
                                          width: 1,
                                        )),
                                  )),
                            ),
                          ),
                    Align(
                      alignment: Alignment.center,
                      child: Text("요소별 측정치는 수치가 높을수록 위험한 요소입니다",
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600)),
                    ),
                    Row(children: <Widget>[
                      if (!isLoading)
                        Column(children: [
                          SizedBox(
                              height: 60,
                              width: size / 2,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(_rank['cognitive'][0],
                                    style: TextStyle(
                                        fontSize: 25, color: Colors.black)),
                              )),
                          SizedBox(
                              height: 60,
                              width: size / 2,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                    _scores['cognitive'][0].toStringAsFixed(1),
                                    style: TextStyle(
                                        fontSize: 25, color: Colors.black)),
                              )),
                        ])
                      else
                        Text(""),
                      if (!isLoading)
                        Column(children: [
                          SizedBox(
                              height: 60,
                              width: size / 2,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(_rank['cognitive'][1],
                                    style: TextStyle(
                                        fontSize: 25, color: Colors.black)),
                              )),
                          SizedBox(
                              height: 60,
                              width: size / 2,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                    _scores['cognitive'][1].toStringAsFixed(1),
                                    style: TextStyle(
                                        fontSize: 25, color: Colors.black)),
                              )),
                        ])
                      else
                        Text(""),
                    ]),
                    SizedBox(height: 24),
                    Divider(color: Colors.black38),
                    SizedBox(height: 24),
                    // 감정영역 요소
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("혹시 요즘..",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("슬픈 감정을 자주 느끼시나요?",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w600)),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "대화 중에 제가 느낀 Brian님의 감정상태는\n슬픈 감정을 자주 느끼시는 걸로 보여요\n떨쳐내려고 하기보다 조용한 노래를 들으며\n지금의 슬픈 감정의 원인이 무엇인지 생각해봐요",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        softWrap: true,
                      ),
                    ),
                    SizedBox(height: 24),

                    Divider(),
                    SizedBox(height: 24),
                    // 감정영역 요소
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("자주 깜빡깜빡 하신다면🤦🏻",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("내 기억력 누가 훔쳐갔지?",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w600)),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "집중력과 기억력에 문제가 생기신거 같네요\n심한 스트레스나 우울증에도 이런 증상이 나타나요\n몇가지 방법으로 다시 되찾을 수 있어요",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        softWrap: true,
                      ),
                    ),
                    SizedBox(height: 24),
                    Divider(),
                    SizedBox(height: 24),
                    !_showCharts
                        ? TextButton(
                            style: TextButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                                alignment: Alignment.center),
                            onPressed: () {
                              setState(() => {_showCharts = true});
                            },
                            child: Column(children: [
                              Text("내 통계 보기",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500)),
                              Icon(Icons.bar_chart, size: 25),
                            ]),
                          )
                        : Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text("내 통계",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 23,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                              SizedBox(height: 10),
                              AspectRatio(
                                aspectRatio: 1,
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        SizedBox(height: 12),

                                        Align(
                                          alignment: Alignment.center,
                                          child: Text("내 마음 건강지수",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600)),
                                        ),

                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                        ),
                                        // const SizedBox(
                                        //   height: 38,
                                        // ),
                                        Expanded(
                                          child: BarChart(
                                            BarChartData(
                                              maxY: 63,
                                              barTouchData: BarTouchData(
                                                touchTooltipData:
                                                    BarTouchTooltipData(
                                                  tooltipBgColor:
                                                      Colors.grey[400],
                                                  tooltipPadding:
                                                      const EdgeInsets.only(
                                                          left: 5,
                                                          right: 4,
                                                          top: 4,
                                                          bottom: 1),
                                                  tooltipMargin: 8,
                                                  getTooltipItem: (
                                                    BarChartGroupData group,
                                                    int groupIndex,
                                                    BarChartRodData rod,
                                                    int rodIndex,
                                                  ) =>
                                                      BarTooltipItem(
                                                    rod.y.round().toString(),
                                                    const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              titlesData: FlTitlesData(
                                                show: true,
                                                rightTitles: SideTitles(
                                                    showTitles: false),
                                                topTitles: SideTitles(
                                                    showTitles: false),
                                                bottomTitles: SideTitles(
                                                  showTitles: true,
                                                  getTextStyles: (context,
                                                          value) =>
                                                      const TextStyle(
                                                          color:
                                                              Color(0xff7589a2),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                  margin: 20,
                                                  getTitles: (double value) {
                                                    switch (value.toInt()) {
                                                      // case 0:
                                                      //   return _date[0] ?? "0";
                                                      // case 1:
                                                      //   return _date[1] ?? "0";
                                                      case 4:
                                                        return _date[4] ?? "0";
                                                      case 3:
                                                        return _date[3] ?? "0";
                                                      case 2:
                                                        return _date[2] ?? "0";
                                                      case 1:
                                                        return _date[1] ?? "0";
                                                      case 0:
                                                        return _date[0] ?? "0";
                                                      default:
                                                        return '';
                                                    }
                                                  },
                                                ),
                                                leftTitles: SideTitles(
                                                  showTitles: false,
                                                  getTextStyles: (context,
                                                          value) =>
                                                      const TextStyle(
                                                          color:
                                                              Color(0xff7589a2),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                  margin: 8,
                                                  reservedSize: 28,
                                                  interval: 1,
                                                  // getTitles: (value) {
                                                  //   if (value == 0) {
                                                  //     return '건강';
                                                  //   } else if (value == 10) {
                                                  //     return '1';
                                                  //   } else if (value == 20) {
                                                  //     return '2';
                                                  //   } else if (value == 30) {
                                                  //     return '3';
                                                  //   } else if (value == 45) {
                                                  //     return '4';
                                                  //   } else if (value == 55) {
                                                  //     return '5';
                                                  //   } else {
                                                  //     return '';
                                                  //   }
                                                  // },
                                                ),
                                              ),
                                              borderData: FlBorderData(
                                                show: false,
                                              ),
                                              barGroups: showingGroups(),
                                              gridData: FlGridData(show: false),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 26,
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                    splashFactory: NoSplash.splashFactory,
                                    alignment: Alignment.center),
                                onPressed: () {
                                  setState(() => {_showCharts = false});
                                },
                                child: Column(children: [
                                  Text("내 통계 접기",
                                      style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500)),
                                  Icon(Icons.bar_chart,
                                      size: 25, color: Colors.grey)
                                ]),
                              ),
                              SizedBox(height: 10),
                            ],
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
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y1) =>
      BarChartGroupData(barsSpace: 4, x: x, barRods: [
        BarChartRodData(
          y: y1,
          colors: [
            Colors.blue[200],
            Colors.green[200],
            Colors.orangeAccent,
            Colors.redAccent,
            Colors.redAccent,
          ],
          width: width,
        )
      ], showingTooltipIndicators: [
        0
      ]);

  BarChartGroupData makeFactorGroupData(int x, double y1) =>
      BarChartGroupData(barsSpace: 4, x: x, barRods: [
        BarChartRodData(
          y: y1,
          colors: [
            Colors.white70,
            Colors.orange[400],
            Colors.orangeAccent,
            Colors.orangeAccent,
          ],
          width: width,
        )
      ], showingTooltipIndicators: [
        0
      ]);
// BarChartRodData(
//   y: y2,
//   colors: [rightBarColor],
//   width: width,
// ),

}
