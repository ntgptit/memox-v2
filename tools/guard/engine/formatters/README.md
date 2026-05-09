# Formatters

Các bộ định dạng kết quả đầu ra của Guard Engine.

## Các formatter hiện có

| File | Định dạng | Mô tả |
|------|-----------|-------|
| `terminal_formatter.py` | `terminal` | Bảng màu đẹp, dễ đọc khi chạy tương tác trong terminal. Dùng thư viện `rich`. |
| `json_formatter.py` | `json` | Đầu ra dạng JSON — lý tưởng cho tích hợp CI/CD và xử lý tự động. |
| `markdown_formatter.py` | `markdown` | Báo cáo Markdown có cấu trúc — phù hợp cho bình luận PR hoặc tài liệu. |
| `base_formatter.py` | — | Lớp trừu tượng `BaseFormatter` định nghĩa interface chung. |

## Cách thêm formatter mới

1. Tạo class kế thừa `BaseFormatter`:
   ```python
   class XmlFormatter(BaseFormatter):
       def format(self, results: list[GuardResult], verbose: bool = False) -> str:
           # ... chuyển đổi results thành XML
           return xml_content
   ```
2. Đăng ký trong `reporter.py`:
   ```python
   from .formatters.xml_formatter import XmlFormatter

   _FORMATTERS = {
       "terminal": TerminalFormatter,
       "json": JsonFormatter,
       "markdown": MarkdownFormatter,
       "xml": XmlFormatter,
   }
   ```
3. Sử dụng qua CLI: `--format xml`
