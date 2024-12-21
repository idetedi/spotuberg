import 'package:flutter/material.dart' hide AppBar;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    show AppBar, WidgetExtension;
import 'package:spotube/components/titlebar/titlebar_buttons.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/utils/platform.dart';
import 'package:window_manager/window_manager.dart';

class TitleBar extends HookConsumerWidget implements PreferredSizeWidget {
  final bool automaticallyImplyLeading;
  final List<Widget> trailing;
  final List<Widget> leading;
  final Widget? child;
  final Widget? title;
  final Widget? header; // small widget placed on top of title
  final Widget? subtitle; // small widget placed below title
  final bool
      trailingExpanded; // expand the trailing instead of the main content
  final AlignmentGeometry alignment;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? leadingGap;
  final double? trailingGap;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final bool useSafeArea;
  final double? surfaceBlur;
  final double? surfaceOpacity;

  const TitleBar({
    super.key,
    this.automaticallyImplyLeading = true,
    this.trailing = const [],
    this.leading = const [],
    this.title,
    this.header,
    this.subtitle,
    this.child,
    this.trailingExpanded = false,
    this.alignment = Alignment.center,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.leadingGap,
    this.trailingGap,
    this.height,
    this.surfaceBlur,
    this.surfaceOpacity,
    this.useSafeArea = true,
  });

  void onDrag(WidgetRef ref) {
    final systemTitleBar =
        ref.read(userPreferencesProvider.select((s) => s.systemTitleBar));
    if (kIsDesktop && !systemTitleBar) {
      windowManager.startDragging();
    }
  }

  @override
  Widget build(BuildContext context, ref) {
    final hasLeadingOrCanPop = leading.isNotEmpty || Navigator.canPop(context);

    return SizedBox(
      height: height ?? 56,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasFullscreen =
              MediaQuery.sizeOf(context).width == constraints.maxWidth;

          return GestureDetector(
            onHorizontalDragStart: (_) => onDrag(ref),
            onVerticalDragStart: (_) => onDrag(ref),
            child: AppBar(
              leading: leading.isEmpty &&
                      automaticallyImplyLeading &&
                      Navigator.canPop(context)
                  ? [
                      const BackButton(),
                    ]
                  : leading,
              trailing: [
                ...trailing,
                WindowTitleBarButtons(foregroundColor: foregroundColor),
              ],
              title: title,
              header: header,
              subtitle: subtitle,
              trailingExpanded: trailingExpanded,
              alignment: alignment,
              padding: padding,
              backgroundColor: backgroundColor,
              leadingGap: leadingGap,
              trailingGap: trailingGap,
              height: height,
              surfaceBlur: surfaceBlur,
              surfaceOpacity: surfaceOpacity,
              useSafeArea: useSafeArea,
              child: child,
            ).withPadding(
                left: kIsMacOS && hasFullscreen && hasLeadingOrCanPop ? 65 : 0),
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56.0);
}
