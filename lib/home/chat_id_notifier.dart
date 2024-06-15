import 'package:flutter/cupertino.dart';
import 'package:gpt_thing/home/chat_info.dart';

class ChatIdNotifier extends ChangeNotifier{
  List<ChatInfo> _ids = [];
  List<ChatInfo> get ids => _ids;

  ChatIdNotifier(List<ChatInfo> ids){
    this._ids = ids;
    sortByDate();
  }

  ChatInfo? getById(String id){
    for (ChatInfo info in _ids) {
      if (info.id == id) {
        return info;
      }
    }
    return null;
  }

  void sortByDate() {
    _ids.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  void setTitleById(String id, String title){
    ChatInfo info = getById(id)!;
    info.setTitle(title);
    sortByDate();
    notifyListeners();
  }

  void removeInfo(ChatInfo info){
    _ids.remove(info);
    sortByDate();
    notifyListeners();
  }

  void setInfos(List<ChatInfo> newIds){
    _ids = newIds;
    sortByDate();
    notifyListeners();
  }

  void addInfo(ChatInfo info){
    _ids.add(info);
    sortByDate();
    notifyListeners();
  }

  void updateInfo(ChatInfo info){
    _ids.remove(getById(info.id));
    _ids.add(info);
    sortByDate();
    notifyListeners();
  }

  int size(){
    return _ids.length;
  }

  ChatInfo get(int index) {
    return _ids[index];
  }
}