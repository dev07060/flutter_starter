import 'package:flutter/material.dart';
import 'package:flutter_starter/constants/hero_tag.dart';
import 'package:flutter_starter/models/location.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hero_widget.dart';
import 'lat_long_widget.dart';

class ImageWidget extends StatelessWidget {
  final Location location;

  const ImageWidget({
    required this.location,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      /// space from white container
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: size.height * 0.5,
      width: size.width * 0.8,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 2, spreadRadius: 1),
          ],
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Stack(
          children: [
            buildImage(),
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildTopText(),
                  LatLongWidget(location: location),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildImage() => SizedBox.expand(
        child: HeroWidget(
          tag: HeroTag.image(location.urlImage),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: Image.asset(location.urlImage, fit: BoxFit.cover),
          ),
        ),
      );

  Widget buildTopText() => Text(
        location.name,
        style: GoogleFonts.montserrat(
          textStyle: (TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w200,
            color: Colors.black45,
          )),
        ),
      );
}
