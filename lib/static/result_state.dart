sealed class ResultState<T> {
  const ResultState();
}

final class InitialState<T> extends ResultState<T> {
  const InitialState();
}

final class LoadingState<T> extends ResultState<T> {
  const LoadingState();
}

final class LoadedState<T> extends ResultState<T> {
  const LoadedState(this.data);

  final T data;
}

final class NoDataState<T> extends ResultState<T> {
  const NoDataState(this.message);

  final String message;
}

final class ErrorState<T> extends ResultState<T> {
  const ErrorState(this.message);

  final String message;
}
