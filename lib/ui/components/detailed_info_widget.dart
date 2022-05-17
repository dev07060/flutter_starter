import 'package:flutter/material.dart';
import 'package:flutter_starter/constants/hero_tag.dart';
import 'package:flutter_starter/models/location.dart';
import 'hero_widget.dart';
import 'stars_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailedInfoWidget extends StatelessWidget {
  final Location location;

  const DetailedInfoWidget({
    required this.location,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(height: 8),
            HeroWidget(
              tag: HeroTag.stars(location),
              child: StarsWidget(stars: location.starRating),
            ),
          ],
        ),
      );
}
