import 'package:dart_openai/dart_openai.dart';
import 'package:gpt_thing/home/chat_data.dart';

class APIManager {
  Future<OpenAIChatCompletionModel> chatPrompt(List<ChatMessage> history) async {
    final List<OpenAIChatCompletionChoiceMessageModel> messages = [];

    for (int i = 0; i < history.length; i++) {
      messages.add(OpenAIChatCompletionChoiceMessageModel(
        role: history[i].role == ChatRole.user
          ? OpenAIChatMessageRole.user
          : history[i].role == ChatRole.system
            ? OpenAIChatMessageRole.system
            : OpenAIChatMessageRole.assistant,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            history[i].message,
          ),
        ]
      ));
    }

    return await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: messages,
      maxTokens: 100,
    );
  }
}