import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/repositories/flashcard_import_support.dart';
import 'package:memox/domain/value_objects/content_actions.dart';

void main() {
  test(
    'DT1 parseRows: auto detects slash separated vocabulary lines before colon text',
    () {
      final preparation = FlashcardImportSupport.parse(
        format: ImportSourceFormat.structuredText,
        rawContent: '''
개다 Clear up / Quang đãng (Động từ, chỉ hiện tượng trời đang mưa hoặc nhiều mây trở nên quang đãng)
고민하다 To worry / Lo lắng, trăn trở (Động từ, âm Hán Việt: Khổ muộn)
''',
      );

      expect(preparation.issues, isEmpty);
      expect(preparation.previewItems, hasLength(2));
      expect(preparation.previewItems.first.draft.front, '개다 Clear up');
      expect(
        preparation.previewItems.first.draft.back,
        'Quang đãng (Động từ, chỉ hiện tượng trời đang mưa hoặc nhiều mây trở nên quang đãng)',
      );
      expect(preparation.previewItems.last.draft.front, '고민하다 To worry');
      expect(
        preparation.previewItems.last.draft.back,
        contains('âm Hán Việt: Khổ muộn'),
      );
    },
  );

  test('DT2 parseRows: explicit tab separator parses one card per line', () {
    final preparation = FlashcardImportSupport.parse(
      format: ImportSourceFormat.structuredText,
      structuredTextSeparator: ImportStructuredTextSeparator.tab,
      rawContent: '안녕\tHello\n감사\tThanks',
    );

    expect(preparation.issues, isEmpty);
    expect(preparation.previewItems.map((item) => item.draft.front), [
      '안녕',
      '감사',
    ]);
    expect(preparation.previewItems.map((item) => item.draft.back), [
      'Hello',
      'Thanks',
    ]);
  });

  test('DT3 parseRows: empty CSV returns a line one validation issue', () {
    final preparation = FlashcardImportSupport.parse(
      format: ImportSourceFormat.csv,
      rawContent: '\n\n',
    );

    expect(preparation.previewItems, isEmpty);
    expect(preparation.issues, hasLength(1));
    expect(preparation.issues.single.lineNumber, 1);
    expect(preparation.issues.single.message, 'CSV content is empty.');
    expect(preparation.canCommit, isFalse);
  });

  test(
    'DT4 parseRows: CSV missing required header returns a line one issue',
    () {
      final preparation = FlashcardImportSupport.parse(
        format: ImportSourceFormat.csv,
        rawContent: 'term,note\nhello,greeting',
      );

      expect(preparation.previewItems, isEmpty);
      expect(preparation.issues, hasLength(1));
      expect(preparation.issues.single.lineNumber, 1);
      expect(
        preparation.issues.single.message,
        'CSV header must include front and back columns.',
      );
    },
  );

  test(
    'DT5 parseRows: CSV row missing back keeps valid preview and reports line',
    () {
      final preparation = FlashcardImportSupport.parse(
        format: ImportSourceFormat.csv,
        rawContent: 'front,back\nhello,xin chao\nbroken,',
      );

      expect(preparation.previewItems, hasLength(1));
      expect(preparation.previewItems.single.sourceLabel, 'Line 2');
      expect(preparation.previewItems.single.draft.front, 'hello');
      expect(preparation.issues, hasLength(1));
      expect(preparation.issues.single.lineNumber, 3);
      expect(preparation.issues.single.message, 'front and back are required.');
      expect(preparation.canCommit, isFalse);
    },
  );

  test(
    'DT6 parseRows: structured block missing Back reports the block start line',
    () {
      final preparation = FlashcardImportSupport.parse(
        format: ImportSourceFormat.structuredText,
        rawContent: 'Front: hello\nNote: greeting',
      );

      expect(preparation.previewItems, isEmpty);
      expect(preparation.issues, hasLength(1));
      expect(preparation.issues.single.lineNumber, 1);
      expect(
        preparation.issues.single.message,
        'Each block must include Front: and Back: lines.',
      );
    },
  );

  test(
    'DT1 onUpdate: explicit colon separator preserves later colons in the answer',
    () {
      final preparation = FlashcardImportSupport.parse(
        format: ImportSourceFormat.structuredText,
        structuredTextSeparator: ImportStructuredTextSeparator.colon,
        rawContent: '고민하다: Lo lắng, âm Hán Việt: Khổ muộn',
      );

      expect(preparation.issues, isEmpty);
      expect(preparation.previewItems.single.draft.front, '고민하다');
      expect(
        preparation.previewItems.single.draft.back,
        'Lo lắng, âm Hán Việt: Khổ muộn',
      );
    },
  );

  test(
    'DT1 onNavigate: auto keeps existing Front Back block format compatible',
    () {
      final preparation = FlashcardImportSupport.parse(
        format: ImportSourceFormat.structuredText,
        rawContent: 'Front: hello\nBack: xin chao\nNote: greeting',
      );

      expect(preparation.issues, isEmpty);
      expect(preparation.previewItems.single.draft.front, 'hello');
      expect(preparation.previewItems.single.draft.back, 'xin chao');
      expect(preparation.previewItems.single.draft.note, 'greeting');
    },
  );

  test(
    'DT2 onNavigate: auto detects pipe-delimited rows with source labels',
    () {
      final preparation = FlashcardImportSupport.parse(
        format: ImportSourceFormat.structuredText,
        rawContent: 'hello | xin chao\nbye | tam biet',
      );

      expect(preparation.issues, isEmpty);
      expect(preparation.previewItems.map((item) => item.sourceLabel), <String>[
        'Line 1',
        'Line 2',
      ]);
      expect(preparation.previewItems.map((item) => item.draft.front), <String>[
        'hello',
        'bye',
      ]);
      expect(preparation.previewItems.map((item) => item.draft.back), <String>[
        'xin chao',
        'tam biet',
      ]);
    },
  );
}
