import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile(this.title, this.description, this.currentValue, this.onChanged,
      {super.key,
      this.values,
      this.buttonIcon,
      this.note,
      this.noteColor});

  final String title;
  final String description;
  final dynamic currentValue;
  final Function(dynamic) onChanged;
  final List<dynamic>? values;
  final Icon? buttonIcon;
  final String? note;
  final Color? noteColor;

  @override
  Widget build(BuildContext context) {
    Widget trailingWidget = const SizedBox.shrink();

    if (buttonIcon != null) {
      trailingWidget = IconButton(
        icon: buttonIcon ?? const Icon(Icons.error_outline_rounded),
        onPressed: () {
          onChanged(null);
        },
      );
    } else if (currentValue is bool) {
      trailingWidget = Switch(
        value: currentValue,
        onChanged: onChanged,
      );
    } else if (currentValue is String) {
      if (values != null) {
        trailingWidget = DropdownButton(
          value: currentValue,
          items: values!.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        );
      } else {
        // TODO: TextField?
      }
    }

    return ListTile(
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
      trailing: trailingWidget,
    );
  }
}
