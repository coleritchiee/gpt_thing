import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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

class ChatData extends ChangeNotifier {
  // included fields
  List<OpenAIChatCompletionChoiceMessageModel> messages = [];
  String id = "";
  String model = "";
  ModelGroup modelGroup = ModelGroup.other;
  int inputTokens = 0;
  int outputTokens = 0;

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
  bool _thinking = false;
  String streamText = "";
  u.User user = GetIt.I<u.User>();

  ChatData();

  void overwrite(ChatData data) {
    id = data.id;
    messages = data.messages;
    model = data.model;
    modelGroup = data.modelGroup;
    inputTokens = data.inputTokens;
    outputTokens = data.outputTokens;
    _thinking = false;
    streamText = "";
    notifyListeners();
  }

  void setId(String id) {
    this.id = id;
    notifyListeners();
  }

  void setKey(String key, String org) {
    apiKey = key;
    OpenAI.apiKey = apiKey;
    organization = org;
    if (organization.isNotEmpty) {
      OpenAI.organization = organization;
    }
    notifyListeners();
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

  void applyDefaultModel(BuildContext context) {
    if (keyIsSet() && user.settings.defaultModel.isNotEmpty) {
      Model? defaultModel = getModelById(user.settings.defaultModel);
      if (defaultModel == null) {
        String oldModel = user.settings.defaultModel;
        // reset default model and update it in the database
        user.updateSettings(
            user.settings.copyWith(defaultModel: "", defaultModelGroup: ""));
        FirestoreService().updateUser(user);
        // tell the user the default model is gone
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: const Text("Default Model Error"),
            content: Text("Looks like your default model ($oldModel) isn't supported anymore. Choose a new one in settings."),
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

  void addMessage(OpenAIChatMessageRole role, String message) {
    messages.add(OpenAIChatCompletionChoiceMessageModel(
      role: role,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(message),
      ],
    ));
    notifyListeners();
  }

  void addTokenUsage(int input, int output) {
    inputTokens += input;
    outputTokens += output;
    notifyListeners();
  }

  bool hasTokenUsage() {
    return inputTokens > 0 || outputTokens > 0;
  }

  void addImage(OpenAIChatMessageRole role, String url) {
    messages.add(OpenAIChatCompletionChoiceMessageModel(
      role: role,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(url),
      ],
    ));
    notifyListeners();
  }

  String firstUserMessage(int limit) {
    String message = "Untitled Chat"; // failsafe instead of id (security risk)
    for (OpenAIChatCompletionChoiceMessageModel msg in messages) {
      if (msg.role == OpenAIChatMessageRole.user) {
        message = msg.content!.first.text!;
      }
    }
    if (message.length > limit) {
      message = "${message.substring(0, limit)}...";
    }
    return message;
  }

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData()
      ..id = json['id'] as String
      ..model = json['model'] as String
      ..modelGroup = ModelGroup.getByName(json['modelGroup'] as String)
      ..inputTokens = json['inputTokens'] as int
      ..outputTokens = json['outputTokens'] as int
      ..messages = (json['messages'] as List)
          .map((e) => OpenAIChatCompletionChoiceMessageModel.fromMap(
              e as Map<String, dynamic>))
          .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model': model,
      'modelGroup': modelGroup.name,
      'inputTokens': inputTokens,
      'outputTokens': outputTokens,
      'messages': messages.map((message) => message.toMap()).toList(),
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

  @override
  String toString() {
    // really just to be used for debugging
    // TODO: remove this eventually
    String retStr = "ChatData Contents:";
    for (int i = 0; i < messages.length; i++) {
      retStr += "\n ${messages[i].role}:\n  ${(messages[i].content)![0].text}";
    }
    return retStr;
  }
}
