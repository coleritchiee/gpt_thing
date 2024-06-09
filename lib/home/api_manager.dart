import 'package:dart_openai/dart_openai.dart';

class APIManager {
  Future<OpenAIChatCompletionModel> chatPrompt(
    List<OpenAIChatCompletionChoiceMessageModel> messages) async {
    return await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: messages,
      maxTokens: 100,
    );
  }
}