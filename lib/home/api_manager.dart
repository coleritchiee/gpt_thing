import 'package:dart_openai/dart_openai.dart';

class APIManager {
  Future<OpenAIChatCompletionModel> chatPrompt(String prompt) async {
    final sysMsg = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "Respond to any prompt in a single sentence.",
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    final usrMsg = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          prompt
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    final messages = [
      sysMsg,
      usrMsg,
    ];

    return await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      responseFormat: {"type": "text"},
      messages: messages,
      maxTokens: 100,
    );
  }
}