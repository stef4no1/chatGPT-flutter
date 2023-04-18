import "package:chatgptcurso/services/open_ai_services.dart";
import "package:chatgptcurso/widgets/message_bubble.dart";
import "package:flutter/material.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    final messages = [
        {"message":"Hola, bienvenido","isMe": false},
        {"message": "Hola", "isMe":true}
    ];

  TextEditingController _textController = TextEditingController();

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("ChatGPT"),
        ),
        body: Column(children: [
            Expanded(child: ListView.builder(
                shrinkWrap: true,
                itemCount: messages.length,
                itemBuilder: ((context,index){
                    return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: MessageBubble(
                            message: messages[index]["message"].toString(), 
                            isMe: messages[index]["isMe"].toString() == "false" ? false : true),
                    );
                }))),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                  child: Row(
                    children: [
                      Expanded(child: TextField(controller: _textController,)),
                      IconButton(
                        onPressed: () async {
                          final userMessage = _textController.text;
                          messages.add({"message": _textController.text, "isMe": true});

                          _textController.text = "";
                          setState(() {});
                          final res = await sendChatCompletionRequest(userMessage);
                          messages.add({"message": res, "isMe": false});
                      }, 
                      icon: Icon(Icons.send))
                    ],
                  ),
                )
        ]),
    );
  }
}
