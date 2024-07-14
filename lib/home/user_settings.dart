import 'package:json_annotation/json_annotation.dart';

part 'user_settings.g.dart';

final streamValues = [
  "word",
  "line",
  "off",
];

@JsonSerializable(explicitToJson: true)
class UserSettings {
  static final UserSettings DEFAULT = UserSettings(
      streamResponse: "word",
      generateTitles: false,
      defaultModel: "",
      defaultModelGroup: "",
      showSystemPrompt: false,
      saveAPIKey: false);

  String streamResponse;
  bool generateTitles;
  String defaultModel;
  String defaultModelGroup;
  bool showSystemPrompt;
  bool saveAPIKey;

  UserSettings(
      {required this.streamResponse,
      required this.generateTitles,
      required this.defaultModel,
      required this.defaultModelGroup,
      required this.showSystemPrompt,
      required this.saveAPIKey});

  UserSettings copyWith(
      {String? streamResponse,
      bool? generateTitles,
      String? defaultModel,
      String? defaultModelGroup,
      bool? showSystemPrompt,
      bool? saveAPIKey}) {
    return UserSettings(
      streamResponse: streamResponse ?? this.streamResponse,
      generateTitles: generateTitles ?? this.generateTitles,
      defaultModel: defaultModel ?? this.defaultModel,
      defaultModelGroup: defaultModelGroup ?? this.defaultModelGroup,
      showSystemPrompt: showSystemPrompt ?? this.showSystemPrompt,
      saveAPIKey: saveAPIKey ?? this.saveAPIKey,
    );
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);
}
