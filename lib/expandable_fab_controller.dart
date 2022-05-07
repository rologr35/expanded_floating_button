library expanded_floating_button;

import 'package:rxdart/rxdart.dart';

class ExpandableFABController {
  late final BehaviorSubject<bool> _toggleController;

  ExpandableFABController() {
    _toggleController = BehaviorSubject();
  }

  Stream<bool> get eventHandlerToggle => _toggleController.stream;

  void toggle() => _toggleController.sink.add(true);

  void dispose() {
    _toggleController.close();
  }
}