import 'package:get_it/get_it.dart';
import 'package:gpt_thing/home/api_manager.dart';
import 'package:gpt_thing/home/chat_data.dart';

class SingletonManager {
  static void setupSingletons() {
    GetIt.I.registerSingleton<ChatData>(ChatData());
    GetIt.I.registerSingleton<APIManager>(APIManager());
  }
}
