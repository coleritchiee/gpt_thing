import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gpt_thing/home/api_manager.dart';
import 'package:gpt_thing/home/chat_message_data.dart';
import 'package:gpt_thing/home/model_group.dart';
import 'package:gpt_thing/services/firestore.dart';
import '../services/models.dart' as u;

class Model {
  late String id;
  ModelGroup group = ModelGroup.other;
  late bool preview;

  Model(this.id, List<ModelGroup> groups) {
    for (ModelGroup mg in groups) {
      if (id.startsWith(mg.prefix)) {
        group = mg;
        break;
      }
    }

    preview = id.endsWith("preview");
  }
}

class TokenUsageEntry {
  int input;
  int output;

  TokenUsageEntry({required this.input, required this.output});

  void addUsage(int input, int output) {
    this.input += input;
    this.output += output;
  }

  factory TokenUsageEntry.fromJson(Map<String, dynamic> json) {
    return TokenUsageEntry(
      input: json['input'] as int,
      output: json['output'] as int,
    );
  }

  Map<String, int> toJson() {
    return {
      'input': input,
      'output': output,
    };
  }
}

class ChatData extends ChangeNotifier {
  // included fields
  List<ChatMessageData> messages = [];
  String id = "";
  ModelGroup modelGroup = ModelGroup.other;
  Map<String, TokenUsageEntry> tokenUsage = <String, TokenUsageEntry>{};

  // excluded fields
  String apiKey = "";
  String organization = "";
  List<Model> models = <Model>[];
  final List<ModelGroup> groups = [
    ModelGroup.chatGPT,
    ModelGroup.dalle,
    ModelGroup.tts,
    ModelGroup.whisper,
    ModelGroup.embeddings,
    ModelGroup.other,
  ];
  String model = "";
  bool _thinking = false;
  String streamText = "";
  u.User user = GetIt.I<u.User>();

  ChatData();

  void overwrite(ChatData data) {
    id = data.id;
    messages = data.messages;
    model = data.model;
    modelGroup = data.modelGroup;
    tokenUsage = data.tokenUsage;
    _thinking = false;
    streamText = "";
    notifyListeners();
  }

  void setId(String id) {
    this.id = id;
    notifyListeners();
  }

  Future<bool> setKey(String key, String org) async {
    bool validated = true;
    OpenAI.apiKey = apiKey = key;
    OpenAI.organization = organization = org;
    try {
      addModels(await APIManager.getModels());
    } catch (e) {
      resetKey();
      validated = false;
    }
    if (user.settings.saveAPIKey) {
      user.setKey(apiKey, organization);
    }
    notifyListeners();
    return validated;
  }

  void resetKey() {
    apiKey = "";
    OpenAI.apiKey = "";
    organization = "";
    OpenAI.organization = "";
    notifyListeners();
  }

  void addModels(List<String> ids) {
    models.clear();
    for (String id in ids) {
      models.add(Model(id, groups));
    }
    notifyListeners();
  }

  void setModel(Model? model) {
    if (model != null) {
      this.model = model.id;
      modelGroup = model.group;
      notifyListeners();
    }
  }

  Model? getModelById(String id) {
    for (Model m in models) {
      if (m.id == id) {
        return m;
      }
    }
    return null;
  }

  void applyDefaultModel([BuildContext? context]) {
    if (messages.isNotEmpty) {
      return; // don't change model if there's a conversation
    }
    if (keyIsSet() && user.settings.defaultModel.isNotEmpty) {
      Model? defaultModel = getModelById(user.settings.defaultModel);
      if (defaultModel == null && context != null) {
        String oldModel = user.settings.defaultModel;
        // reset default model and update it in the database
        user.updateSettings(
            user.settings.copyWith(defaultModel: "", defaultModelGroup: ""));
        FirestoreService().updateUser(user);
        // tell the user the default model is gone
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Default Model Error"),
                content: Text(
                    "Looks like your default model ($oldModel) isn't supported anymore. Choose a new one in settings."),
                actions: [
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
                insetPadding: const EdgeInsets.all(24),
              );
            });
      }
      setModel(defaultModel);
    }
  }

  bool keyIsSet() {
    return apiKey.isNotEmpty;
  }

  bool modelChosen() {
    return model.isNotEmpty;
  }

  void setThinking(bool t) {
    _thinking = t;
    notifyListeners();
  }

  bool isThinking() {
    return _thinking;
  }

  void addChatStreamDelta(String buffer) {
    streamText += buffer;
    notifyListeners();
  }

  String clearStreamText() {
    final temp = streamText;
    streamText = "";
    notifyListeners();
    return temp;
  }

  void addMessage(OpenAIChatMessageRole role, String text,
      {String? model, int? inputTokens, int? outputTokens}) {
    messages.add(ChatMessageData(
      role: role,
      timestamp: DateTime.now(),
      text: text,
      model: model,
      inputTokens: inputTokens,
      outputTokens: outputTokens,
    ));
    notifyListeners();
  }

  void addImage(OpenAIChatMessageRole role, String url,
      {String? model, int? inputTokens, int? outputTokens}) {
    messages.add(ChatMessageData(
      role: role,
      imageUrl: url,
      timestamp: DateTime.now(),
      model: model,
      inputTokens: inputTokens,
      outputTokens: outputTokens,
    ));
    notifyListeners();
  }

  void addTokenUsage(String model, int input, int output) {
    if (tokenUsage.containsKey(model)) {
      tokenUsage[model]!.addUsage(input, output);
    } else {
      tokenUsage[model] = TokenUsageEntry(input: input, output: output);
    }
    notifyListeners();
  }

  bool hasTokenUsage() {
    return tokenUsage.isNotEmpty;
  }

  String firstUserMessage(int limit) {
    String message = "Untitled Chat"; // failsafe instead of id (security risk)
    for (ChatMessageData msg in messages) {
      if (msg.role == OpenAIChatMessageRole.user) {
        if (msg.text != null) {
          message = msg.text!;
        }
      }
    }
    if (message.length > limit) {
      message = "${message.substring(0, limit)}...";
    }
    return message;
  }

  factory ChatData.fromJson(Map<String, dynamic> json) {
    final stuff = ChatData()
      ..id = json['id'] as String
      ..modelGroup = ModelGroup.getByName(json['modelGroup'] as String)
      ..tokenUsage = (json['tokenUsage'] as Map<String, dynamic>)
          .map<String, TokenUsageEntry>((model, usage) =>
              MapEntry<String, TokenUsageEntry>(model,
                  TokenUsageEntry.fromJson(usage as Map<String, dynamic>)))
      ..messages = (json['messages'] as List)
          .map((e) => ChatMessageData.fromJson(e as Map<String, dynamic>))
          .toList();
    return stuff;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelGroup': modelGroup.name,
      'tokenUsage': tokenUsage.map((model, usage) =>
          MapEntry<String, Map<String, int>>(model, usage.toJson())),
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }

  static String roleToString(OpenAIChatMessageRole role) {
    switch (role) {
      case OpenAIChatMessageRole.user:
        return "User";
      case OpenAIChatMessageRole.assistant:
        return "ChatGPT";
      case OpenAIChatMessageRole.system:
        return "System";
      default:
        return "Unknown";
    }
  }
}
