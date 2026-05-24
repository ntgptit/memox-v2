part of 'study_repo_impl.dart';

final class _SqlScope {
  const _SqlScope({required this.whereClause, required this.variables});

  final String whereClause;
  final List<Variable> variables;
}

final class _SrsOutcome {
  const _SrsOutcome({
    required this.result,
    required this.oldBox,
    required this.newBox,
    required this.nextDueAt,
    required this.lapseDelta,
  });

  final ReviewResult result;
  final int oldBox;
  final int newBox;
  final int nextDueAt;
  final int lapseDelta;
}
