# flutter_zustand

Non-ceremonial. The bear-necessities for state management.

An attempt to bring [Zustand](https://github.com/pmndrs/zustand) to Flutter. This is a work in progress and is not ready for use.

After working with Flutter for 5 years, I've found that state management in flutter is
- Laborious
- Not productive
- Boilerplate heavy
- Often slows down the analyzer as code is generated
- Feels sluggish to type

I found myself saying things like:
- "Oh great, I have to place this in the build context somewhere"
- "Ah darn, I have to run the generator again"

I had the pleasure to work with Zustand on my last project. I was amazed by how quickly I was
able to build features and how easy it was to maintain the code. I want to bring that same
experience to Flutter.

Zustand has the advantage of being written in javascript, which supports reflection. We'll see
if this is possible.

This package aims to provide the following:
- Fast to type
- No boilerplate
- No advantage to using code generation
- No need to place in the build context, but still can support multiple instances
- Productive and easy maintenance
- Handle small and large scale apps gracefully

The ideal API is something like...

```dart
// Store definition
class MyStore extends Store {
  int a = 0;
  int b = 0;

  int get c => a + b;

  void incrementA() {
    set(() => a++);
  }

  void incrementB() {
    set(() => b++);
  }

  Future<void> longTask() async {
    set(() {
      a = 10;
    });
    await Future.delayed(Duration(seconds: 1));
    set(() {
      a = -1;
    });
  }

  @override
  FutureOr<void> init() {
    super.init();
  }

  @override
  FutureOr<void> close() {
    super.close();
  }
}

// registering the stores
void main() {
  registerStore(MyStore());
  // or...
  // registerLazyStore(() => MyStore());
}

// using the store in a widget
Widget build(BuildContext context) {
  final a = use<MyStore>().select(context, (state) => state.a);
  final b = use<MyStore>().select(context, (state) => state.b);
  final c = use<MyStore>().select(context, (state) => state.c);
  final d = use<MyStore>().select(context, (state) => state.a + state.b, equality: (prev, next) => prev == next);

  // I have no idea if this is possible
  // it looks like it is: add listener, if context is unmounted destroy listener
  use<MyStore>().event(
    context,
    (state) {
      showSnackBar('A is now ${state.a}');
    },
    condition: (prev, next) => prev.a == 5 && next.a == 0,
  );

  final view = Button(
    onPressed: () {
      use<MyStore>().incrementA();
    },
  );
}
```