import 'dart:convert';

import 'package:over_react/over_react.dart';
import 'package:over_react/over_react_redux.dart';

import 'package:todo_client/src/actions.dart';
import 'package:todo_client/src/local_storage.dart';
import 'package:todo_client/src/store.dart';
import 'package:todo_client/src/components/app_bar/save_as_menu_item.dart';
import 'package:todo_client/src/components/app_bar/saved_data_menu_item.dart';
import 'package:todo_client/src/components/shared/material_ui.dart';
import 'package:todo_client/src/components/shared/menu_overlay.dart';

// ignore: uri_has_not_been_generated
part 'app_bar_local_storage_menu.over_react.g.dart';

UiFactory<AppBarLocalStorageMenuProps> ConnectedAppBarLocalStorageMenu = connect<AppState, AppBarLocalStorageMenuProps>(
    mapStateToProps: (state) {
      return (AppBarLocalStorageMenu()
        ..currentDataSetName = state.name
        ..currentDataHasBeenModified = json.encode(localTodoAppStorage[state.name]) != json.encode(state.toJson())
      );
    },
)(AppBarLocalStorageMenu);

@Factory()
UiFactory<AppBarLocalStorageMenuProps> AppBarLocalStorageMenu =
    // ignore: undefined_identifier
    _$AppBarLocalStorageMenu;

@Props()
class _$AppBarLocalStorageMenuProps extends MenuOverlayProps with ConnectPropsMixin {
  String currentDataSetName;
  List<String> savedLocalStorageStateNames;
  bool currentDataHasBeenModified;
}

@Component2()
class AppBarLocalStorageMenuComponent extends UiComponent2<AppBarLocalStorageMenuProps> {
  final _overlayRef = createRef<MenuOverlayComponent>();
  bool get _currentStateKeyIsReadOnly => TodoAppLocalStorage.reservedStateKeys.contains(props.currentDataSetName);

  @override
  render() {
    return (MenuOverlay()
      ..modifyProps(addUnconsumedProps)
      ..trigger = Button({'color': 'inherit'}, 'Data: ${props.currentDataSetName}')
      ..useDerivedMaxWidth = true
      ..ref = _overlayRef
    )(
      _renderSaveMenuItem(),
      _renderSaveAsMenuItem(),
      MenuItem({
        'onClick': (_) {
          _loadFromLocalStorage(TodoAppLocalStorage.defaultStateKey);
        },
      }, 'Load Default Data'),
      MenuItem({
        'onClick': (_) {
          _loadFromLocalStorage(TodoAppLocalStorage.emptyStateKey);
        },
      }, 'Load Empty Data'),
      _renderSavedStateMenuItems(),
    );
  }

  ReactElement _renderSaveMenuItem() {
    if (!props.currentDataHasBeenModified || _currentStateKeyIsReadOnly) return null;

    return MenuItem({
      'onClick': (SyntheticMouseEvent event) {
        event.stopPropagation(); // Don't close the menu
        _handleCurrentLocalStorageStateSaveAs(newStateName: props.currentDataSetName);
      }
    },
      'Save ${props.currentDataSetName}',
    );
  }

  ReactElement _renderSaveAsMenuItem() {
    return (SaveAsMenuItem()
      ..initialValue = _currentStateKeyIsReadOnly ? 'Copy of ${props.currentDataSetName}' : props.currentDataSetName
      ..onSave = (newStateName) {
        _handleCurrentLocalStorageStateSaveAs(newStateName: newStateName);
      }
    )();
  }

  ReactElement _renderSavedStateMenuItem(String stateKey) {
    final json = localTodoAppStorage.mapOfCustomStatesJson[stateKey];
    return (SavedDataMenuItem()
      ..key = json['name']
      ..['selected'] = json['name'] == props.currentDataSetName
      ..localStorageKey = json['name']
      ..onSelect = _loadFromLocalStorage
      ..onRename = (newStateName) {
        _handleLocalStorageStateRename(newStateName, renamedFrom: json['name']);
      }
      ..onDelete = (stateName) {
        localTodoAppStorage.remove(stateName);
        forceUpdate();
      }
    )();
  }

  List<ReactElement> _renderSavedStateMenuItems() {
    if (localTodoAppStorage.mapOfCustomStatesJson.isEmpty) return null;

    return [
      Divider({'key': 'divider'}),
      (Dom.li()..key = 'dividerLabel')(
        Typography({
          'color': 'textSecondary',
          'display': 'block',
          'variant': 'caption',
          'style': {'margin': '5px 0 0 16px'},
        },
          'Custom Data Sets',
        ),
      ),
      ...localTodoAppStorage.mapOfCustomStatesJson.keys.map(_renderSavedStateMenuItem),
    ];
  }

  void _handleLocalStorageStateRename(String newStateName, {String renamedFrom}) {
    props.dispatch(SaveLocalStorageStateAsAction(newStateName, previousName: renamedFrom));
  }

  void _handleCurrentLocalStorageStateSaveAs({String newStateName}) {
    props.dispatch(SaveLocalStorageStateAsAction(newStateName));
    _loadFromLocalStorage(newStateName);
    _overlayRef.current.close();
  }

  void _loadFromLocalStorage(String stateName) {
    props.dispatch(LoadStateFromLocalStorageAction(stateName));
    _overlayRef.current.close();
  }
}

// ignore: mixin_of_non_class, undefined_class
class AppBarLocalStorageMenuProps extends _$AppBarLocalStorageMenuProps with _$AppBarLocalStorageMenuPropsAccessorsMixin {
  // ignore: undefined_identifier, undefined_class, const_initialized_with_non_constant_value
  static const PropsMeta meta = _$metaForAppBarLocalStorageMenuProps;
}
