import 'package:dart_openai/dart_openai.dart';
import 'package:gpt_thing/home/chat_data.dart';

class APIManager {
  Future<OpenAIChatCompletionModel> chatPrompt(
    List<ChatMessage> history,
    String model
  ) async {
    final List<OpenAIChatCompletionChoiceMessageModel> messages = [];

    for (int i = 0; i < history.length; i++) {
      messages.add(OpenAIChatCompletionChoiceMessageModel(
        role: history[i].role,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            history[i].message,
          ),
        ]
      ));
    }

    return await OpenAI.instance.chat.create(
      model: model,
      messages: messages,
      maxTokens: 1024,
    );
  }

  Future<List<String>> getModels() async {
    final result = await OpenAI.instance.model.list();
    result.sort((a, b) => a.id.compareTo(b.id));
    final models = <String>[];
    for (int i = 0; i < result.length; i++) {
      models.add(result[i].id);
    }
    return models;
  }
}