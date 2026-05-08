import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_revision_providers.g.dart';

@Riverpod(keepAlive: true)
class StudySessionDataRevision extends _$StudySessionDataRevision {
  @override
  int build() => 0;

  void bump() {
    state += 1;
  }
}

@Riverpod(keepAlive: true)
class StudySettingsDataRevision extends _$StudySettingsDataRevision {
  @override
  int build() => 0;

  void bump() {
    state += 1;
  }
}
