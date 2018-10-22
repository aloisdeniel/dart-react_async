// Based on work from : 
// https://github.com/flutter/flutter 
// Copyright 2015 The Chromium Authors. All rights reserved.

import 'package:meta/meta.dart';
import 'hash_codes.dart' show hashValues;

/// The state of connection to an asynchronous computation.
///
/// See also:
///
/// * [AsyncSnapshot], which augments a connection state with information
/// received from the asynchronous computation.
enum ConnectionState {
  /// Not currently connected to any asynchronous computation.
  ///
  /// For example, a [FutureBuilder] whose [FutureBuilder.future] is null.
  none,

  /// Connected to an asynchronous computation and awaiting interaction.
  waiting,

  /// Connected to an active asynchronous computation.
  ///
  /// For example, a [Stream] that has returned at least one value, but is not
  /// yet done.
  active,

  /// Connected to a terminated asynchronous computation.
  done,
}

/// Immutable representation of the most recent interaction with an asynchronous
/// computation.
///
/// See also:
///
/// * [StreamBuilder], which builds itself based on a snapshot from interacting
///   with a [Stream].
/// * [FutureBuilder], which builds itself based on a snapshot from interacting
///   with a [Future].
@immutable
class AsyncSnapshot<T> {
  /// Creates an [AsyncSnapshot] with the specified [connectionState],
  /// and optionally either [data] or [error] (but not both).
  const AsyncSnapshot._(this.connectionState, this.data, this.error)
      : assert(connectionState != null),
        assert(!(data != null && error != null));

  /// Creates an [AsyncSnapshot] in [ConnectionState.none] with null data and error.
  const AsyncSnapshot.nothing() : this._(ConnectionState.none, null, null);

  /// Creates an [AsyncSnapshot] in the specified [state] and with the specified [data].
  const AsyncSnapshot.withData(ConnectionState state, T data) : this._(state, data, null);

  /// Creates an [AsyncSnapshot] in the specified [state] and with the specified [error].
  const AsyncSnapshot.withError(ConnectionState state, Object error) : this._(state, null, error);

  /// Current state of connection to the asynchronous computation.
  final ConnectionState connectionState;

  /// The latest data received by the asynchronous computation.
  ///
  /// If this is non-null, [hasData] will be true.
  ///
  /// If [error] is not null, this will be null. See [hasError].
  ///
  /// If the asynchronous computation has never returned a value, this may be
  /// set to an initial data value specified by the relevant widget. See
  /// [FutureBuilder.initialData] and [StreamBuilder.initialData].
  final T data;

  /// Returns latest data received, failing if there is no data.
  ///
  /// Throws [error], if [hasError]. Throws [StateError], if neither [hasData]
  /// nor [hasError].
  T get requireData {
    if (hasData)
      return data;
    if (hasError)
      throw error;
    throw StateError('Snapshot has neither data nor error');
  }

  /// The latest error object received by the asynchronous computation.
  ///
  /// If this is non-null, [hasError] will be true.
  ///
  /// If [data] is not null, this will be null.
  final Object error;

  /// Returns a snapshot like this one, but in the specified [state].
  ///
  /// The [data] and [error] fields persist unmodified, even if the new state is
  /// [ConnectionState.none].
  AsyncSnapshot<T> inState(ConnectionState state) => AsyncSnapshot<T>._(state, data, error);

  /// Returns whether this snapshot contains a non-null [data] value.
  ///
  /// This can be false even when the asynchronous computation has completed
  /// successfully, if the computation did not return a non-null value. For
  /// example, a [Future<void>] will complete with the null value even if it
  /// completes successfully.
  bool get hasData => data != null;

  /// Returns whether this snapshot contains a non-null [error] value.
  ///
  /// This is always true if the asynchronous computation's last result was
  /// failure.
  bool get hasError => error != null;

  @override
  String toString() => '$runtimeType($connectionState, $data, $error)';

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other))
      return true;
    if (other is! AsyncSnapshot<T>)
      return false;
    final AsyncSnapshot<T> typedOther = other;
    return connectionState == typedOther.connectionState
        && data == typedOther.data
        && error == typedOther.error;
  }

  @override
  int get hashCode => hashValues(connectionState, data, error);
}