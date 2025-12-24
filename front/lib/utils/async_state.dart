sealed class AsyncState<T> {
  const AsyncState();
}

class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading();
}

class AsyncEmpty<T> extends AsyncState<T> {
  const AsyncEmpty();
}

class AsyncData<T> extends AsyncState<T> {
  const AsyncData(this.value);

  final T value;
}

class AsyncError<T> extends AsyncState<T> {
  const AsyncError(
    this.error, {
    this.stackTrace,
  });

  final Object error;
  final StackTrace? stackTrace;
}

extension AsyncStateX<T> on AsyncState<T> {
  bool get isLoading => this is AsyncLoading<T>;
  bool get isEmpty => this is AsyncEmpty<T>;
  bool get hasData => this is AsyncData<T>;
  bool get hasError => this is AsyncError<T>;

  T? get valueOrNull => switch (this) {
        AsyncData(:final value) => value,
        _ => null,
      };
}
