import 'package:firebase_auth/firebase_auth.dart';

const url = "http://192.168.0.37:5001/";
// const url = "http://192.168.35.179:5001/";
var currentUser = FirebaseAuth.instance.currentUser;
String bdi_call = "bdiscale?email=";
String email = currentUser.email;
String name = currentUser.displayName;

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


// const url = "http://192.168.0.37:5001/";

