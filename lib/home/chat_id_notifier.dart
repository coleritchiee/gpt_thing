import 'package:flutter/cupertino.dart';

class ChatIdNotifier extends ChangeNotifier{
  List<String> _ids = [];
  List<String> get ids => _ids;

  ChatIdNotifier(List<String> ids){
    this._ids = ids;
  }

  void setIds(List<String> newIds){
    _ids = newIds;
    notifyListeners();
  }

  void addId(String id){
    _ids.add(id);
    notifyListeners();
  }

  int size(){
    return _ids.length;
  }

  String get(int index) {
    return _ids[index];
  }
}