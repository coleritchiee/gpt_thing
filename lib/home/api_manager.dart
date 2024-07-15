import 'package:dart_openai/dart_openai.dart';

class APIManager {
  static Future<OpenAIChatCompletionModel> chatPrompt(
      List<OpenAIChatCompletionChoiceMessageModel> messages,
      String model) async {
    return await OpenAI.instance.chat.create(
      model: model,
      messages: messages,
    );
  }
  
  static Future<OpenAIChatCompletionModel> getChatTitle(List<OpenAIChatCompletionChoiceMessageModel> messages) async {
    final promptMsg = <OpenAIChatCompletionChoiceMessageModel>[];
    // clone it to avoid messing with the actual chat
    promptMsg.addAll(messages);
    // remove system prompt to avoid conflicting instructions
    for (int i = 0; i < promptMsg.length; i++) {
      if (promptMsg[i].role == OpenAIChatMessageRole.system) {
        promptMsg.removeAt(i);
        i--;
      }
    }
    // add our own system prompt to generate titles
    promptMsg.insert(0, OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.system,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "You are an assistant that generates summarizing titles for conversations. Respond in ABSOLUTELY NO MORE THAN 30 CHARACTERS, formatted with PROPER TITLE CAPITALIZATION and WITHOUT QUOTATIONS. The following messages are the context of the conversation."
        )
      ]
    ));
    return await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: promptMsg,
    );
  }

  static Stream<OpenAIStreamChatCompletionModel> chatPromptStream(
      List<OpenAIChatCompletionChoiceMessageModel> messages, String model) {
    return OpenAI.instance.chat.createStream(
        model: model,
        messages: messages,
        streamOptions: {
          "include_usage": true,
        });
  }

  static Future<OpenAIImageModel> imagePrompt(String prompt, String model) async {
    return await OpenAI.instance.image.create(
      model: model,
      prompt: prompt,
      n: 1,
      size: OpenAIImageSize
          .size1024, // the only size supported by both dall-e 2 and 3
      responseFormat: OpenAIImageResponseFormat.b64Json,
    );
  }

  static Future<List<String>> getModels() async {
    final result = await OpenAI.instance.model.list();
    result.sort((a, b) => a.id.compareTo(b.id));
    final models = <String>[];
    for (int i = 0; i < result.length; i++) {
      models.add(result[i].id);
    }
    return models;
  }
}
