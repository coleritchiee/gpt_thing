import 'package:json_annotation/json_annotation.dart';

part 'user_settings.g.dart';

final streamValues = [
  "full",
  "paragraph",
  "none",
];

@JsonSerializable(explicitToJson: true)
class UserSettings {
  static final UserSettings DEFAULT = UserSettings(
      streamResponse: "full",
      generateTitles: false,
      showSystemPrompt: false,
      saveAPIToken: false);

  String streamResponse;
  bool generateTitles;
  bool showSystemPrompt;
  bool saveAPIToken;

  UserSettings(
      {required this.streamResponse,
      required this.generateTitles,
      required this.showSystemPrompt,
      required this.saveAPIToken});

  UserSettings copyWith(
      {String? streamResponse,
      bool? generateTitles,
      bool? showSystemPrompt,
      bool? saveAPIToken}) {
    return UserSettings(
      streamResponse: streamResponse ?? this.streamResponse,
      generateTitles: generateTitles ?? this.generateTitles,
      showSystemPrompt: showSystemPrompt ?? this.showSystemPrompt,
      saveAPIToken: saveAPIToken ?? this.saveAPIToken,
    );
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);
}
