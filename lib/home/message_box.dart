import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessageBox extends StatefulWidget {
  const MessageBox({super.key});

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  var msgController = TextEditingController();
  bool _isEmpty = true;

  void sendMsg() {
    print(msgController.text); // this is where you call the api
    msgController.clear();
    updateEmpty();
  }

  late final msgFocusNode = FocusNode(
    onKeyEvent: (FocusNode node, KeyEvent event) {
      if (!HardwareKeyboard.instance.isShiftPressed &&
          event.logicalKey.keyLabel == 'Enter') {
        if (event is KeyDownEvent && !_isEmpty) {
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
              onPressed: _isEmpty ? null : sendMsg,
              color: Colors.grey[900],
              disabledColor: Colors.grey[900],
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  _isEmpty ? (Colors.grey[800])! : Colors.white
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
