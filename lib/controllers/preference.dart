import 'package:firebase_auth/firebase_auth.dart';

const url = 'http://3.35.147.41:5000/';
// const url = "http://192.168.0.50:5000/";
const state = 'state=';
// const url = 'http://192.168.35.179:5000/';
// const url = 'http://172.30.1.16:5000/';

var currentUser = FirebaseAuth.instance.currentUser;

int len = state_list!.length;

String bdi_call = "bdiscale?email=";
// String? email = '1111@gmail.com';
String? email = currentUser?.email;
String? name = currentUser?.displayName;

List<String?> chat_list = [];
List? state_list = [];
String? distType = 'small_talk';

const bdiDist = {
  1: "슬픔",
  2: "비관주의",
  3: "과거의 실패",
  4: "즐거움상실",
  5: "죄책감",
  6: "벌받는 느낌",
  7: "자기혐오",
  8: "자기비판",
  9: "자살 사고 및 자살 소망",
  10: "울음",
  11: "초조",
  12: "흥미상실",
  13: "우유부단",
  14: "무가치함",
  15: "기력상실",
  16: "수면 양상 변화",
  17: "짜증",
  18: "식욕변화",
  19: "주의집중 어려움",
  20: "피로감",
  21: "성(性)에 대한 흥미 상실"
};

const emotions = {
  1: "공포",
  2: "놀람",
  3: "분노",
  4: "슬픔",
  5: "중립",
  6: "행복",
  7: "혐오"
};

final List<String> imagesList = [
  'https://i.insider.com/5eea8a48f0f419386721f9e8?width=1136&format=jpeg',
  'https://s3.ap-northeast-2.amazonaws.com/img.kormedi.com/news/article/__icsFiles/artimage/2015/08/22/c_km601/684186_540_2.jpg',
  'https://i.ytimg.com/vi/dq7gXN0QZco/hqdefault.jpg',
  'https://cdn.mindgil.com/news/photo/201812/67622_4_1642.jpg'
];

final List<String> titles = [' 5000보 걷기 ', ' 혼자 음악 듣기 ', ' 컬러링북 ', ' 5분 명상 '];
