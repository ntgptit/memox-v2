import '../../../../../domain/enums/study_enums.dart';

class StudyAnswerSubmission {
  const StudyAnswerSubmission({
    required this.grade,
    this.submittedAnswer,
    this.selectedOptionId,
  });

  final AttemptGrade grade;
  final String? submittedAnswer;
  final String? selectedOptionId;
}

class StudyAnswerFeedback {
  const StudyAnswerFeedback({
    required this.itemId,
    required this.selectedGrade,
    required this.isCorrect,
    required this.correctAnswer,
    this.submittedAnswer,
    this.selectedOptionId,
  });

  final String itemId;
  final AttemptGrade selectedGrade;
  final bool isCorrect;
  final String correctAnswer;
  final String? submittedAnswer;
  final String? selectedOptionId;

  StudyAnswerFeedback copyWith({
    String? itemId,
    AttemptGrade? selectedGrade,
    bool? isCorrect,
    String? correctAnswer,
    String? submittedAnswer,
    String? selectedOptionId,
  }) {
    return StudyAnswerFeedback(
      itemId: itemId ?? this.itemId,
      selectedGrade: selectedGrade ?? this.selectedGrade,
      isCorrect: isCorrect ?? this.isCorrect,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      submittedAnswer: submittedAnswer ?? this.submittedAnswer,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
    );
  }

  StudyAnswerFeedback markCorrected() {
    final correctedGrade = selectedGrade == AttemptGrade.forgot
        ? AttemptGrade.remembered
        : AttemptGrade.correct;
    return copyWith(selectedGrade: correctedGrade, isCorrect: true);
  }
}
