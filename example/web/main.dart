import 'dart:async';
import 'dart:html';
import 'package:react_async/async.dart';
import 'package:react/react.dart';
import 'package:react/react_client.dart' as react_client;
import 'package:react/react_dom.dart' as react_dom;

/// An example model object that exposes a `Future` and a
/// `Stream`. Our components will be able to observe them,
/// and update in accordingly.
class Model {
  Future<String> future() async {
    await Future.delayed(Duration(seconds: 4));
    return "Finished!";
  }

  Stream<String> stream() async* {
    await Future.delayed(Duration(seconds: 1));
    yield "3";
    await Future.delayed(Duration(seconds: 1));
    yield "2";
    await Future.delayed(Duration(seconds: 1));
    yield "1";
    await Future.delayed(Duration(seconds: 1));
    yield "Finished!";
  }
}

/// An example component that will be updated asynchronously 
/// from our model.
class HomeComponent extends Component {
  final Model model = Model();

  /// A component instance that will be refreshed at the end
  /// of the model's future execution.
  dynamic _fromFuture() => FutureBuilder<String>(
    initialData: "Ready...",
    future: this.model.future(),
    builder: (s) => b({}, s.data));

  /// A component instance that will be refreshed on each update
  /// from the model's stream.
  dynamic _fromStream() => StreamBuilder<String>(
    initialData: "Ready...",
    stream: this.model.stream(),
    builder: (s) => b({}, s.data));

  @override
  render() => div({}, [
    div({}, [ "Future:", _fromFuture()]),
    div({}, [ "Stream:", _fromStream()]),
  ]);
}

var Home = registerComponent(() => HomeComponent());

main() {
  react_client.setClientConfiguration();
  react_dom.render(Home({}), querySelector('#react_mount_point'));
}