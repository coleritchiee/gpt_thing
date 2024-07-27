import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile(this.title, this.description, this.currentValue, this.onChanged,
      {super.key,
      this.defaultValue,
      this.values,
      this.buttonIcon,
      this.buttonText,
      this.note,
      this.noteColor});

  final String title;
  final String description;
  final dynamic currentValue;
  final Function(dynamic) onChanged;
  final dynamic defaultValue;
  final List<dynamic>? values;
  final Icon? buttonIcon;
  final String? buttonText;
  final String? note;
  final Color? noteColor;

  @override
  Widget build(BuildContext context) {
    List<Widget> trail = [];
    if (defaultValue != null) {
      if (defaultValue != currentValue) {
        trail.add(IconButton(
          icon: const Icon(Icons.replay_rounded),
          onPressed: () {
            onChanged(defaultValue);
          },
          tooltip: "Restore default",
        ));
      }
    }

    if (buttonIcon != null) {
      trail.add(IconButton(
        icon: buttonIcon ?? const Icon(Icons.error_outline_rounded),
        onPressed: () {
          onChanged(null);
        },
      ));
    } else if (buttonText != null) {
      trail.add(TextButton(
        child: Text(buttonText!),
        onPressed: () {
          onChanged(null);
        },
      ));
    } else if (currentValue is bool) {
      trail.add(Switch(
        value: currentValue,
        onChanged: onChanged,
      ));
    } else if (currentValue is String) {
      if (values != null) {
        trail.add(DropdownButton(
          value: currentValue,
          items: values!.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ));
      } else {
        // TODO: TextField?
      }
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: description,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              )),
          if (note != null)
            TextSpan(
                text: "\n$note",
                style: TextStyle(
                  color: noteColor ?? Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.5, // for line spacing
                )),
        ]),
      ),
      trailing: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: trail,
      ),
    );
  }
}
