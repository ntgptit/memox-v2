import 'dart:typed_data';

import 'package:archive/archive.dart';
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
    'DT7 parseRows: Excel with header reads fixed A B C columns after row one',
    () {
      final preparation = FlashcardImportSupport.parse(
        format: ImportSourceFormat.excel,
        rawContent: '',
        sourceBytes: _xlsxBytes(
          worksheetRows: '''
<row r="1">
  <c r="A1" t="inlineStr"><is><t>Korean</t></is></c>
  <c r="B1" t="inlineStr"><is><t>Meaning</t></is></c>
  <c r="C1" t="inlineStr"><is><t>Memo</t></is></c>
</row>
<row r="2">
  <c r="A2" t="inlineStr"><is><t>개다</t></is></c>
  <c r="B2" t="inlineStr"><is><t>Clear up</t></is></c>
  <c r="C2" t="inlineStr"><is><t>weather phrase</t></is></c>
</row>
<row r="3">
  <c r="A3" t="inlineStr"><is><t>고민하다</t></is></c>
  <c r="B3" t="inlineStr"><is><t></t></is></c>
</row>
''',
        ),
        excelHasHeader: true,
      );

      expect(preparation.format, ImportSourceFormat.excel);
      expect(preparation.previewItems, hasLength(1));
      expect(preparation.previewItems.single.sourceLabel, 'Row 2');
      expect(preparation.previewItems.single.draft.front, '개다');
      expect(preparation.previewItems.single.draft.back, 'Clear up');
      expect(preparation.previewItems.single.draft.note, 'weather phrase');
      expect(preparation.issues, hasLength(1));
      expect(preparation.issues.single.lineNumber, 3);
      expect(preparation.issues.single.message, 'front and back are required.');
      expect(preparation.canCommit, isFalse);
    },
  );

  test('DT8 parseRows: Excel without header imports A1 as the first front', () {
    final preparation = FlashcardImportSupport.parse(
      format: ImportSourceFormat.excel,
      rawContent: '',
      sourceBytes: _xlsxBytes(
        worksheetRows: '''
<row r="1">
  <c r="A1" t="inlineStr"><is><t>개다</t></is></c>
  <c r="B1" t="inlineStr"><is><t>Clear up</t></is></c>
  <c r="C1" t="inlineStr"><is><t>weather phrase</t></is></c>
</row>
<row r="2">
  <c r="A2" t="inlineStr"><is><t>고민하다</t></is></c>
  <c r="B2" t="inlineStr"><is><t></t></is></c>
</row>
''',
      ),
      excelHasHeader: false,
    );

    expect(preparation.format, ImportSourceFormat.excel);
    expect(preparation.previewItems, hasLength(1));
    expect(preparation.previewItems.single.sourceLabel, 'Row 1');
    expect(preparation.previewItems.single.draft.front, '개다');
    expect(preparation.previewItems.single.draft.back, 'Clear up');
    expect(preparation.previewItems.single.draft.note, 'weather phrase');
    expect(preparation.issues, hasLength(1));
    expect(preparation.issues.single.lineNumber, 2);
    expect(preparation.issues.single.message, 'front and back are required.');
    expect(preparation.canCommit, isFalse);
  });

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

Uint8List _xlsxBytes({required String worksheetRows}) {
  final archive = Archive()
    ..addFile(
      ArchiveFile.string('xl/workbook.xml', '''
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheets>
    <sheet name="Sheet1" sheetId="1" r:id="rId1"/>
  </sheets>
</workbook>
'''),
    )
    ..addFile(
      ArchiveFile.string('xl/_rels/workbook.xml.rels', '''
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1"
    Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet"
    Target="worksheets/sheet1.xml"/>
</Relationships>
'''),
    )
    ..addFile(
      ArchiveFile.string('xl/worksheets/sheet1.xml', '''
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <sheetData>
    $worksheetRows
  </sheetData>
</worksheet>
'''),
    );

  return ZipEncoder().encodeBytes(archive);
}
