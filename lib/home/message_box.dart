import 'dart:async';
import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gpt_thing/home/api_manager.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/home/chat_info.dart';
import 'package:gpt_thing/home/key_set_dialog.dart';
import 'package:gpt_thing/home/model_dialog.dart';
import 'package:gpt_thing/home/model_group.dart';
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
      case ModelGroup.chatGPT:
        final chatStream = widget.api
            .chatPromptStream(widget.data.messages, widget.data.model);
        final streamCompleter = Completer<bool>();
        int inputTokens = 0;
        int outputTokens = 0;
        chatStream.listen(
          (delta) {
            if (delta.usage != null) {
              inputTokens = delta.usage!.promptTokens;
              outputTokens = delta.usage!.completionTokens;
            }
            if (delta.haveChoices) {
              widget.data.addChatStreamDelta(delta);
            }
          },
          onDone: () {
            streamCompleter.complete(true);
          },
        );
        await streamCompleter.future;

        final response = widget.data.clearStreamText();
        widget.data.addTokenUsage(inputTokens, outputTokens);
        widget.data.addMessage(OpenAIChatMessageRole.assistant, response);
        if (widget.data.id == "") {
          ChatInfo info = ChatInfo(
              id: widget.data.id,
              title: widget.data.firstUserMessage(),
              date: DateTime.now());
          widget.data
              .overwrite(FirestoreService().updateChat(widget.data, info));
          widget.chatIds.addInfo(info);
        } else {
          ChatInfo info = widget.chatIds.getById(widget.data.id)!;
          widget.chatIds.updateInfo(FirestoreService().updateInfo(info));
          widget.data
              .overwrite(FirestoreService().updateChat(widget.data, info));
        }

        // final response = await widget.api
        //     .chatPrompt(widget.data.messages, widget.data.model);
        // widget.data.addTokenUsage(response.usage.promptTokens, response.usage.completionTokens);
        // widget.data.addMessage(OpenAIChatMessageRole.assistant,
        //     (response.choices.first.message.content)!.first.text!);
        // if (widget.data.id == "") {
        //   ChatInfo info = ChatInfo(
        //       id: widget.data.id, title: widget.data.id, date: DateTime.now());
        //   widget.data
        //       .overwrite(FirestoreService().updateChat(widget.data, info));
        //   widget.chatIds.addInfo(info);
        // } else {
        //   ChatInfo info = widget.chatIds.getById(widget.data.id)!;
        //   widget.chatIds.updateInfo(FirestoreService().updateInfo(info));
        //   widget.data
        //       .overwrite(FirestoreService().updateChat(widget.data, info));
        // }
        break;
      case ModelGroup.dalle:
        final response = await widget.api.imagePrompt(
          msg,
          widget.data.model,
        );
        if (widget.data.id == "") {
          ChatInfo info = ChatInfo(
              id: widget.data.id,
              title: widget.data.firstUserMessage(),
              date: DateTime.now());
          widget.data
              .overwrite(FirestoreService().updateChat(widget.data, info));
          widget.chatIds.addInfo(info);
        }
        String firebaseUrl = await FirestoreService()
            .uploadImageToStorageFromLink(
                response.data.first.b64Json!, widget.data.id);
        // Put the image in the cache now, so you don't have to download it again later
        // Also make sure to wait until it's done, otherwise it will be downloaded again
        await DefaultCacheManager().putFile(
            firebaseUrl, base64Decode(response.data.first.b64Json!),
            fileExtension: "png");
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
    if (sysController.text.isNotEmpty) {
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
        if (widget.data.messages.isEmpty)
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
          ),
        if (widget.data.messages.isEmpty) const SizedBox(height: 8.0),
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
                      focusNode: msgFocusNode,
                      controller: msgController,
                      onChanged: (val) {
                        updateEmpty();
                      },
                      decoration: InputDecoration(
                        hintText: widget.data.modelGroup == ModelGroup.other
                            ? "Send a message..."
                            : "Message ${widget.data.modelGroup.name}",
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
                        _isWaiting || _isEmpty
                            ? (Colors.grey[800])!
                            : Colors.white),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  iconSize: 26,
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 32,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  // api key button
                  onPressed: () {
                    openKeySetDialog();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(
                      left: 4,
                      right: 8,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (!widget.data.keyIsSet())
                          Icon(
                            Icons.close_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          )
                        else
                          const Icon(
                            Icons.check_rounded,
                            color: Colors.grey,
                            size: 20,
                          ),
                        Text(
                          "API Key",
                          style: TextStyle(
                            color: widget.data.keyIsSet()
                                ? Colors.grey
                                : Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ]),
                ),
                TextButton(
                  // api key button
                  onPressed: widget.data.messages.isNotEmpty
                      ? null
                      : () {
                          openModelDialog();
                        },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
