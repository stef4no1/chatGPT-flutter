import 'package:http/http.dart' as http;
import 'dart:convert';

String apiKey = "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";

Future sendChatCompletionRequest(String message) async {
  String baseUrl = "https://api.openai.com/v1/chat/completions";
  Map<String, String> headers = {
    "Content-Type": "application/json; charset=UTF-8",
    "Authorization": "Bearer $apiKey"
  };

  var res = await http.post(Uri.parse(baseUrl),
      headers: headers,
      body: json.encode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": message}
        ]
      }));

  if (res.statusCode == 200) {
    final resultBody = utf8.decode(res.bodyBytes);
    final String result =
        jsonDecode(resultBody)["choices"][0]["message"]["content"];
    return result.trim();
  }
}
