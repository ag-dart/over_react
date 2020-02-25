part of '../members.dart';

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return substring(0, 1).toUpperCase() + substring(1);
  }
}

mixin PropsStateStringHelpers {
  bool get isProps;
  String get propsOrStateString => isProps ? 'props' : 'state';
  String get propsOrStateBaseClassString => 'Ui${propsOrStateString.capitalize()}';
  String get propsOrStateClassString => '${propsOrStateString.capitalize()} class';
  String get propsOrStateMixinString => '${propsOrStateString.capitalize()} mixin';
  String get propsOrStateFieldsName => isProps ? 'props' : 'state fields';
  String get propsOrStateMetaStructName => isProps ? 'PropsMeta' : 'StateMeta';
}

abstract class BoilerplatePropsOrState extends BoilerplateMember with PropsStateStringHelpers {
  @override
  final NamedCompilationUnitMember node;

  final ClassishDeclaration nodeHelper;

  final bool hasCompanionClass;

  NodeWithMeta<NamedCompilationUnitMember, annotations.TypedMap> get withMeta;

  BoilerplatePropsOrState(this.nodeHelper, int declarationConfidence, {@required this.hasCompanionClass}) : node = nodeHelper.node, super(declarationConfidence);

  @override
  Map<BoilerplateVersion, int> get versionConfidence => {
    // todo might need to rethink these, as well as in the mixin classes, to be able to provide better error messages when people make things mixins
    BoilerplateVersion.v2_legacyBackwardsCompat: node is MixinDeclaration ? Confidence.none : Confidence.high,
    BoilerplateVersion.v3_legacyDart2Only: node is MixinDeclaration ? Confidence.none : Confidence.high,
    BoilerplateVersion.v4_mixinBased: node is MixinDeclaration ? Confidence.high : Confidence.veryLow,
  };

  @override
  void validate(BoilerplateVersion version, ValidationErrorCollector errorCollector) {
    switch (version) {
      case BoilerplateVersion.v4_mixinBased:
        final node = this.node;
        if (node is MixinDeclaration) {
          // It's possible in the future that this may not always
          // be a ClassDeclaration, so fall back to node if it's not one.
          errorCollector.addError('$propsOrStateClassString implementations must be concrete classes, not mixins',// TODO add versions to error messages
              errorCollector.spanFor(node.mixinKeyword));
        } else {
          if (nodeHelper.superclass?.nameWithoutPrefix != 'UiProps') {
            errorCollector.addError('$propsOrStateClassString implementations must extend directly from `on $propsOrStateBaseClassString`',
                errorCollector.spanFor(nodeHelper.superclass ?? node));
          }

          if (node is ClassDeclaration && node.members.isNotEmpty) {
            errorCollector.addError('$propsOrStateClassString implementations must not declare any $propsOrStateFieldsName or other memberss.',
                errorCollector.span(node.leftBracket.offset, node.rightBracket.end));
          }

          if (nodeHelper.isAbstract) {
            // todo what about the abstract interface case? Do we special case the "Abstract" prefix?
            errorCollector.addError('$propsOrStateClassString implementations must not be abstract, as they cannot be extended.',
            errorCollector.spanFor(nodeHelper.abstractKeyword));
          }
        }
        break;
      case BoilerplateVersion.v2_legacyBackwardsCompat:
        // TODO: Handle this case.
        break;
      case BoilerplateVersion.v3_legacyDart2Only:
        // TODO: Handle this case.
        break;
    }
  }
}

class BoilerplateProps extends BoilerplatePropsOrState {
  BoilerplateProps(ClassishDeclaration nodeHelper, int declarationConfidence) : withMeta = NodeWithMeta(nodeHelper.node), super(nodeHelper, declarationConfidence);

  @override
  final NodeWithMeta<NamedCompilationUnitMember, annotations.Props> withMeta;

  @override
  bool get isProps => true;
}

class BoilerplateState extends BoilerplatePropsOrState {
  BoilerplateState(ClassishDeclaration nodeHelper, int declarationConfidence) : withMeta = NodeWithMeta(nodeHelper.node), super(nodeHelper, declarationConfidence);

  @override
  final NodeWithMeta<NamedCompilationUnitMember, annotations.State> withMeta;

  @override
  bool get isProps => false;
}

abstract class BoilerplatePropsOrStateMixin extends BoilerplateMember with PropsStateStringHelpers {
  @override
  final ClassOrMixinDeclaration node;

  NodeWithMeta<ClassOrMixinDeclaration, annotations.TypedMap> get withMeta;

  BoilerplatePropsOrStateMixin(this.node, int declarationConfidence) : super(declarationConfidence);

  @override
  Map<BoilerplateVersion, int> get versionConfidence {
    final isMixin = node is MixinDeclaration;
    final hasGeneratedPrefix = node.name.name.startsWith(r'_$');

    return {
      BoilerplateVersion.v2_legacyBackwardsCompat: isMixin
          ? Confidence.none
          : (hasGeneratedPrefix ? Confidence.veryLow : Confidence.high),

      BoilerplateVersion.v3_legacyDart2Only: isMixin
          ? Confidence.none
          : (hasGeneratedPrefix ? Confidence.high : Confidence.veryLow),

      BoilerplateVersion.v4_mixinBased:
          isMixin ? Confidence.high : Confidence.veryLow,
    };
  }

  @override
  void validate(BoilerplateVersion version, ValidationErrorCollector errorCollector) {
    switch (version) {
      case BoilerplateVersion.v4_mixinBased:
        final node = this.node;
        if (node is MixinDeclaration) {
          final isOnUiProps = node.onClause?.superclassConstraints
              ?.any((type) => type.nameWithoutPrefix == propsOrStateBaseClassString) ?? false;
          if (!isOnUiProps) {
            errorCollector.addError('$propsOrStateString mixins must be `on $propsOrStateBaseClassString`',
                errorCollector.spanFor(node.onClause ?? node.name));
          }
        } else {
          // It's possible in the future that this may not always
          // be a ClassDeclaration, so fall back to node if it's not one.
          final spanNode = node.tryCast<ClassDeclaration>()?.classKeyword ?? node;
          errorCollector.addError('$propsOrStateString mixins must be mixins',
              errorCollector.spanFor(spanNode));
        }
        break;
      case BoilerplateVersion.v2_legacyBackwardsCompat:
        validateMetaField(node, propsOrStateMetaStructName, errorCollector);
        break;
      case BoilerplateVersion.v3_legacyDart2Only:
        checkForMetaPresence(node, errorCollector);
        break;
    }
  }
}

/// If a [ClassMember] exists in [node] with the name `meta`, this will
/// throw an error if the member is not static and a warning if the member
/// is static.
void checkForMetaPresence(ClassOrMixinDeclaration node, ValidationErrorCollector errorCollector) {
  final metaField = metaFieldOrNull(node);
  final metaMethod = metaMethodOrNull(node);
  final isNotNull = metaField != null || metaMethod != null;
  final isStatic = (metaField?.isStatic ?? false) || (metaMethod?.isStatic ?? false);
  if (isNotNull) {
    // If a class declares a field or method with the name of `meta` which is
    // not static, then we should error, since the static `meta` const in the
    // generated implementation will have a naming collision.
    if (!isStatic) {
      errorCollector.addError('Non-static class member `meta` is declared in ${node.name.name}. '
          '`meta` is a field declared by the over_react builder, and is therefore not '
          'valid for use as a class member in any class annotated with  @Props(), @State(), '
          '@AbstractProps(), @AbstractState(), @PropsMixin(), or @StateMixin()',
          errorCollector.spanFor(metaField ?? metaMethod));
    } else {
      // warn that static `meta` definition will not be accessible by consumers.
      errorCollector.addWarning(messageWithSpan('Static class member `meta` is declared in ${node.name.name}. '
          '`meta` is a field declared by the over_react builder, and therefore this '
          'class member will be unused and should be removed or renamed.',
          span: errorCollector.spanFor(metaField ?? metaMethod)));
    }
  }
}

/// Validates that `meta` field in a companion class or props/state mixin
/// is formatted as expected.
///
/// Meta fields should have the following format:
///   `static const {Props|State}Meta meta = _$metaFor{className};`
///
/// [cd] should be either a [ClassDeclaration] instance for the companion
/// class of a props/state/abstract props/abstract state class, or the
/// [ClassDeclaration] for a props or state mixin class.
void validateMetaField(ClassOrMixinDeclaration cd, String expectedType, ValidationErrorCollector errorCollector) {
  final metaField = getMetaField(cd);
  if (metaField == null) return;

  if (metaField.fields.type?.toSource() != expectedType) {
    errorCollector.addError(
      'Static meta field in accessor class must be of type `$expectedType`',
      errorCollector.spanFor(metaField),
    );
  }

  final expectedInitializer = '${privateSourcePrefix}metaFor${cd.name.name}';

  final initializer = metaField.fields.variables.single.initializer
      ?.toSource();
  if (!(expectedInitializer == initializer)) {
    errorCollector.addError(
      'Static $expectedType field in accessor class must be initialized to:'
          '`$expectedInitializer`',
      errorCollector.spanFor(metaField),
    );
  }
}

class BoilerplatePropsMixin extends BoilerplatePropsOrStateMixin {
  BoilerplatePropsMixin(ClassOrMixinDeclaration node, int declarationConfidence) : withMeta = NodeWithMeta(node), super(node, declarationConfidence);

  @override
  final NodeWithMeta<ClassOrMixinDeclaration, annotations.PropsMixin> withMeta;

  @override
  bool get isProps => true;
}


class BoilerplateStateMixin extends BoilerplatePropsOrStateMixin {
  BoilerplateStateMixin(ClassOrMixinDeclaration node, int declarationConfidence) : withMeta = NodeWithMeta(node), super(node, declarationConfidence);

  @override
  final NodeWithMeta<ClassOrMixinDeclaration, annotations.StateMixin> withMeta;

  @override
  bool get isProps => false;
}
