library expanded_floating_button;

import 'dart:async';

import 'package:flutter/material.dart';
import 'expandable_fab_controller.dart';
import 'expanding_action_button.dart';

class ExpandableFloatingActionButton extends StatefulWidget {
  final bool initialOpen;
  final double distance;
  final double separation;
  final List<Widget> children;
  final Icon icon;
  final ExpandableFABController? controller;
  final ValueChanged<bool>? onChange;

  const ExpandableFloatingActionButton({
    Key? key,
    this.initialOpen = false,
    this.icon = const Icon(Icons.add),
    this.controller,
    this.onChange,
    required this.distance,
    required this.children,
    required this.separation,
  }) : super(key: key);

  @override
  _ExpandableFloatingActionState createState() => _ExpandableFloatingActionState();
}

class _ExpandableFloatingActionState extends State<ExpandableFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _open = false;
  StreamSubscription? _streamSubscriptionToggle;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
    if(widget.controller != null) {
      _streamSubscriptionToggle = widget.controller!.eventHandlerToggle.listen((value) {
        if(value) {
          _toggle();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _streamSubscriptionToggle?.cancel();
    widget.controller?.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    if(widget.onChange != null) {
      widget.onChange!(_open);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    for (var i = 0; i < count; i++) {
      children.add(
        ExpandingActionButton(
          directionInDegrees: 90,
          maxDistance: i == 0 ? widget.distance : widget.distance + widget.separation * i,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        alignment: Alignment.bottomRight,
        transform: Matrix4.diagonal3Values(
          _open ? 0.9 : 1.0,
          _open ? 0.9 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 50),
          child: FloatingActionButton(
            onPressed: _toggle,
            child: widget.icon,
          ),
        ),
      ),
    );
  }
}
