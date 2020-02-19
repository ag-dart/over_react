import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:meta/meta.dart';
import 'package:over_react/src/builder/generation/parsing/members.dart';
import 'package:over_react/src/builder/generation/parsing/util.dart';
import 'package:over_react/src/builder/generation/parsing/version.dart';

Union<BoilerplateProps, BoilerplatePropsMixin> getPropsForFactory(
  BoilerplateFactory factory,
  Iterable<BoilerplateProps> props,
  Iterable<BoilerplatePropsMixin> propsMixins,
) => throw UnimplementedError();

Union<BoilerplateState, BoilerplateStateMixin> getStateForFactory(
  BoilerplateFactory factory,
  Iterable<BoilerplateState> states,
  Iterable<BoilerplateStateMixin> stateMixins,
) => throw UnimplementedError();

class FactoryGroup {
  final List<BoilerplateFactory> factories;

  FactoryGroup(this.factories);

  BoilerplateFactory get bestFactory => throw UnimplementedError();
}

List<FactoryGroup> groupFactories(Iterable<BoilerplateFactory> factories) => throw UnimplementedError();

bool isStandaloneFactory(BoilerplateFactory factory) => throw UnimplementedError();
bool isFunctionComponent(BoilerplateFactory factory) => throw UnimplementedError();

NamedCompilationUnitMember fuzzyMatch(BoilerplateMember member, Iterable<BoilerplateMember> members) => throw UnimplementedError();

BoilerplateComponent getComponent(
  BoilerplateFactory factory,
  Union<BoilerplateProps, BoilerplatePropsMixin> propsClassOrMixin,
) => throw UnimplementedError();


Iterable<BoilerplateDeclaration> getBoilerplateDeclarations(BoilerplateMembers members, ValidationErrorCollector errorCollector) sync* {
  final factories = members.factories;
  final props = members.props;
  final propsMixins = members.propsMixins;
  final components = members.components;
  final states = members.states;
  final stateMixins = members.stateMixins;

  for (var propsMixin in propsMixins) {
    yield PropsMixinDeclaration(propsMixin: propsMixin);
  }

  final unusedFactories = <FactoryGroup>[];

  // todo assume one component per file here, group if the counts are correct

  // ...


  // todo getPropsForFactories getComponent utils - what if there are multiple candidates?
  //  Do we just go with the first one, or do we use confidence scores? It's possible something could look like a component or props class

  // todo maybe just ditch factory groups and instead strip out non-best factories.
  // Use a queue since we want to mutate factories during iteration
  final factoryGroups = groupFactories(factories);
  final factoryGroupsQueue = Queue.of(factoryGroups);
  while (factoryGroupsQueue.isNotEmpty) {
    final factoryGroup = factoryGroupsQueue.removeFirst();
    final factory = factoryGroup.bestFactory;

    final propsClassOrMixin = getPropsForFactory(factory, props, propsMixins);
    final stateClassOrMixin = getStateForFactory(factory, states, stateMixins);

    if (propsClassOrMixin == null) {
      // will be validated below the for-loop.
      continue;
    }

    factoryGroups.remove(factoryGroup);
    factoryGroup.factories.forEach(factories.remove);
    // don't remove mixins, just classes, since mixins are generated/grouped the same as when standalone
    props.remove(propsClassOrMixin.either);
    states.remove(stateClassOrMixin?.either);

    final component = getComponent(factory, propsClassOrMixin);
    if (component != null) {
      components.remove(component);

      final versions = resolveVersions([factory, propsClassOrMixin.either, component, stateClassOrMixin.either]);

      switch (versions.firstOrNull) {
        case BoilerplateVersion.v2_legacyBackwardsCompat:
        case BoilerplateVersion.v3_legacyDart2Only:
          // FIXME what if propsClassOrMixin is a mixin? It probably wouldn't have gotten filtered out in resolveVersions, and we'd currently expect Declaration.validate to handle it.
          yield LegacyClassComponentDeclaration(factory: factory, component: component, props: propsClassOrMixin.a, state: stateClassOrMixin.a);
          break;
        case BoilerplateVersion.v4_mixinBased:
          yield ClassComponentDeclaration(factory: factory, component: component, props: propsClassOrMixin, state: stateClassOrMixin);
          break;
        default:
          // This case (null) is unlikely, but it means that none of the declarations actually seem like boilerplate.
          break;
      }
    } else {
      if (propsClassOrMixin == null) {
        unusedFactories.add(factoryGroup);
        continue;
      }

      if (isFunctionComponent(factory)) {
        yield FunctionComponentDeclaration(factory: factory, props: propsClassOrMixin);
      } else {
        yield PropsMapViewDeclaration(factory: factory, props: propsClassOrMixin);
      }
    }
  }

  for (var component in components) {
    final potentialFactory = fuzzyMatch(component, factories)?.name;
    final potentialProps = fuzzyMatch(component, [...props, ...propsMixins])?.name;
    errorCollector.addError('Component is missing factory/props: could it be referring to $potentialFactory/$potentialProps?',
        errorCollector.spanFor(component.node.name));
  }

  for (var factoryGroup in factoryGroups) {
    if (isStandaloneFactory(factoryGroup.bestFactory)) {
      continue;
    }

    final potentialProps = fuzzyMatch(factoryGroup.bestFactory, [...props, ...propsMixins]);
    errorCollector.addError('Factory is missing props: $potentialProps');
  }

  for (var propsClass in props) {
    final potentialFactory = fuzzyMatch(propsClass, factories);
    final potentialComponent = fuzzyMatch(propsClass, components);
    errorCollector.addError('Props class is missing factory/component: $potentialFactory/$potentialComponent');
  }

  // todo when to fail for above cases vs just warn? When they reference generated code? When their "is boilerplate" confidence score is sufficiently high?

  // todo outside of this function, Validate boilerplateDecls, which validates individual items as well


  // old version
//  final factories, propsClasses, propsMixins, components;
  //
  //  final deduplicatedFactories = findRelatedFactories();
  //  for (var factory in deuplicatedFactories) {
  //    final propsClassOrMixin = getPropsForFactory(factory, propsClasses, propsMixins);
  //    propsClasses.remove(propsClassOrMixin);
  //    final propsImplInfo = generatePropsImpl(propsClassOrMixin);
  //
  //    final component = getComponent(factory, propsClassOrMixin);
  //    if (component != null) {
  //      components.remove(component);
  //      generateComponentImpl(component, propsImplInfo);
  //      generateComponentFactoryProxy(component, propsImplInfo);
  //    } else {
  //      // Props MapViews and Function components, also bad components?
  //      generateThrowingComponentFactoryProxy();
  //    }
  //  }
  //
  //  for (var factory in propsMixins) {
  //  }
}



class GrouperByName {
  static final namePattern = RegExp(r'^[_$]*(\w+)(?:Comp(?:onent)?|(?:Props|State)(?:Mixin)?)$');

  Map<String, List<CompilationUnitMember>> group(Iterable<BoilerplateMember> members) {
    final groupsByName = <String, List<CompilationUnitMember>>{};

    for (var boilerplateMember in members) {
      final member = boilerplateMember.node;

      String name;
      if (member is NamedCompilationUnitMember) {
        final rawName = member.name.name;
        final nameMatch = namePattern.firstMatch(rawName);
        if (nameMatch != null) {
          name = nameMatch.group(1);
        }
      } else if (member is TopLevelVariableDeclaration) {
        name = member.variables.variables.first.name.name;
      }

      if (name != null) {
        groupsByName.putIfAbsent(name, () => []).add(member);
      }
    }

    groupsByName.removeWhere((name, nodes) => nodes.length == 1);

    return groupsByName;
  }
}


class BoilerplateGenerator {}

abstract class BoilerplateDeclaration {
  void validate(BoilerplateVersion version, ValidationErrorCollector errorCollector) {}
  BoilerplateGenerator get generator => null;

  Iterable<BoilerplateMember> get _members;
  BoilerplateVersion get bestVersion => resolveVersions(_members.whereNotNull()).firstOrNull;
}

class LegacyClassComponentDeclaration extends BoilerplateDeclaration {
  final BoilerplateFactory factory;
  final BoilerplateComponent component;
  final BoilerplateProps props;
  final BoilerplateState state;

  @override
  get _members => [factory, component, props, state];

  LegacyClassComponentDeclaration(
      {@required this.factory,
      @required this.component,
      @required this.props,
      this.state});
}

class LegacyAbstractClassComponentDeclaration extends BoilerplateDeclaration {
  final BoilerplateComponent component;
  final BoilerplateProps props;
  final BoilerplateState state;

  @override
  get _members => [component, props, state];

  LegacyAbstractClassComponentDeclaration(
      {@required this.component, @required this.props, this.state});
}

class ClassComponentDeclaration extends BoilerplateDeclaration {
  final BoilerplateFactory factory;
  final BoilerplateComponent component;
  final Union<BoilerplateProps, BoilerplatePropsMixin> props;
  final Union<BoilerplateState, BoilerplateStateMixin> state;

  @override
  get _members => [factory, component, props.either, state.either];

  ClassComponentDeclaration(
      {@required this.factory,
      @required this.component,
      @required this.props,
      this.state});
}

// todo how to tell between these two?

class PropsMapViewDeclaration extends BoilerplateDeclaration {
  final BoilerplateFactory factory;

  final Union<BoilerplateProps, BoilerplatePropsMixin> props;

  @override
  get _members => [factory, props.either];

  PropsMapViewDeclaration({@required this.factory, @required this.props});
}

class FunctionComponentDeclaration extends BoilerplateDeclaration {
  // will it even have this?
  final BoilerplateFactory factory;

  // will have only one of these
  final Union<BoilerplateProps, BoilerplatePropsMixin> props;

  @override
  get _members => [factory, props.either];

  FunctionComponentDeclaration({@required this.factory, @required this.props});
}

class PropsMixinDeclaration extends BoilerplateDeclaration {
  final BoilerplatePropsMixin propsMixin;

  @override
  get _members => [propsMixin];

  PropsMixinDeclaration({@required this.propsMixin});
}

class StateMixinDeclaration extends BoilerplateDeclaration {
  final BoilerplateStateMixin stateMixin;

  @override
  get _members => [stateMixin];

  StateMixinDeclaration({@required this.stateMixin});
}
