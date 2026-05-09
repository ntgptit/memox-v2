# Engine

Module lõi của Guard Engine — điều phối việc đọc cấu hình, quét file, thực thi quy tắc và xuất kết quả.

## Các module chính

| File | Chức năng |
|------|-----------|
| `runner.py` | Điều phối toàn bộ quy trình: tải config, lọc rule, quét file, thực thi, lọc suppression/baseline |
| `config_loader.py` | Đọc `config.yaml` và các file quy tắc (`*_rules.yaml`) của policy |
| `rule_executor.py` | Gọi matcher phù hợp cho từng rule và trang trí (decorate) kết quả |
| `rule_registry.py` | Ánh xạ `rule.type` → hàm xử lý (matcher) tương ứng |
| `file_scanner.py` | Giải pháp phạm vi (scope) thành danh sách file cụ thể |
| `reporter.py` | Điều phối định dạng đầu ra (terminal/json/markdown) |
| `models.py` | Các lớp dữ liệu: `Rule`, `Violation`, `GuardResult`, `Severity`, ... |
| `baseline.py` | Lưu/tải snapshot baseline để so sánh vi phạm mới |
| `suppression.py` | Kiểm tra suppression theo file và inline |
| `exit_policy.py` | Quyết định mã thoát (exit code) dựa trên môi trường |
| `message_catalog.py` | Đọc `messages.yaml` và thay thế thông báo theo locale |
| `schema_validator.py` | Kiểm tra cú pháp rule YAML |
| `constants.py` | Hằng số: tên file, khóa config, giá trị mặc định |

## Các thư mục con

- **`matchers/`** — Các bộ so khớp quy tắc (xem `matchers/README.md`)
- **`formatters/`** — Các bộ định dạng kết quả (xem `formatters/README.md`)

## Luồng hoạt động

1. `Runner` khởi tạo → `ConfigLoader` đọc policy
2. `Runner.run()` lọc rule theo family/profile/max-cost
3. Với mỗi rule, `FileScanner.resolve_scope()` xác định tập file
4. `RuleExecutor.execute()` chọn matcher từ `RuleRegistry` và chạy
5. `SuppressionChecker` lọc bỏ các vi phạm bị suppression
6. `BaselineManager` lọc chỉ giữ vi phạm mới (nếu `--baseline-diff`)
7. `Reporter.output()` ghi kết quả ra terminal/file theo định dạng
