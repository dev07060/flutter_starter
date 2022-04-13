import 'package:flutter/material.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/models/models.dart';

class UserChatBubble extends StatelessWidget {
  final ChatMessageModel chatMessageModelRecord;
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
        mainAxisAlignment: chatMessageModelRecord.id != 2
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 5,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 7 / 10,
              ),
              decoration: BoxDecoration(
                borderRadius: chatMessageModelRecord.id != 2
                    ? BorderRadius.only(
                        bottomLeft: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0),
                        topLeft: Radius.circular(15.0),
                      )
                    : BorderRadius.only(
                        bottomLeft: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                color: chatMessageModelRecord.id != 2
                    ? darkblueColor
                    : primaryColor,
              ),
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 20,
              ),
              child: Text(
                "${chatMessageModelRecord.message}",
                style: TextStyle(
                  fontSize: 15,
                  // fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
