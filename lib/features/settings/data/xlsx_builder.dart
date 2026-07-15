import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

class XlsxSheet {
  final String name;
  final List<String> headers;
  final List<List<String>> rows;
  const XlsxSheet({required this.name, required this.headers, required this.rows});
}

class XlsxBuilder {
  static Uint8List build(List<XlsxSheet> sheets) {
    final archive = Archive();
    _add(archive, '[Content_Types].xml', _contentTypes(sheets.length));
    _add(archive, '_rels/.rels', _rootRels());
    _add(archive, 'xl/workbook.xml', _workbook(sheets));
    _add(archive, 'xl/_rels/workbook.xml.rels', _workbookRels(sheets.length));
    _add(archive, 'xl/styles.xml', _styles());
    for (var i = 0; i < sheets.length; i++) {
      _add(archive, 'xl/worksheets/sheet${i + 1}.xml', _worksheet(sheets[i]));
    }
    final encoded = ZipEncoder().encode(archive);
    return Uint8List.fromList(encoded);
  }

  static void _add(Archive archive, String name, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  static String _contentTypes(int count) {
    final overrides = List.generate(
      count,
      (i) => '<Override PartName="/xl/worksheets/sheet${i + 1}.xml"'
          ' ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>',
    ).join();
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
        '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
        '$overrides</Types>';
  }

  static String _rootRels() =>
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"'
      ' Target="xl/workbook.xml"/></Relationships>';

  static String _workbook(List<XlsxSheet> sheets) {
    final sheetEls = sheets.indexed
        .map((e) => '<sheet name="${_esc(e.$2.name)}" sheetId="${e.$1 + 1}" r:id="rId${e.$1 + 1}"/>')
        .join();
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"'
        ' xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
        '<sheets>$sheetEls</sheets></workbook>';
  }

  static String _workbookRels(int count) {
    final rels = List.generate(
      count,
      (i) => '<Relationship Id="rId${i + 1}"'
          ' Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet"'
          ' Target="worksheets/sheet${i + 1}.xml"/>',
    ).join();
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '$rels'
        '<Relationship Id="rId${count + 1}"'
        ' Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles"'
        ' Target="styles.xml"/></Relationships>';
  }

  static String _styles() =>
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
      '<fonts count="2">'
      '<font><sz val="11"/><name val="Calibri"/></font>'
      '<font><b/><sz val="11"/><name val="Calibri"/></font>'
      '</fonts>'
      '<fills count="2">'
      '<fill><patternFill patternType="none"/></fill>'
      '<fill><patternFill patternType="gray125"/></fill>'
      '</fills>'
      '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>'
      '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
      '<cellXfs count="2">'
      '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
      '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0"/>'
      '</cellXfs></styleSheet>';

  static String _worksheet(XlsxSheet sheet) {
    final buf = StringBuffer();
    _writeRow(buf, 1, sheet.headers, bold: true);
    for (var i = 0; i < sheet.rows.length; i++) {
      _writeRow(buf, i + 2, sheet.rows[i]);
    }
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
        '<sheetData>$buf</sheetData></worksheet>';
  }

  static void _writeRow(StringBuffer sb, int r, List<String> cells, {bool bold = false}) {
    sb.write('<row r="$r">');
    for (var i = 0; i < cells.length; i++) {
      final style = bold ? ' s="1"' : '';
      sb.write('<c r="${_col(i)}$r" t="inlineStr"$style><is><t>${_esc(cells[i])}</t></is></c>');
    }
    sb.write('</row>');
  }

  static String _col(int i) {
    var result = '';
    var n = i;
    do {
      result = String.fromCharCode(65 + n % 26) + result;
      n = n ~/ 26 - 1;
    } while (n >= 0);
    return result;
  }

  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}
