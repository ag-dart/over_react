import 'package:collection/collection.dart';
import 'package:over_react/over_react.dart';
import 'package:over_react/over_react_redux.dart';

import 'package:todo_client/src/actions.dart';
import 'package:todo_client/src/store.dart';
import 'package:todo_client/src/models/user.dart';
import 'package:todo_client/src/components/shared/material_ui.dart';

// ignore: uri_has_not_been_generated
part 'task_count.over_react.g.dart';

UiFactory<TaskCountBadgeProps> ConnectedTaskCountBadge = connect<AppState, TaskCountBadgeProps>(
    mapStateToPropsWithOwnProps: (state, ownProps) {
      return (TaskCountBadge()
        ..assignedTodoIds = state.todos.where((todo) => todo.assignedUserId == ownProps.user.id)
            .map((todo) => todo.id).toList()
      );
    },
    areStatePropsEqual: (nextProps, prevProps) {
      return ListEquality().equals(nextProps.assignedTodoIds, prevProps.assignedTodoIds);
    },
)(TaskCountBadge);

@Factory()
UiFactory<TaskCountBadgeProps> TaskCountBadge =
    // ignore: undefined_identifier
    _$TaskCountBadge;

@Props()
class _$TaskCountBadgeProps extends UiProps with ConnectPropsMixin {
  @requiredProp
  User user;

  @requiredProp
  List<String> assignedTodoIds;
}

@Component2()
class TaskCountBadgeComponent extends UiComponent2<TaskCountBadgeProps> {
  @override
  render() {
    return Box({
      'onMouseEnter': (_) {
        props.dispatch(HighlightTodosAction(props.assignedTodoIds));
      },
      'onMouseLeave': (_) {
        props.dispatch(UnHighlightTodosAction(props.assignedTodoIds));
      },
    },
      Tooltip({
        'title': _tooltipContent,
        'arrow': true,
        'enterDelay': 500,
      },
        Badge({
          'badgeContent': props.assignedTodoIds.length,
          'color': 'secondary',
          'overlap': 'circle',
          'anchorOrigin': {
            'vertical': 'bottom',
            'horizontal': 'right',
          },
        },
          props.children,
        ),
      ),
    );
  }

  String get _tooltipContent {
    final taskCount = props.assignedTodoIds.length;
    if (taskCount == 1) {
      return 'There is $taskCount task assigned to ${props.user.name}';
    }

    return 'There are $taskCount tasks assigned to ${props.user.name}';
  }
}

// ignore: mixin_of_non_class, undefined_class
class TaskCountBadgeProps extends _$TaskCountBadgeProps with _$TaskCountBadgePropsAccessorsMixin {
  // ignore: undefined_identifier, undefined_class, const_initialized_with_non_constant_value
  static const PropsMeta meta = _$metaForTaskCountBadgeProps;
}
