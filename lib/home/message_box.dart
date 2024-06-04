import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpt_thing/home/api_manager.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/home/key_set_dialog.dart';

class MessageBox extends StatefulWidget {
  final ChatData data;
  final KeySetDialog keyDialog;
  final APIManager api;

  const MessageBox({super.key, required this.data, required this.keyDialog, required this.api});

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  var msgController = TextEditingController();
  bool _isEmpty = true;
  bool _isWaiting = false;

  void recMsg(String msg) async {
    final response = await widget.api.chatPrompt(widget.data.messages);
    widget.data.addMessage(ChatRole.assistant, (response.choices.first.message.content)!.first.text!);
    setState(() {
      _isWaiting = false;
    });
  }

  void sendMsg() {
    if (!widget.data.keyIsSet()) {
      showDialog(context: context, builder: widget.keyDialog.build);
      return;
    }
    widget.data.addMessage(ChatRole.user, msgController.text);
    recMsg(msgController.text);
    msgController.clear();
    setState(() {
      _isEmpty = true;
      _isWaiting = true;
    });
  }

  late final msgFocusNode = FocusNode(
    onKeyEvent: (FocusNode node, KeyEvent event) {
      if (!HardwareKeyboard.instance.isShiftPressed &&
          event.logicalKey.keyLabel == 'Enter') {
        if (event is KeyDownEvent && !_isWaiting && !_isEmpty) {
          sendMsg();
        }
        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    },
  );

  void updateEmpty() {
    setState(() {
      _isEmpty = msgController.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 215,
        maxWidth: 768,
      ),
      child: Container(
        padding: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border.all(color: (Colors.grey[800])!),
          borderRadius: const BorderRadius.all(
            Radius.circular(18),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: null,
                focusNode: msgFocusNode,
                controller: msgController,
                onChanged: (val) {updateEmpty();},
                decoration: InputDecoration(
                  hintText: 'Message ChatGPT',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                  ),
                  contentPadding: const EdgeInsets.only(
                    left: 22.0,
                    right: 8.0,
                    top: 12.0,
                    bottom: 12.0,
                  ),
                  border: InputBorder.none,
                )),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_upward_rounded),
              onPressed: _isWaiting || _isEmpty ? null : sendMsg,
              color: Colors.grey[900],
              disabledColor: Colors.grey[900],
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  _isWaiting || _isEmpty ? (Colors.grey[800])! : Colors.white
                ),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
              ),
              iconSize: 26,
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
