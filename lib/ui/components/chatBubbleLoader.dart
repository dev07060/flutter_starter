import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rive/rive.dart';

import '../../controllers/preference.dart';

class ChatBubbleLoader extends StatelessWidget {
  final ChatMessageModel chatMessageModelRecord;

  const ChatBubbleLoader({
    Key? key,
    required this.chatMessageModelRecord,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spinkit = SpinKitThreeBounce(
      size: 20.0,
      itemBuilder: (BuildContext context, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        );
      },
    );
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Row(
        // if message ID is not '2' generate user chat bubble otherwise ID is '1' generate bot chat bubble
        mainAxisAlignment: chatMessageModelRecord.id > 1
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 5,
            ),
            child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 2 / 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: chatMessageModelRecord.id > 1
                      ? BorderRadius.only(
                          bottomLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        )
                      : BorderRadius.only(
                          bottomLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0),
                          topLeft: Radius.circular(15.0),
                        ),
                  color: chatMessageModelRecord.id > 1
                      ? primaryColor
                      : darkblueColor,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: spinkit),
          ),
        ],
      ),
    );
  }
}
