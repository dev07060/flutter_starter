import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_starter/models/models.dart';

import 'package:flutter/services.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rive/rive.dart';

import '../../controllers/preference.dart';

class UserChatBubble extends StatelessWidget {
  final ChatMessageModel chatMessageModelRecord;
  final double iconSize = 45;
  final double paddingSize = 5;
  const UserChatBubble({
    Key? key,
    required this.chatMessageModelRecord,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Row(
        // if message ID is not '2' generate user chat bubble otherwise ID is '1' generate bot chat bubble
        mainAxisAlignment: chatMessageModelRecord.id > 1
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: chatMessageModelRecord.id == 2
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          chatMessageModelRecord.id == 2
              ? Center(
                  child: Padding(
                      padding: EdgeInsets.only(right: paddingSize),
                      child: Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  opacity: 30,
                                  fit: BoxFit.fill,
                                  image: AssetImage(
                                      'assets/images/metaIcon.png'))))))
              : chatMessageModelRecord.id > 2
                  ? SizedBox(width: iconSize + paddingSize)
                  : Text(""),
          Padding(
            padding: EdgeInsets.only(
              top: chatMessageModelRecord.id == 2
                  ? 9
                  : chatMessageModelRecord.id == 1
                      ? 9
                      : 3,
              bottom: 3,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 7 / 10,
              ),
              decoration: BoxDecoration(
                borderRadius: chatMessageModelRecord.id > 1
                    ? chatMessageModelRecord.id == 2
                        ? BorderRadius.only(
                            topRight: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                            topLeft: Radius.circular(3.0),
                            bottomLeft: Radius.circular(15.0),
                          )
                        : BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                            topLeft: Radius.circular(3.0),
                          )
                    : BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(3.0),
                        topRight: Radius.circular(15.0),
                      ),
                color: chatMessageModelRecord.id > 1
                    ? Colors.grey[200]
                    : Colors.yellow[200],
              ),
              padding: EdgeInsets.symmetric(
                vertical: 7,
                horizontal: 16,
              ),
              child: Text(
                "${chatMessageModelRecord.message}",
                style: GoogleFonts.gowunDodum(
                  textStyle: (TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[900],
                  )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
