import 'package:flutter_starter/constants/reviews.dart';
import 'package:flutter_starter/models/location.dart';

List<Location> locations = [
  Location(
    name: 'Relaxing',
    urlImage: 'assets/images/sea.jpg',
    addressLine1: '불안감, 긴장감 완화',
    addressLine2: '가장 많이 시청한 영상',
    starRating: 4,
    latitude: 'Relaxing Music',
    longitude: 'Piano, Chill',
    reviews: Reviews.allReviews,
  ),
  Location(
    name: 'Depressed',
    urlImage: 'assets/images/mountain.jpg',
    addressLine1: '슬픔, 우울감 완화',
    addressLine2: '우울감에 효과',
    starRating: 4,
    latitude: 'Depressed',
    longitude: 'Sad',
    reviews: Reviews.allReviews,
  ),
  Location(
    name: 'Sleep theraphy',
    urlImage: 'assets/images/sea2.jpg',
    addressLine1: '수면부족, 피로감',
    addressLine2: '숙면을 돕는 음악',
    starRating: 4,
    latitude: 'Insomnia',
    longitude: 'Fatigue',
    reviews: Reviews.allReviews,
  ),
  Location(
    name: 'Guilty',
    urlImage: 'assets/images/mountain2.jpg',
    addressLine1: '자책감, 과거의 실패',
    addressLine2: '자존감 회복에 도움을 주는 영상',
    starRating: 4,
    latitude: 'Self accusation',
    longitude: 'Past failure',
    reviews: Reviews.allReviews,
  ),
];
