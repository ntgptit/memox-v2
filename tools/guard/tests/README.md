# Tests

Các bài kiểm thử đơn vị cho Guard Engine.

## Cách chạy

```bash
python -m pytest tools/guard/tests/
```

## Các file kiểm thử

| File | Nội dung kiểm thử |
|------|-------------------|
| `test_decision_table_guard.py` | Kiểm tra matcher phân tích Decision Table — đảm bảo coverage giữa tài liệu markdown và test code |
| `test_lazy_list_guard.py` | Kiểm tra rule lazy list rendering — phát hiện `ListView`/`Column` build eager thay vì dùng builder |
| `test_string_utils_guard.py` | Kiểm tra các hàm tiện ích xử lý chuỗi trong engine |

## Thêm bài kiểm thử mới

1. Tạo file `test_<ten>.py` trong thư mục này.
2. Viết các hàm test theo quy ước pytest:
   ```python
   def test_my_feature():
       # Arrange
       rule = Rule(...)
       # Act
       violations = SomeMatcher.check(rule, "path.dart", lines)
       # Assert
       assert len(violations) == 1
   ```
3. Chạy `pytest tools/guard/tests/test_<ten>.py -v` để kiểm tra.
