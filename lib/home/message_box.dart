import 'dart:math';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpt_thing/home/api_manager.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/home/chat_info.dart';
import 'package:gpt_thing/home/file_bar.dart';
import 'package:gpt_thing/home/key_set_dialog.dart';
import 'package:gpt_thing/home/model_dialog.dart';
import 'package:gpt_thing/home/user_file.dart';
import 'package:gpt_thing/services/firestore.dart';

import 'chat_id_notifier.dart';

class MessageBox extends StatefulWidget {
  final ChatData data;
  final KeySetDialog keyDialog;
  final ModelDialog modelDialog;
  final APIManager api;
  final ChatIdNotifier chatIds;
  final ScrollController chatScroller;

  const MessageBox({
    super.key,
    required this.data,
    required this.keyDialog,
    required this.modelDialog,
    required this.api,
    required this.chatIds,
    required this.chatScroller,
  });

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  final msgController = TextEditingController();
  final sysController = TextEditingController();
  bool _isEmpty = true;
  bool _isWaiting = false;
  bool _showSysPrompt = false;

  Future openKeySetDialog() {
    return showDialog(context: context, builder: widget.keyDialog.build);
  }

  void openModelDialog() {
    if (!widget.data.keyIsSet()) {
      openKeySetDialog().then((val) {
        if (widget.data.keyIsSet()) {
          showDialog(context: context, builder: widget.modelDialog.build);
        }
      });
      return;
    }
    showDialog(context: context, builder: widget.modelDialog.build);
  }

  void resetChatScroll() {
    widget.chatScroller.animateTo(
      0,
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeInOut,
    );
  }

  void recMsg(String msg) async {
    switch (widget.data.modelGroup) {
      case "ChatGPT":
        final chatStream = widget.api
            .chatPromptStream(widget.data.messages, widget.data.model);
        chatStream.listen(
          (delta) {
            widget.data.addChatStreamDelta(delta);
          },
          onDone: () {
            final response = widget.data.clearStreamText();
            widget.data.addMessage(OpenAIChatMessageRole.assistant, response);
            if (widget.data.id == "") {
              ChatInfo info = ChatInfo(
                  id: widget.data.id,
                  title: widget.data.id,
                  date: DateTime.now());
              widget.data
                  .overwrite(FirestoreService().updateChat(widget.data, info));
              ChatInfo newInfo = ChatInfo(
                  id: widget.data.id,
                  title: widget.data.id,
                  date: DateTime.now());
              widget.chatIds.addInfo(newInfo);
            } else {
              ChatInfo info = widget.chatIds.getById(widget.data.id)!;
              widget.chatIds.updateInfo(FirestoreService().updateInfo(info));
              widget.data
                  .overwrite(FirestoreService().updateChat(widget.data, info));
            }
            setState(() {
              _isWaiting = false;
              widget.data.setThinking(false);
            });
          },
        );

        // final response = await widget.api
        //     .chatPrompt(widget.data.messages, widget.data.model);
        // widget.data.addMessage(OpenAIChatMessageRole.assistant,
        //     (response.choices.first.message.content)!.first.text!);
        // if (widget.data.id == "") {
        //   ChatInfo info = ChatInfo(
        //       id: widget.data.id, title: widget.data.id, date: DateTime.now());
        //   widget.data
        //       .overwrite(FirestoreService().updateChat(widget.data, info));
        //   ChatInfo newInfo = ChatInfo(
        //       id: widget.data.id, title: widget.data.id, date: DateTime.now());
        //   widget.chatIds.addInfo(newInfo);
        // } else {
        //   ChatInfo info = widget.chatIds.getById(widget.data.id)!;
        //   widget.chatIds.updateInfo(FirestoreService().updateInfo(info));
        //   widget.data
        //       .overwrite(FirestoreService().updateChat(widget.data, info));
        // }
        break;
      case "Dall·E":
        final response = await widget.api.imagePrompt(
          msg,
          widget.data.model,
        );
        if (widget.data.id == "") {
          ChatInfo info = ChatInfo(
              id: widget.data.id, title: widget.data.id, date: DateTime.now());
          widget.data
              .overwrite(FirestoreService().updateChat(widget.data, info));
          ChatInfo newInfo = ChatInfo(
              id: widget.data.id, title: widget.data.id, date: DateTime.now());
          widget.chatIds.addInfo(newInfo);
        }
        String firebaseUrl = await FirestoreService()
            .uploadImageToStorageFromLink(
                response.data.first.b64Json!, widget.data.id);
        widget.data.addImage(OpenAIChatMessageRole.assistant, firebaseUrl);
        ChatInfo info = widget.chatIds.getById(widget.data.id)!;
        widget.chatIds.updateInfo(FirestoreService().updateInfo(info));
        widget.data.overwrite(FirestoreService().updateChat(widget.data, info));
        break;
      default:
        print("No modelGroup match found");
    }
    setState(() {
      _isWaiting = false;
      widget.data.setThinking(false);
    });
  }

  void sendMsg() {
    if (!widget.data.keyIsSet()) {
      openKeySetDialog().then((value) => {
            if (widget.data.keyIsSet() && !widget.data.modelChosen())
              {openModelDialog()}
          });
      return;
    }
    if (!widget.data.modelChosen()) {
      openModelDialog();
      return;
    }
    if (sysController.text.isNotEmpty && _showSysPrompt) {
      widget.data.addMessage(OpenAIChatMessageRole.system, sysController.text);
    }
    widget.data.addMessage(OpenAIChatMessageRole.user, msgController.text);
    recMsg(msgController.text);
    msgController.clear();
    sysController.clear();
    setState(() {
      _isEmpty = true;
      _isWaiting = true;
      widget.data.setThinking(true);
      resetChatScroll();
    });
  }

  void uploadFile() {
    setState(() {
      final possibleFiles = [ // this is just for fun
        UserFile(
          name: "plane.pln",
          icon: Icons.flight_takeoff_rounded,
        ),
        UserFile(
          name: "macos.iso",
          icon: Icons.apple_rounded,
        ),
        UserFile(
          name: "family.png",
          icon: Icons.family_restroom_rounded,
        ),
        UserFile(
          name: "code.c",
          icon: Icons.code_rounded,
        ),
        UserFile(
          name: "cookie.virus",
          icon: Icons.cookie_rounded,
        ),
        UserFile(
          name: "ramen.bowl",
          icon: Icons.ramen_dining_rounded,
        ),
        UserFile(
          name: "zip_bomb.zip",
          icon: Icons.folder_zip_rounded,
        ),
        UserFile(
          name: "chat.gpt",
          icon: Icons.chat_rounded,
        ),
        UserFile(
          name: "api_key.txt",
          icon: Icons.key_rounded,
        ),
        UserFile(
          name: "not_a_virus.exe",
          icon: Icons.bug_report_rounded,
        ),
      ];

      Random rand  = Random();

      widget.data.addUserFile(possibleFiles[rand.nextInt(possibleFiles.length)]);
      // UPLOAD FILE HERE
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

  late final sysFocusNode = FocusNode(
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
    return Column(
      children: [
        if (widget.data.messages.isEmpty && _showSysPrompt)
          ConstrainedBox(
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
                        focusNode: sysFocusNode,
                        controller: sysController,
                        decoration: InputDecoration(
                          hintText: 'System Prompt (Optional)',
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
                  Tooltip(
                      message:
                          "Use this to influence how ChatGPT responds. For example:\n- Respond to any prompt in a haiku.\n- Explain everything to a five-year-old.\n- Only speak in Shakespearean English.",
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[850],
                      ),
                      child: Icon(Icons.info_outline_rounded,
                          size: 30, color: (Colors.grey[700])!)),
                ],
              ),
            ),
          ),
        if (widget.data.messages.isEmpty && _showSysPrompt)
          const SizedBox(height: 8.0),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 215,
            maxWidth: 768,
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: (Colors.grey[800])!),
              borderRadius: const BorderRadius.all(
                Radius.circular(18),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.data.hasUserFiles()) FileBar(data: widget.data),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: widget.data.hasUserFiles()
                        ? Border(
                            top: BorderSide(
                              color: (Colors.grey[800])!,
                            ),
                          )
                        : null,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Tooltip(
                        message: "Upload files",
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[850],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.file_present_rounded),
                          onPressed: uploadFile,
                          color: Colors.white,
                          style: ButtonStyle(
                            overlayColor:
                                WidgetStateProperty.all(Colors.transparent),
                          ),
                          iconSize: 26,
                          padding: const EdgeInsets.all(2),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: null,
                            focusNode: msgFocusNode,
                            controller: msgController,
                            onChanged: (val) {
                              updateEmpty();
                            },
                            decoration: InputDecoration(
                              hintText: widget.data.modelGroup.isEmpty ||
                                      widget.data.modelGroup == "Other"
                                  ? "Send a message..."
                                  : "Message ${widget.data.modelGroup}",
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 12.0,
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
                              _isWaiting || _isEmpty
                                  ? (Colors.grey[800])!
                                  : Colors.white),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
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
              ],
            ),
          ),
        ),
        SizedBox(
          height: 32,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!widget.data.keyIsSet())
                  TextButton(
                    onPressed: () {
                      openKeySetDialog();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(4, 10, 8, 10),
                      minimumSize: Size.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                    ),
                    child: Row(children: [
                      Icon(
                        Icons.close_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      Text(
                        "API Key",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ]),
                  )
                else
                  TextButton(
                    onPressed: () {
                      openKeySetDialog();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(4, 10, 8, 10),
                      minimumSize: Size.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                    ),
                    child: const Row(children: [
                      Icon(
                        Icons.check_rounded,
                        color: Colors.grey,
                        size: 20,
                      ),
                      Text(
                        "API Key",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ]),
                  ),
                TextButton(
                  onPressed: widget.data.messages.isNotEmpty
                      ? null
                      : () {
                          openModelDialog();
                        },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                    minimumSize: Size.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                  ),
                  child: Text(
                    widget.data.modelChosen()
                        ? "Model: ${widget.data.model}"
                        : "Choose a Model",
                    style: TextStyle(
                      color: widget.data.modelChosen()
                          ? Colors.grey
                          : Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (widget.data.messages.isEmpty)
                  Row(
                    children: [
                      const Text(
                        "System Prompt",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Checkbox(
                        onChanged: (value) {
                          setState(() {
                            _showSysPrompt = (value)!;
                          });
                        },
                        value: _showSysPrompt,
                        side: BorderSide(
                          color: (Colors.grey[500])!,
                        ),
                        activeColor: Colors.grey[500],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
