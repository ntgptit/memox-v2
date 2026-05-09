# Policies

Thư mục chứa các chính sách (policy) kiểm tra mã nguồn cho từng dự án.

## Cấu trúc một policy

Mỗi policy là một thư mục con chứa ít nhất:

```
policies/<ten_policy>/
├── config.yaml          # Cấu hình chung: project, scopes, families, profiles, exit_policy
├── messages.yaml        # (Tùy chọn) Catalog thông báo đa ngôn ngữ
├── suppressions.yaml    # (Tùy chọn) Suppressions toàn cục
├── *_rules.yaml         # Các file định nghĩa quy tắc
```

## Các policy hiện có

| Thư mục | Mô tả |
|---------|-------|
| `_template/` | Chính sách mẫu tối thiểu — điểm khởi đầu cho policy mới |
| `memox/` | Policy cho dự án MemoX (Flutter/Dart) — đầy đủ các rule về kiến trúc, coding, UI, state management |
| `spaced_learning_app/` | Policy cho dự án Spaced Learning App (Flutter/Dart) — tương tự MemoX, tuỳ chỉnh theo cấu trúc riêng |

## Tạo policy mới

1. Sao chép `_template/` thành thư mục mới.
2. Chỉnh sửa `config.yaml`: tên dự án, `root_marker`, scopes, families, profiles.
3. Viết các file `*_rules.yaml` định nghĩa quy tắc cho dự án.
4. Chạy: `python guard/run.py --policy <ten_moi>`

## Quy tắc trong YAML

Mỗi quy tắc khai báo: `id`, `type`, `name`, `description`, `severity`, `scope`, `params`, v.v.

Các `type` đơn giản (`forbidden_pattern`, `required_pattern`, `forbidden_token`, `naming_convention`) chỉ cần YAML.
Các `type` phức tạp (`ast_check`, `project_check`, `import_direction`, `structural_check`) cần matcher Python tương ứng trong `engine/matchers/`.

Xem ví dụ chi tiết trong `_template/coding_rules.yaml` và các policy `memox/`, `spaced_learning_app/`.
