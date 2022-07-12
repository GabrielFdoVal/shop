import 'package:flutter/cupertino.dart';

class CounterState {
  int _value = 0;
  void inc() => _value++;
  void dec() => _value--;
  int get value => _value;

  bool diff(CounterState old) {
    return old.value != _value;
  }
}

class CounterProvider extends InheritedWidget {
  final CounterState state = CounterState();
  CounterProvider({Key? key, required Widget child})
      : super(key: key, child: child);

  static CounterProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CounterProvider>();
  }

  @override
  bool updateShouldNotify(covariant CounterProvider oldWidget) {
    // ignore: todo
    // TODO: implement updateShouldNotify
    return oldWidget.state.diff(state);
  }
}
