import 'package:json_annotation/json_annotation.dart';

part 'nhl_localized_name.g.dart';

@JsonSerializable()
class NhlLocalizedName {
  const NhlLocalizedName({
    required this.defaultName,
    this.fr,
  });

  factory NhlLocalizedName.fromJson(Map<String, Object?> json) =>
      _$NhlLocalizedNameFromJson(json);

  @JsonKey(name: 'default')
  final String defaultName;

  final String? fr;

  Map<String, Object?> toJson() => _$NhlLocalizedNameToJson(this);
}
