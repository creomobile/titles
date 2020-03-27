library titles;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// * types

enum TitlePlacement { none, label, placeholder, left, right, top }

typedef TitleBuilder = Widget Function(
    BuildContext context, TitleParameters parameters, dynamic title);

// * context

class TitleParameters {
  const TitleParameters({this.placement, this.style, this.builder});

  static const defaultParameters = TitleParameters(
    placement: TitlePlacement.label,
    builder: defaultTitleBuilder,
  );

  final TitlePlacement placement;
  final TextStyle style;
  final TitleBuilder builder;

  TitleParameters copyWith({
    TitlePlacement placement,
    TextStyle style,
    TitleBuilder builder,
  }) =>
      TitleParameters(
        placement: placement ?? this.placement,
        style: style ?? this.style,
        builder: builder ?? this.builder,
      );

  static Widget defaultTitleBuilder(
      BuildContext context, TitleParameters parameters, dynamic title) {
    Widget titleWidget;
    if (title == null) {
      return const Text('');
    } else if (title is Widget) {
      titleWidget = title;
    } else {
      final placement = parameters.placement;
      assert(placement != TitlePlacement.none &&
          placement != TitlePlacement.label &&
          placement != TitlePlacement.placeholder);
      final text = Text(
          title.toString() + (placement == TitlePlacement.left ? ':' : ''),
          overflow: TextOverflow.ellipsis);
      // ignore: missing_enum_constant_in_switch
      switch (placement) {
        case TitlePlacement.left:
          titleWidget =
              Padding(padding: const EdgeInsets.only(right: 8.0), child: text);
          break;
        case TitlePlacement.right:
          titleWidget =
              Padding(padding: const EdgeInsets.only(left: 8.0), child: text);
          break;
        case TitlePlacement.top:
          titleWidget =
              Padding(padding: const EdgeInsets.only(bottom: 4.0), child: text);
          break;
      }
    }
    final style = parameters.style;
    return style == null
        ? titleWidget
        : AnimatedDefaultTextStyle(
            duration: kThemeChangeDuration, style: style, child: titleWidget);
  }
}

class TitlesContext extends StatelessWidget {
  const TitlesContext({
    Key key,
    @required this.parameters,
    @required this.child,
  })  : assert(parameters != null),
        assert(child != null),
        super(key: key);

  final TitleParameters parameters;
  final Widget child;

  static TitlesContextData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TitlesContextData>();

  @override
  Widget build(BuildContext context) {
    final parentData = TitlesContext.of(context);
    final def = parentData == null
        ? TitleParameters.defaultParameters
        : parentData.parameters;
    final my = parameters;
    final merged = TitleParameters(
      placement: my.placement ?? def.placement,
      style: my.style ?? def.style,
      builder: my.builder ?? def.builder,
    );
    return TitlesContextData(this, child, merged);
  }
}

class TitlesContextData extends InheritedWidget {
  const TitlesContextData(this._widget, Widget child, this.parameters)
      : super(child: child);

  final TitlesContext _widget;
  final TitleParameters parameters;

  @override
  bool updateShouldNotify(TitlesContextData oldWidget) =>
      _widget.parameters != oldWidget._widget.parameters;
}

// * widgets

extension WidgetExtension on Widget {
  Widget buildTitled(dynamic title, [TitlePlacement placement]) =>
      // ignore: missing_return
      Builder(builder: (context) {
        final parameters = TitlesContext.of(context).parameters;
        placement ??= parameters.placement;
        switch (placement) {
          case TitlePlacement.none:
          case TitlePlacement.placeholder:
            return this;
          case TitlePlacement.label:
            final theme = Theme.of(context);
            final decoration = InputDecoration(
              labelText: title.toString(),
              contentPadding: const EdgeInsets.only(top: 20),
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ).applyDefaults(theme.inputDecorationTheme);
            return InputDecorator(decoration: decoration, child: this);
          default:
            final titleWidget = parameters.builder(context, parameters, title);
            // ignore: missing_enum_constant_in_switch
            switch (placement) {
              case TitlePlacement.left:
                return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [titleWidget, Expanded(child: this)]);
              case TitlePlacement.right:
                return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Expanded(child: this), titleWidget]);
              case TitlePlacement.top:
                return IntrinsicWidth(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [titleWidget, this]),
                );
            }
        }
        //
      });
}
