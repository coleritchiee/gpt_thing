class ModelGroup {
  static const ModelGroup chatGPT = ModelGroup(
    supported: true,
    name: "ChatGPT",
    prefix: "gpt",
    description: "Natural language processing",
    systemPrompt: true,
  );
  static const ModelGroup dalle = ModelGroup(
    supported: true,
    name: "Dall·E",
    prefix: "dall-e",
    description: "Generate images",
    systemPrompt: false,
  );
  static const ModelGroup tts = ModelGroup(
    supported: false,
    name: "TTS",
    prefix: "tts",
    description: "Convert text to spoken audio",
    systemPrompt: false,
  );
  static const ModelGroup whisper = ModelGroup(
    supported: false,
    name: "Whisper",
    prefix: "whisper",
    description: "Convert audio to text",
    systemPrompt: false,
  );
  static const ModelGroup embeddings = ModelGroup(
    supported: false,
    name: "Embeddings",
    prefix: "text-embedding",
    description: "Convert text to a numerical form",
    systemPrompt: false,
  );
  static const ModelGroup other = ModelGroup(
    supported: false,
    name: "Other",
    prefix: "",
    description: "Specialized Models",
    systemPrompt: false,
  );

  final bool supported;
  final String name;
  final String prefix;
  final String description;
  final bool systemPrompt;

  const ModelGroup(
      {required this.supported,
      required this.name,
      required this.prefix,
      required this.description,
      required this.systemPrompt});

  bool isSupported() {
    return supported;
  }

  static ModelGroup getByName(String name) {
    switch (name) {
      case "ChatGPT":
        return ModelGroup.chatGPT;
      case "Dall·E":
        return ModelGroup.dalle;
      case "TTS":
        return ModelGroup.tts;
      case "Whisper":
        return ModelGroup.whisper;
      case "Embeddings":
        return ModelGroup.embeddings;
      default:
        return ModelGroup.other;
    }
  }
}
