import 'snapshot.dart';

typedef AsyncComponentRenderer<T> = dynamic Function(AsyncSnapshot<T> snapshot);

AsyncComponentRenderer uncastRenderer<T>(AsyncComponentRenderer<T> builder) {
  return (AsyncSnapshot s) {
      if(s.hasError) {
        return builder(AsyncSnapshot<T>.withError(s.connectionState, s.error));
      }

      if(s.hasData) {
        return builder(AsyncSnapshot<T>.withData(s.connectionState, s.data));
      }
      
      return builder(AsyncSnapshot<T>.nothing());
    };
}