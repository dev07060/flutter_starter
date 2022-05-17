import 'package:flutter/material.dart';
import 'package:flutter_starter/constants/hero_tag.dart';
import 'package:flutter_starter/constants/locations.dart';
import 'package:flutter_starter/models/location.dart';
import 'package:flutter_starter/ui/components/stars_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hero_widget.dart';
import 'stars_widget.dart';

import 'hero_widget.dart';

class ExpandedContentWidget extends StatelessWidget {
  final Location location;

  const ExpandedContentWidget({
    required this.location,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            HeroWidget(
              tag: HeroTag.addressLine1(location),
              child: Text(
                location.addressLine1,
                style: GoogleFonts.gowunDodum(
                  textStyle: (TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[900],
                  )),
                ),
              ),
            ),
            SizedBox(height: 8),
            buildAddressRating(location: location),
            SizedBox(height: 12),
            buildReview(location: location)
          ],
        ),
      );

  Widget buildAddressRating({
    required Location location,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          HeroWidget(
            tag: HeroTag.addressLine2(location),
            child: Text(
              location.addressLine2,
              style: GoogleFonts.gowunDodum(
                textStyle: (TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[900],
                )),
              ),
            ),
          ),
          HeroWidget(
            tag: HeroTag.stars(location),
            child: StarsWidget(stars: location.starRating),
          ),
        ],
      );

  Widget buildReview({
    required Location location,
  }) =>
      Row(
        children: location.reviews.map((review) {
          final pageIndex = locations.indexOf(location);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: HeroWidget(
              tag: HeroTag.avatar(review, pageIndex),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.black12,
                backgroundImage: AssetImage(review.urlImage),
              ),
            ),
          );
        }).toList(),
      );
}
