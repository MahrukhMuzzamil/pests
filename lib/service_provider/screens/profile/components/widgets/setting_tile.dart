import 'package:flutter/material.dart';
import '../../../../../client/widgets/animations/custom_switch.dart';

class SettingTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Icon leadingIcon;
  final bool isSwitch;
  final VoidCallback? onTap;
  final bool? switchValue;
  final void Function(bool)? onChanged;

  const SettingTile({
    required this.title,
    this.switchValue,
    this.onChanged,
    this.subtitle,
    this.onTap,
    this.isSwitch = false,
    super.key,
    required this.leadingIcon,
  });

  @override
  State<SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<SettingTile> {
  bool isOn = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ListTile(
        onTap: widget.onTap,
        leading: CircleAvatar(
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: widget.leadingIcon),
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 14)),
        subtitle: widget.isSwitch
            ? null
            : widget.subtitle != null
                ? Text(widget.subtitle!,
                    style: TextStyle(fontWeight: FontWeight.w100,color: Colors.black.withOpacity(.4),fontSize: 13))
                : null,
        trailing: widget.isSwitch
            ? CustomSwitch(
                value: widget.switchValue!,
                activeColor: Colors.blue,
                onChanged: widget.onChanged!,
              )
            : const Icon(Icons.arrow_forward_ios_outlined,color: Colors.blue,),
        contentPadding: const EdgeInsets.only(left: 12,bottom: 4,top: 4,right: 4),
        minVerticalPadding: 0,
      ),
    );
  }
}
