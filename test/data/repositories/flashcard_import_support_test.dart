import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/repositories/flashcard_import_support.dart';
import 'package:memox/domain/value_objects/content_actions.dart';

void main() {
  test('auto detects slash separated vocabulary lines before colon text', () {
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
  });

  test('explicit tab separator parses one card per line', () {
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

  test('explicit colon separator preserves later colons in the answer', () {
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
  });

  test('auto keeps existing Front Back block format compatible', () {
    final preparation = FlashcardImportSupport.parse(
      format: ImportSourceFormat.structuredText,
      rawContent: 'Front: hello\nBack: xin chao\nNote: greeting',
    );

    expect(preparation.issues, isEmpty);
    expect(preparation.previewItems.single.draft.front, 'hello');
    expect(preparation.previewItems.single.draft.back, 'xin chao');
    expect(preparation.previewItems.single.draft.note, 'greeting');
  });
}
