import 'dart:async';
import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:gpt_thing/home/api_manager.dart';
import 'package:gpt_thing/home/chat_data.dart';
import 'package:gpt_thing/home/chat_info.dart';
import 'package:gpt_thing/home/chat_message_data.dart';
import 'package:gpt_thing/home/key_set_dialog.dart';
import 'package:gpt_thing/home/model_dialog.dart';
import 'package:gpt_thing/home/model_group.dart';
import 'package:gpt_thing/services/firestore.dart';
import '../services/models.dart' as u;

import 'chat_id_notifier.dart';

class MessageBox extends StatefulWidget {
  final ChatData data;
  final ChatIdNotifier chatIds;
  final ScrollController chatScroller;

  final u.User user = GetIt.I<u.User>();

  MessageBox({
    super.key,
    required this.data,
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

  Future<bool> openKeySetDialog() async {
    bool? keySet = await showDialog(
        context: context, builder: KeySetDialog(widget.data).build);
    return keySet == true;
  }

  Future<bool> openModelDialog() async {
    if (!widget.data.keyIsSet()) {
      if (!await openKeySetDialog()) return false;
    }
    Model? newModel;
    if (mounted) {
      newModel = await showDialog(
          context: context, builder: ModelDialog(widget.data).build);
      widget.data.setModel(newModel);
    }
    return newModel != null;
  }

  void resetChatScroll() {
    widget.chatScroller.animateTo(
      0,
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeInOut,
    );
  }

  String getStreamDeltaString(OpenAIStreamChatCompletionModel delta) {
    if (delta.choices.first.delta.content != null) {
      if (delta.choices.first.delta.content!.first != null) {
        if (delta.choices.first.delta.content!.first!.text != null) {
          // yes this is ugly but you have to check
          return delta.choices.first.delta.content!.first!.text!;
        }
      }
    }
    return "";
  }

  Future<void> generateChatTitle() async {
    ChatInfo info = widget.chatIds.getById(widget.data.id)!;
    final title = await APIManager.getChatTitle(
        ChatMessageData.convertForAPI(widget.data.messages));
    info.title = title.choices.first.message.content!.first.text!;
    widget.chatIds.updateInfo(FirestoreService().updateInfo(info));
    widget.data.overwrite(FirestoreService().updateChat(widget.data, info));
    // replace this with adding tokens to the user profile so they can keep track,
    // otherwise the models between the title generation and the conversation can differ
    // and it will be an inaccurate count
    // widget.data.addTokenUsage(title.usage.promptTokens, title.usage.completionTokens);
  }

  void recMsg(String msg, bool firstMsg, String model) async {
    switch (widget.data.modelGroup) {
      case ModelGroup.chatGPT:
        late String message;
        late int inputTokens;
        late int outputTokens;
        // api call and text streaming (setting dependent)
        switch (widget.user.settings.streamResponse) {
          case "word":
            final chatStream = APIManager.chatPromptStream(
                ChatMessageData.convertForAPI(widget.data.messages),
                widget.data.model);
            final streamCompleter = Completer<bool>();
            chatStream.listen(
              (delta) {
                if (delta.usage != null) {
                  inputTokens = delta.usage!.promptTokens;
                  outputTokens = delta.usage!.completionTokens;
                }
                if (delta.haveChoices) {
                  widget.data.addChatStreamDelta(getStreamDeltaString(delta));
                }
              },
              onDone: () {
                streamCompleter.complete(true);
              },
            );
            await streamCompleter.future;
            message = widget.data.clearStreamText();
            break;
          case "line":
            final chatStream = APIManager.chatPromptStream(
                ChatMessageData.convertForAPI(widget.data.messages),
                widget.data.model);
            final streamCompleter = Completer<bool>();
            String buffer = "";
            chatStream.listen(
              (delta) {
                if (delta.usage != null) {
                  inputTokens = delta.usage!.promptTokens;
                  outputTokens = delta.usage!.completionTokens;
                }
                if (delta.haveChoices) {
                  buffer += getStreamDeltaString(delta);
                  if (buffer.contains("\n")) {
                    widget.data.addChatStreamDelta(buffer);
                    buffer = "";
                  }
                }
              },
              onDone: () {
                streamCompleter.complete(true);
              },
            );
            await streamCompleter.future;

            widget.data.addChatStreamDelta(buffer);
            buffer = "";
            message = widget.data.clearStreamText();
            break;
          case "off":
            final response = await APIManager.chatPrompt(
                ChatMessageData.convertForAPI(widget.data.messages),
                widget.data.model);
            message = (response.choices.first.message.content)!.first.text!;
            inputTokens = response.usage.promptTokens;
            outputTokens = response.usage.completionTokens;
            break;
          default:
            print("invalid streamResponse setting");
        }

        // add the stuff to the database
        widget.data.addTokenUsage(model, inputTokens, outputTokens);
        widget.data.addMessage(OpenAIChatMessageRole.assistant, message,
            model: model, inputTokens: inputTokens, outputTokens: outputTokens);
        if (widget.data.id == "") {
          ChatInfo info = ChatInfo(
              id: widget.data.id,
              title: widget.data.firstUserMessage(64),
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

        // generate the title if the setting is on
        if (widget.user.settings.generateTitles && firstMsg) {
          await generateChatTitle();
        }
        break;
      case ModelGroup.dalle:
        final response = await APIManager.imagePrompt(
          msg,
          widget.data.model,
        );
        if (widget.data.id == "") {
          ChatInfo info = ChatInfo(
              id: widget.data.id,
              title: widget.data.firstUserMessage(64),
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
        widget.data.addImage(OpenAIChatMessageRole.assistant, firebaseUrl,
            model: model);
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

  void sendMsg() async {
    if (!widget.data.keyIsSet()) {
      if (!await openKeySetDialog()) return;
    }
    if (!widget.data.modelChosen()) {
      openModelDialog();
      return;
    }
    bool firstMessage = widget.data.messages.isEmpty;
    if (sysController.text.isNotEmpty) {
      widget.data.addMessage(OpenAIChatMessageRole.system, sysController.text);
    }
    widget.data.addMessage(OpenAIChatMessageRole.user, msgController.text);
    recMsg(msgController.text, firstMessage, widget.data.model);
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
        if (widget.data.messages.isEmpty &&
            widget.user.settings.showSystemPrompt && widget.data.modelGroup.systemPrompt)
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
        if (widget.data.messages.isEmpty &&
            widget.user.settings.showSystemPrompt)
          const SizedBox(height: 8.0),
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
