import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_starter/models/models.dart';
import 'package:flutter_starter/ui/components/components.dart';

final ScrollController _controller = new ScrollController();

final StreamController<ChatMessageModel> _chatMessagesStreamController =
    StreamController<ChatMessageModel>.broadcast();
final Stream<ChatMessageModel> _chatMessagesStream =
    _chatMessagesStreamController.stream;

void maxScrolling() {
  final position = _controller.position.maxScrollExtent;
  _controller.animateTo(
    position + 300.0,
    duration: Duration(milliseconds: 700),
    curve: Curves.easeOut,
  );
}

// void sendMessage(String s) async {
//   s = s.trim();

//   bubbleGenerate(s, 2, "");
// }

void bubbleGenerate(String _message, int _id, String _dist) {
  debugPrint(
      'Adding a ChatMessageModel with the message $_message and $_dist to the Stream');
  ChatMessageModel chatMessageModelRecord =
      ChatMessageModel(message: _message, id: _id, dist: _dist, bot: '');
  maxScrolling();

  // print( "is: ${_message.split('\n')[1]}, ${_message.split('\n')[2]}");

  return _chatMessagesStreamController.add(
    chatMessageModelRecord,
  );
}

class MessagesStream extends StatefulWidget {
  @override
  _MessagesStreamState createState() => _MessagesStreamState();
}

class _MessagesStreamState extends State<MessagesStream> {
  final List<ChatMessageModel> _allMessagesContainedInTheStream = [];

  @override
  void initState() {
    _chatMessagesStream.listen((streamedMessages) {
      // _allMessagesContainedInTheStream.clear();
      debugPrint('Value from controller: $streamedMessages');
      _allMessagesContainedInTheStream.add(streamedMessages);
    });
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChatMessageModel>(
      stream: _chatMessagesStream,
      builder: (context, snapshot) {
        return Expanded(
          child: ListView.builder(
            controller: _controller,
            // reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            itemCount: _allMessagesContainedInTheStream.length,
            itemBuilder: (BuildContext context, int index) {
              if (snapshot.hasData) {
                return UserChatBubble(
                  chatMessageModelRecord:
                      _allMessagesContainedInTheStream[index],
                );
                // }
              } else {
                print(snapshot.connectionState);
                return Container();
              }
            },
          ),
        );
      },
    );
  }
}
