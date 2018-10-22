// Based on work from : 
// https://github.com/flutter/flutter 
// Copyright 2015 The Chromium Authors. All rights reserved.

import 'dart:async';

import 'package:react/react.dart';

import '../base/renderers.dart';
import '../base/snapshot.dart';

var _FutureBuilder =  registerComponent(() => _FutureBuilderComponent());

dynamic FutureBuilder<T>({T initialData, Future<T> future, dynamic Function(AsyncSnapshot<T>) builder}) {
  return _FutureBuilder({
    'initialData': initialData,
    'future': future,
    'builder': uncastRenderer(builder),
  });
}

/// A Flutter like FutureBuilder
class _FutureBuilderComponent extends Component {

  AsyncSnapshot get snapshot  => this.state['snapshot'] ?? AsyncSnapshot.withData(ConnectionState.none, this.initialData);

  /// The build strategy currently used by this builder.
  ///
  /// The builder is provided with an [AsyncSnapshot] object whose
  /// [AsyncSnapshot.connectionState] property will be one of the following
  /// values:
  ///
  ///  * [ConnectionState.none]: [future] is null. The [AsyncSnapshot.data] will
  ///    be set to [initialData], unless a future has previously completed, in
  ///    which case the previous result persists.
  ///
  ///  * [ConnectionState.waiting]: [future] is not null, but has not yet
  ///    completed. The [AsyncSnapshot.data] will be set to [initialData],
  ///    unless a future has previously completed, in which case the previous
  ///    result persists.
  ///
  ///  * [ConnectionState.done]: [future] is not null, and has completed. If the
  ///    future completed successfully, the [AsyncSnapshot.data] will be set to
  ///    the value to which the future completed. If it completed with an error,
  ///    [AsyncSnapshot.hasError] will be true and [AsyncSnapshot.error] will be
  ///    set to the error object.
  AsyncComponentRenderer get builder => props['builder'] ?? (v) => null;

  /// The asynchronous computation to which this builder is currently connected,
  /// possibly null.
  ///
  /// If no future has yet completed, including in the case where [future] is
  /// null, the data provided to the [builder] will be set to [initialData].
  Future get future  => props['future'] ?? Future.value();

  /// The data that will be used to create the snapshots provided until a
  /// non-null [future] has completed.
  ///
  /// If the future completes with an error, the data in the [AsyncSnapshot]
  /// provided to the [builder] will become null, regardless of [initialData].
  /// (The error itself will be available in [AsyncSnapshot.error], and
  /// [AsyncSnapshot.hasError] will be true.)
  dynamic get initialData => props['initialData'] ?? null;

  /// An object that identifies the currently active callbacks. Used to avoid
  /// calling setState from stale callbacks, e.g. after disposal of this state,
  /// or after widget reconfiguration to a new Future.
  Object _activeCallbackIdentity;

  @override
  void componentDidMount() {
    super.componentWillMount();
    _subscribe();
  }

  @override
  void componentWillUnmount() {
    _unsubscribe();
    super.componentWillUnmount();
  }

  @override
  render() => this.builder(snapshot);

  void _subscribe() {
    if (this.future != null) {
      final Object callbackIdentity = Object();
      _activeCallbackIdentity = callbackIdentity;
      this.future.then<void>((dynamic data) {
        if (_activeCallbackIdentity == callbackIdentity) {
          setState({
            'snapshot' : AsyncSnapshot.withData(ConnectionState.done, data)
          });
        }
      }, onError: (Object error) {
        if (_activeCallbackIdentity == callbackIdentity) {
          setState({
            'snapshot' : AsyncSnapshot.withError(ConnectionState.done, error)
          });
        }
      });
      setState({
            'snapshot' : snapshot.inState(ConnectionState.waiting)
      });
    }
  }

  void _unsubscribe() {
    _activeCallbackIdentity = null;
  }
}