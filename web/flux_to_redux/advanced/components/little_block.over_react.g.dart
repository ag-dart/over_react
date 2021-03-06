// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: deprecated_member_use_from_same_package, unnecessary_null_in_if_null_operators, prefer_null_aware_operators
part of 'little_block.dart';

// **************************************************************************
// OverReactBuilder (package:over_react/src/builder.dart)
// **************************************************************************

// React component factory implementation.
//
// Registers component implementation and links type meta to builder factory.
final $LittleBlockComponentFactory = registerComponent2(
  () => _$LittleBlockComponent(),
  builderFactory: LittleBlock,
  componentClass: LittleBlockComponent,
  isWrapper: false,
  parentType: null,
  displayName: 'LittleBlock',
);

abstract class _$LittleBlockPropsAccessorsMixin implements _$LittleBlockProps {
  @override
  Map get props;

  /// <!-- Generated from [_$LittleBlockProps.backgroundColor] -->
  @override
  String get backgroundColor =>
      props[_$key__backgroundColor___$LittleBlockProps] ??
      null; // Add ` ?? null` to workaround DDC bug: <https://github.com/dart-lang/sdk/issues/36052>;
  /// <!-- Generated from [_$LittleBlockProps.backgroundColor] -->
  @override
  set backgroundColor(String value) =>
      props[_$key__backgroundColor___$LittleBlockProps] = value;

  /// <!-- Generated from [_$LittleBlockProps.colorString] -->
  @override
  String get colorString =>
      props[_$key__colorString___$LittleBlockProps] ??
      null; // Add ` ?? null` to workaround DDC bug: <https://github.com/dart-lang/sdk/issues/36052>;
  /// <!-- Generated from [_$LittleBlockProps.colorString] -->
  @override
  set colorString(String value) =>
      props[_$key__colorString___$LittleBlockProps] = value;

  /// <!-- Generated from [_$LittleBlockProps.blockTitle] -->
  @override
  String get blockTitle =>
      props[_$key__blockTitle___$LittleBlockProps] ??
      null; // Add ` ?? null` to workaround DDC bug: <https://github.com/dart-lang/sdk/issues/36052>;
  /// <!-- Generated from [_$LittleBlockProps.blockTitle] -->
  @override
  set blockTitle(String value) =>
      props[_$key__blockTitle___$LittleBlockProps] = value;
  /* GENERATED CONSTANTS */
  static const PropDescriptor _$prop__backgroundColor___$LittleBlockProps =
      PropDescriptor(_$key__backgroundColor___$LittleBlockProps);
  static const PropDescriptor _$prop__colorString___$LittleBlockProps =
      PropDescriptor(_$key__colorString___$LittleBlockProps);
  static const PropDescriptor _$prop__blockTitle___$LittleBlockProps =
      PropDescriptor(_$key__blockTitle___$LittleBlockProps);
  static const String _$key__backgroundColor___$LittleBlockProps =
      'LittleBlockProps.backgroundColor';
  static const String _$key__colorString___$LittleBlockProps =
      'LittleBlockProps.colorString';
  static const String _$key__blockTitle___$LittleBlockProps =
      'LittleBlockProps.blockTitle';

  static const List<PropDescriptor> $props = [
    _$prop__backgroundColor___$LittleBlockProps,
    _$prop__colorString___$LittleBlockProps,
    _$prop__blockTitle___$LittleBlockProps
  ];
  static const List<String> $propKeys = [
    _$key__backgroundColor___$LittleBlockProps,
    _$key__colorString___$LittleBlockProps,
    _$key__blockTitle___$LittleBlockProps
  ];
}

const PropsMeta _$metaForLittleBlockProps = PropsMeta(
  fields: _$LittleBlockPropsAccessorsMixin.$props,
  keys: _$LittleBlockPropsAccessorsMixin.$propKeys,
);

class LittleBlockProps extends _$LittleBlockProps
    with _$LittleBlockPropsAccessorsMixin {
  static const PropsMeta meta = _$metaForLittleBlockProps;
}

_$$LittleBlockProps _$LittleBlock([Map backingProps]) => backingProps == null
    ? _$$LittleBlockProps$JsMap(JsBackedMap())
    : _$$LittleBlockProps(backingProps);

// Concrete props implementation.
//
// Implements constructor and backing map, and links up to generated component factory.
abstract class _$$LittleBlockProps extends _$LittleBlockProps
    with _$LittleBlockPropsAccessorsMixin
    implements LittleBlockProps {
  _$$LittleBlockProps._();

  factory _$$LittleBlockProps(Map backingMap) {
    if (backingMap == null || backingMap is JsBackedMap) {
      return _$$LittleBlockProps$JsMap(backingMap);
    } else {
      return _$$LittleBlockProps$PlainMap(backingMap);
    }
  }

  /// Let `UiProps` internals know that this class has been generated.
  @override
  bool get $isClassGenerated => true;

  /// The `ReactComponentFactory` associated with the component built by this class.
  @override
  ReactComponentFactoryProxy get componentFactory =>
      super.componentFactory ?? $LittleBlockComponentFactory;

  /// The default namespace for the prop getters/setters generated for this class.
  @override
  String get propKeyNamespace => 'LittleBlockProps.';
}

// Concrete props implementation that can be backed by any [Map].
class _$$LittleBlockProps$PlainMap extends _$$LittleBlockProps {
  // This initializer of `_props` to an empty map, as well as the reassignment
  // of `_props` in the constructor body is necessary to work around a DDC bug: https://github.com/dart-lang/sdk/issues/36217
  _$$LittleBlockProps$PlainMap(Map backingMap)
      : this._props = {},
        super._() {
    this._props = backingMap ?? {};
  }

  /// The backing props map proxied by this class.
  @override
  Map get props => _props;
  Map _props;
}

// Concrete props implementation that can only be backed by [JsMap],
// allowing dart2js to compile more optimal code for key-value pair reads/writes.
class _$$LittleBlockProps$JsMap extends _$$LittleBlockProps {
  // This initializer of `_props` to an empty map, as well as the reassignment
  // of `_props` in the constructor body is necessary to work around a DDC bug: https://github.com/dart-lang/sdk/issues/36217
  _$$LittleBlockProps$JsMap(JsBackedMap backingMap)
      : this._props = JsBackedMap(),
        super._() {
    this._props = backingMap ?? JsBackedMap();
  }

  /// The backing props map proxied by this class.
  @override
  JsBackedMap get props => _props;
  JsBackedMap _props;
}

// Concrete component implementation mixin.
//
// Implements typed props/state factories, defaults `consumedPropKeys` to the keys
// generated for the associated props class.
class _$LittleBlockComponent extends LittleBlockComponent {
  _$$LittleBlockProps$JsMap _cachedTypedProps;

  @override
  _$$LittleBlockProps$JsMap get props => _cachedTypedProps;

  @override
  set props(Map value) {
    assert(
        getBackingMap(value) is JsBackedMap,
        'Component2.props should never be set directly in '
        'production. If this is required for testing, the '
        'component should be rendered within the test. If '
        'that does not have the necessary result, the last '
        'resort is to use typedPropsFactoryJs.');
    super.props = value;
    _cachedTypedProps = typedPropsFactoryJs(getBackingMap(value));
  }

  @override
  _$$LittleBlockProps$JsMap typedPropsFactoryJs(JsBackedMap backingMap) =>
      _$$LittleBlockProps$JsMap(backingMap);

  @override
  _$$LittleBlockProps typedPropsFactory(Map backingMap) =>
      _$$LittleBlockProps(backingMap);

  /// Let `UiComponent` internals know that this class has been generated.
  @override
  bool get $isClassGenerated => true;

  /// The default consumed props, taken from _$LittleBlockProps.
  /// Used in `ConsumedProps` if [consumedProps] is not overridden.
  @override
  final List<ConsumedProps> $defaultConsumedProps = const [
    _$metaForLittleBlockProps
  ];
}
