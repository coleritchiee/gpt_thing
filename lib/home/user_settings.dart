class UserSettings {
  bool showSystemPrompt;

  UserSettings({this.showSystemPrompt = false});

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      showSystemPrompt: json['showSystemPrompt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
     'showSystemPrompt': showSystemPrompt,
    };
  }
}
