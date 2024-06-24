import 'package:firebase_auth/firebase_auth.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_settings.g.dart';

@JsonSerializable(explicitToJson: true)
class UserSettings {
  static final UserSettings DEFAULT = UserSettings(streamResponse: false, generateTitles: false, showSystemPrompt: false);

  bool streamResponse;
  bool generateTitles;
  bool showSystemPrompt;

  UserSettings({required this.streamResponse, required this.generateTitles, required this.showSystemPrompt});

  factory UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);
}
