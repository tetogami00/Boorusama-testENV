// Project imports:
import '../booru/booru.dart';

class BooruScaffold extends Booru {
  const BooruScaffold({
    required super.name,
    required super.protocol,
    required this.type,
    required this.sites,
  });

  @override
  final List<String> sites;

  @override
  final BooruType type;
}
