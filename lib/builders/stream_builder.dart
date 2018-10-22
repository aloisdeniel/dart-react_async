// Based on work from : 
// https://github.com/flutter/flutter 
// Copyright 2015 The Chromium Authors. All rights reserved.

import 'dart:async' show Stream, StreamSubscription;

import 'package:react/react.dart';

import '../base/renderers.dart';
import '../base/snapshot.dart';

var _StreamBuilder =  registerComponent(() => _StreamBuilderComponent());

dynamic StreamBuilder<T>({T initialData, Stream<T> stream, dynamic Function(AsyncSnapshot<T>) builder}) {
  return _StreamBuilder({
    'initialData': initialData,
    'stream': stream,
    'builder': uncastRenderer(builder),
  });
}
 
/// A Flutter like StreamBuilder
class _StreamBuilderComponent extends Component {

  /// The asynchronous computation to which this builder is currently connected,
  /// possibly null. When changed, the current summary is updated using
  /// [afterDisconnected], if the previous stream was not null, followed by
  /// [afterConnected], if the new stream is not null.
  Stream get stream  => props['stream'] ?? Stream.empty();

  /// The build strategy currently used by this builder. Cannot be null.
  AsyncComponentRenderer get builder  => props['builder'] ?? (s) => null;

  /// The data that will be used to create the initial snapshot. Null by default.
  dynamic get initialData => props['initialData'] ?? null;

  StreamSubscription _subscription;

  AsyncSnapshot get summary => this.state['summary'] ?? this.initial();

  /// Returns the initial summary of stream interaction, typically representing
  /// the fact that no interaction has happened at all.
  ///
  /// Sub-classes must override this method to provide the initial value for
  /// the fold computation.
  AsyncSnapshot initial() => AsyncSnapshot.withData(ConnectionState.none, this.initialData);


  /// Returns an updated version of the [current] summary reflecting that we
  /// are now connected to a stream.
  ///
  /// The default implementation returns [current] as is.
  AsyncSnapshot afterConnected(AsyncSnapshot current) => current.inState(ConnectionState.waiting);

  /// Returns an updated version of the [current] summary following a data event.
  ///
  /// Sub-classes must override this method to specify how the current summary
  /// is combined with the new data item in the fold computation.
  AsyncSnapshot afterData(AsyncSnapshot current, dynamic data) {
    return AsyncSnapshot.withData(ConnectionState.active, data);
  }

  /// Returns an updated version of the [current] summary following an error.
  ///
  /// The default implementation returns [current] as is.
  AsyncSnapshot afterError(AsyncSnapshot current, Object error) {
    return AsyncSnapshot.withError(ConnectionState.active, error);
  }

  /// Returns an updated version of the [current] summary following stream
  /// termination.
  ///
  /// The default implementation returns [current] as is.
  AsyncSnapshot afterDone(AsyncSnapshot current) => current.inState(ConnectionState.done);

  /// Returns an updated version of the [current] summary reflecting that we
  /// are no longer connected to a stream.
  ///
  /// The default implementation returns [current] as is.
  AsyncSnapshot afterDisconnected(AsyncSnapshot current) => current.inState(ConnectionState.none);

  @override
  void componentWillMount() {
    super.componentWillMount();
    _subscribe();
  }

  @override
  void componentWillUnmount() {
    _unsubscribe();
    super.componentWillUnmount();
  }

  @override
  dynamic render() => this.builder(summary);

  void _subscribe() {
    if (this.stream != null) {
      _subscription = this.stream.listen((dynamic data) {
        setState({
          'summary' : this.afterData(summary, data)
        });
      }, onError: (Object error) {
        setState({
          'summary' : this.afterError(summary, error)
        });
      }, onDone: () {
        setState({
          'summary' : this.afterDone(summary)
        });
      });
      setState({
          'summary' : this.afterConnected(summary)
      });
    }
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }
}