import 'package:flutter/widgets.dart';

import '../models/control.dart';
import '../utils/alignment.dart';
import 'create_control.dart';
import 'scrollable_control.dart';

class ColumnControl extends StatelessWidget {
  final Control? parent;
  final Control control;
  final bool parentDisabled;
  final List<Control> children;

  const ColumnControl(
      {Key? key,
      this.parent,
      required this.control,
      required this.children,
      required this.parentDisabled})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("Column build: ${control.id}");

    final spacing = control.attrDouble("spacing", 10)!;
    final mainAlignment =
        parseMainAxisAlignment(control, "alignment", MainAxisAlignment.start);
    bool tight = control.attrBool("tight", false)!;
    bool wrap = control.attrBool("wrap", false)!;
    ScrollMode scrollMode = ScrollMode.values.firstWhere(
        (m) =>
            m.name.toLowerCase() ==
            control.attrString("scroll", "")!.toLowerCase(),
        orElse: () => ScrollMode.none);
    final autoScroll = control.attrBool("autoScroll", false)!;
    bool disabled = control.isDisabled || parentDisabled;

    List<Widget> controls = [];

    bool firstControl = true;
    for (var ctrl in children.where((c) => c.isVisible)) {
      // spacer between displayed controls
      if (!wrap &&
          spacing > 0 &&
          !firstControl &&
          mainAlignment != MainAxisAlignment.spaceAround &&
          mainAlignment != MainAxisAlignment.spaceBetween &&
          mainAlignment != MainAxisAlignment.spaceEvenly) {
        controls.add(SizedBox(height: spacing));
      }
      firstControl = false;

      // displayed control
      controls.add(createControl(control, ctrl.id, disabled));
    }

    Widget widget = wrap
        ? Wrap(
            direction: Axis.vertical,
            children: controls,
            spacing: spacing,
            runSpacing: control.attrDouble("runSpacing", 10)!,
            alignment:
                parseWrapAlignment(control, "alignment", WrapAlignment.start),
            crossAxisAlignment: parseWrapCrossAlignment(
                control, "horizontalAlignment", WrapCrossAlignment.start),
          )
        : Column(
            mainAxisAlignment: mainAlignment,
            mainAxisSize: tight ? MainAxisSize.min : MainAxisSize.max,
            crossAxisAlignment: parseCrossAxisAlignment(
                control, "horizontalAlignment", CrossAxisAlignment.start),
            children: controls,
          );

    return constrainedControl(
        context,
        scrollMode != ScrollMode.none
            ? ScrollableControl(
                child: widget,
                scrollDirection: wrap ? Axis.horizontal : Axis.vertical,
                scrollMode: scrollMode,
                autoScroll: autoScroll,
              )
            : widget,
        parent,
        control);
  }
}
