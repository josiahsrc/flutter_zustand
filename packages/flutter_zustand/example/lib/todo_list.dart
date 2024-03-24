import 'package:flutter/material.dart';
import 'package:flutter_zustand/flutter_zustand.dart';

class TodoState {
  const TodoState({
    this.ordering = const [],
    this.todos = const {},
    this.completed = const {},
    this.draft = '',
  });

  final List<int> ordering;
  final Map<int, String> todos;
  final Set<int> completed;
  final String draft;

  TodoState copyWith({
    List<int>? ordering,
    Map<int, String>? todos,
    Set<int>? completed,
    String? draft,
  }) {
    return TodoState(
      ordering: ordering ?? this.ordering,
      todos: todos ?? this.todos,
      completed: completed ?? this.completed,
      draft: draft ?? this.draft,
    );
  }

  bool isDone(int id) => completed.contains(id);

  String getTodo(int id) => todos[id]!;

  bool get canAddNewItem => draft.isNotEmpty;
}

class TodoStore extends Store<TodoState> {
  TodoStore() : super(const TodoState());

  void changedDraft(String draft) {
    set(state.copyWith(draft: draft));
  }

  void addedNewItem() {
    if (!state.canAddNewItem) return;
    final id = state.todos.keys.fold(0, (a, b) => a > b ? a : b) + 1;
    set(state.copyWith(
      ordering: [...state.ordering, id],
      todos: {...state.todos, id: state.draft},
      draft: '',
    ));
  }

  void removedItem(int id) {
    set(state.copyWith(
      ordering: state.ordering.where((i) => i != id).toList(),
      todos: <int, String>{...state.todos}..remove(id),
      completed: <int>{...state.completed}..remove(id),
    ));
  }

  void toggledItem(int id) {
    if (state.completed.contains(id)) {
      set(state.copyWith(completed: <int>{...state.completed}..remove(id)));
    } else {
      set(state.copyWith(completed: <int>{...state.completed}..add(id)));
    }
  }

  void reorderedItems(int oldIndex, int newIndex) {
    final ordering = List<int>.from(state.ordering);
    final id = ordering.removeAt(oldIndex);
    ordering.insert(newIndex, id);
    set(state.copyWith(ordering: ordering));
  }
}

TodoStore useTodoStore() => create(() => TodoStore());

class TodoListPage extends StatelessWidget {
  const TodoListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ordering = useTodoStore().select(context, (state) => state.ordering);

    final content = Column(
      children: [
        Expanded(
          child: ReorderableListView(
            onReorder: (oldIndex, newIndex) {
              useTodoStore().reorderedItems(oldIndex, newIndex);
            },
            children: ordering
                .map((id) => TodoItem(id: id, key: ValueKey(id)))
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0).copyWith(bottom: 64),
          child: const DraftEditor(),
        ),
      ],
    );

    final page = Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: SafeArea(child: content),
    );

    void showMessage(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    return StoreListener(
      [
        useTodoStore().listen(
          (context, state) {
            showMessage('Reordered items');
          },
          condition: (prev, next) =>
              prev.ordering != next.ordering &&
              prev.ordering.length == next.ordering.length,
        ),
        useTodoStore().listen(
          (context, state) {
            showMessage('Added new item');
          },
          condition: (prev, next) => next.todos.length > prev.todos.length,
        ),
      ],
      child: page,
    );
  }
}

class TodoItem extends StatelessWidget {
  final int id;

  const TodoItem({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final text = useTodoStore().select(context, (state) => state.getTodo(id));
    final done = useTodoStore().select(context, (state) => state.isDone(id));

    return CheckboxListTile(
      value: done,
      onChanged: (_) {
        useTodoStore().toggledItem(id);
      },
      title: Text(text),
    );
  }
}

class DraftEditor extends StatefulWidget {
  const DraftEditor({super.key});

  @override
  State<DraftEditor> createState() => _DraftEditorState();
}

class _DraftEditorState extends State<DraftEditor> {
  final controller = TextEditingController();

  @override
  void initState() {
    controller.text = useTodoStore().state.draft;
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canAddNewItem =
        useTodoStore().select(context, (state) => state.canAddNewItem);

    final field = TextField(
      controller: controller,
      onChanged: (value) {
        useTodoStore().changedDraft(value);
      },
      onSubmitted: (_) {
        useTodoStore().addedNewItem();
      },
      decoration: InputDecoration(
        hintText: 'Add a new todo',
        suffixIcon: IconButton(
          icon: const Icon(Icons.add),
          onPressed: canAddNewItem
              ? () {
                  useTodoStore().addedNewItem();
                }
              : null,
        ),
      ),
    );

    return StoreListener(
      [
        useTodoStore().listen(
          (context, state) {},
          condition: (prev, next) => prev.draft != next.draft,
        ),
      ],
      child: field,
    );
  }
}
