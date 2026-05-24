import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentMenuIndex extends _$CurrentMenuIndex {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}
