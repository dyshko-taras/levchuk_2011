/// Environment flags.
class Env {
  const Env._();

  /// True when built with `--dart-define=prod=true`.
  static const bool isProd = bool.fromEnvironment('prod');
}
