import 'json.dart';

/// A tag on communities and events (`interests` table). Interests are how
/// discovery is organised in Cirqles, so they are a model, not a string.
class Interest {
  const Interest({required this.id, required this.name, required this.slug});

  factory Interest.fromJson(Map<String, Object?> json) => Interest(
        id: Json.requireString(json, 'id'),
        name: Json.requireString(json, 'name'),
        slug: Json.requireString(json, 'slug'),
      );

  final String id;
  final String name;
  final String slug;

  Map<String, Object?> toJson() =>
      <String, Object?>{'id': id, 'name': name, 'slug': slug};
}
