# Matchers

Các bộ so khớp (matcher) thực thi logic kiểm tra cho từng loại quy tắc.

## Nguyên tắc

- **Chỉ những rule phức tạp** (cần phân tích cấu trúc AST, cross-file, stateful logic) mới viết matcher bằng Python.
- **Rule đơn giản** (chỉ cần regex, tìm token, kiểm tra tên file...) được định nghĩa hoàn toàn trong YAML thông qua `text_matcher.py`.

## Các matcher hiện có

| File | Matcher | Loại quy tắc xử lý | Mức độ phức tạp |
|------|---------|---------------------|-----------------|
| `text_matcher.py` | `TextMatcher` | `forbidden_pattern`, `forbidden_token`, `required_pattern`, `required_any_token`, `naming_convention` | Đơn giản — chỉ regex/tìm chuỗi |
| `structural_matcher.py` | `StructuralMatcher` | `import_direction`, `required_in_class`, `structural_check` | Trung bình — phân tích brace, class body |
| `ast_matcher.py` | `AstMatcher` | `ast_check` | Phức tạp — strip string/comment, block extraction, context analysis |
| `project_matcher.py` | `ProjectMatcher` | `path_structure`, `file_existence`, `project_check` | Trung bình — kiểm tra tồn tại file/thư mục, cross-file analysis |
| `decision_table_matcher.py` | — | `project_check` (decision table) | Phức tạp — phân tích markdown và test coverage |

## Thêm matcher mới

1. Viết hàm xử lý trong file matcher phù hợp (hoặc tạo file mới).
2. Đăng ký trong `rule_registry.py`:
   ```python
   RULE_HANDLERS["my_new_type"] = RuleHandlerSpec(
       mode=HANDLER_MODE_FILE,  # hoặc HANDLER_MODE_PROJECT
       handler=my_handler_function,
   )
   ```
3. Định nghĩa rule trong YAML với `type: my_new_type`.

## Lưu ý quan trọng

- `ast_matcher.py` hiện là file lớn nhất (~3000 dòng) vì chứa nhiều kiểm tra heuristic cho UI rules.
- Các hàm trong `ast_matcher.py` sử dụng `_strip_strings_and_comments_preserve_layout()` để loại bỏ string literal và comment trước khi match, tránh false positive.
