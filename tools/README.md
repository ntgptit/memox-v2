# Code Verification Guard

Guard Engine v3 — Công cụ kiểm tra và phân tích tĩnh mã nguồn dựa trên chính sách (policy), được viết bằng Python.

## Tổng quan

Dự án này cung cấp một **engine kiểm tra mã nguồn dựa trên chính sách** (policy-driven), quét mã nguồn theo các quy tắc có thể cấu hình, phát hiện vi phạm và báo cáo ở nhiều định dạng. Công cụ được thiết kế để thực thi quy ước viết mã (coding conventions), các ràng buộc kiến trúc, hợp đồng cấu trúc dự án và các mẫu tuỳ chỉnh trên toàn bộ codebase.

**Các tính năng chính:**

- **Quy tắc dựa trên chính sách** — Định nghĩa quy tắc trong các file YAML và tổ chức thành các chính sách (policy) có thể tái sử dụng.
- **Nhiều loại quy tắc** — So khớp mẫu (pattern matching), kiểm tra AST, cấm token, kiểm soát hướng import, quy ước đặt tên, kiểm tra tồn tại file, kiểm tra cấu trúc, v.v.
- **Phạm vi & mục tiêu** — Kiểm soát chính xác file nào được quét bởi từng quy tắc thông qua phạm vi dựa trên glob.
- **Hồ sơ (Profiles)** — Chuyển đổi giữa các bộ quy tắc được định nghĩa trước (ví dụ: `baseline`, `standard`, `strict`, `ci`).
- **Loại bỏ cảnh báo (Suppression)** — Loại bỏ vi phạm ngay trong dòng code hoặc theo từng file bằng các marker comment.
- **Hỗ trợ Baseline** — Lưu các vi phạm đã biết và chỉ báo cáo vi phạm mới (`--baseline-diff`).
- **Nhiều định dạng đầu ra** — Terminal (dễ đọc cho người dùng), JSON và Markdown.
- **Chính sách thoát (Exit policies)** — Cấu hình ngưỡng lỗi theo từng môi trường (`local`, `ci`, `release`).

## Cấu trúc dự án

```
code-verification-guard/
├── guard/
│   ├── run.py                  # Điểm vào CLI
│   ├── requirements.txt        # Các phụ thuộc Python
│   ├── engine/                 # Các module lõi của engine
│   │   ├── runner.py           # Điều phối việc quét và thực thi quy tắc
│   │   ├── config_loader.py    # Tải cấu hình policy và quy tắc từ YAML
│   │   ├── rule_executor.py    # Thực thi từng quy tắc
│   │   ├── file_scanner.py     # Xác định tập file từ các phạm vi
│   │   ├── reporter.py         # Định dạng và xuất kết quả
│   │   ├── models.py           # Các mô hình dữ liệu (Rule, Violation, GuardResult, ...)
│   │   ├── baseline.py         # Quản lý snapshot baseline
│   │   ├── suppression.py      # Kiểm tra suppression (inline & theo file)
│   │   ├── exit_policy.py      # Xác định mã thoát dựa trên môi trường
│   │   ├── formatters/         # Các bộ định dạng đầu ra
│   │   ├── matchers/           # Các bộ so khớp quy tắc
│   │   └── ...
│   ├── policies/               # Các định nghĩa chính sách
│   │   ├── _template/          # Chính sách mẫu (ví dụ khởi đầu)
│   │   ├── memox/              # Ví dụ: chính sách dự án Memox
│   │   └── spaced_learning_app/# Ví dụ: chính sách dự án Spaced Learning App
│   └── tests/                  # Các bài kiểm thử đơn vị
└── README.md
```

## Yêu cầu tiên quyết

- Python 3.10+
- `pyyaml>=6.0`
- `rich>=13.0`

## Cài đặt

```bash
pip install -r guard/requirements.txt
```

## Sử dụng

Chạy Guard từ thư mục gốc của repository hoặc bất kỳ thư mục nào:

```bash
python guard/run.py --policy <TEN_POLICY> [TUY_CHON]
```

### Tham số bắt buộc

- `--policy <ten>` — Tên thư mục chính sách nằm trong `guard/policies/`.

### Tham số tùy chọn

| Cờ | Mô tả |
|------|-------------|
| `-f, --family <ten>` | Chỉ chạy các quy tắc thuộc family chỉ định. |
| `-r, --rule <ids>` | Chỉ chạy các quy tắc có ID cụ thể (phân cách bằng dấu phẩy). |
| `-s, --scope <ten>` | Ghi đè phạm vi mặc định cho các quy tắc được so khớp. |
| `-p, --profile <ten>` | Sử dụng một profile được định nghĩa trước trong cấu hình policy. |
| `-e, --env <moi_truong>` | Môi trường cho chính sách thoát (`local`, `ci`, `release`). Mặc định: `local`. |
| `--max-cost <chi_phi>` | Chi phí tối đa của quy tắc được chạy (`low`, `medium`, `high`). Mặc định: `high`. |
| `--format <dinh_dang>` | Định dạng đầu ra: `terminal` (mặc định), `json`, `markdown`. |
| `-o, --output <duong_dan>` | Ghi kết quả ra file thay vì stdout. |
| `-v, --verbose` | Bao gồm thêm chi tiết (ví dụ: số file quét, thời gian thực thi). |
| `-l, --list` | Liệt kê tất cả các quy tắc cùng trạng thái thay vì chạy chúng. |
| `--baseline-save` | Lưu kết quả hiện tại làm snapshot baseline. |
| `--baseline-diff` | Chỉ báo cáo các vi phạm mới so với baseline đã lưu. |
| `--project-root <duong_dan>` | Thiết lập rõ ràng thư mục gốc của dự án. |
| `--locale <ma>` | Ngôn ngữ của catalog thông báo. Mặc định: `en`. |

### Ví dụ

```bash
# Chạy tất cả quy tắc trong policy memox
python guard/run.py --policy memox

# Chỉ chạy family "coding" với chi phí tối đa medium
python guard/run.py --policy memox -f coding --max-cost medium

# Chạy một quy tắc cụ thể
python guard/run.py --policy memox -r forbidden_print

# Sử dụng profile CI và xuất JSON ra file
python guard/run.py --policy memox -p ci --format json -o report.json

# Liệt kê tất cả các quy tắc có sẵn
python guard/run.py --policy memox -l

# Chỉ hiển thị vi phạm mới so với baseline đã lưu
python guard/run.py --policy memox --baseline-diff
```

## Cấu hình Policy

Mỗi policy là một thư mục nằm trong `guard/policies/<ten>/`, chứa ít nhất một file `config.yaml`.

### File `config.yaml` tối thiểu

```yaml
project:
  name: "My Project Guard"
  root_marker: "pubspec.yaml"     # File dùng để tự động phát hiện gốc dự án
  language: "dart"
  file_extension: ".dart"

rule_files:
  - coding_rules.yaml

scopes:
  all:
    roots: ["lib"]
    include: ["**/*.dart"]
    exclude:
      - "**/*.g.dart"
      - "**/*.freezed.dart"

families:
  coding:
    name: "Coding Conventions"

profiles:
  standard:
    families: [coding]
    max_cost: low

exit_policy:
  local:
    fail_on: [error, critical]
    max_warnings: -1
  ci:
    fail_on: [warning, error, critical]
    max_warnings: 10

versioning:
  engine_version: "3.0.0"
  policy_version: "1.0.0"
  rule_schema_version: 1
```

### Các file quy tắc

Các quy tắc được khai báo trong các file YAML được liệt kê tại `rule_files`. Mỗi quy tắc bao gồm:

- `id`, `name`, `description`, `severity`, `family`
- `type` — Loại matcher (ví dụ: `forbidden_pattern`, `ast_check`, `file_existence`)
- `scope` — Phạm vi đã định nghĩa để quét
- `targets` / `exclude` — Bộ lọc file bổ sung
- `params` — Các tham số riêng của matcher
- `meta` — Siêu dữ liệu (chi phí, có thể tự động sửa, tags, v.v.)
- `docs` — Liên kết tài liệu / chủ sở hữu

Ví dụ đoạn quy tắc:

```yaml
rules:
  - id: no_print_statements
    name: "No Print Statements"
    description: "Tránh để lại các lệnh print gỡ lỗi trong mã production."
    family: coding
    severity: warning
    type: forbidden_pattern
    scope: all
    params:
      patterns:
        - "print("
      skip_comments: true
    meta:
      cost: low
      auto_fixable: false
      tags: [debug, cleanup]
```

### Các loại quy tắc được hỗ trợ

Engine hỗ trợ nhiều bộ so khớp (matcher) tích hợp sẵn, bao gồm nhưng không giới hạn:

- `forbidden_pattern` — Quét bằng regex/glob pattern.
- `forbidden_token` — Phát hiện token hoặc cú pháp cụ thể.
- `required_pattern` — Bắt buộc một mẫu phải tồn tại.
- `required_any_token` — Yêu cầu ít nhất một trong nhiều token.
- `required_in_class` — Yêu cầu thành phần ở cấp lớp (class-level).
- `forbidden_imports` / `import_direction` — Quy tắc về import và phụ thuộc.
- `naming_convention` — Thực thi phong cách đặt tên.
- `file_existence` / `path_structure` — Kiểm tra cấu trúc dự án.
- `ast_check` — Kiểm tra cấu trúc dựa trên AST.
- `project_check` — Các khẳng định xuyên file hoặc toàn dự án.
- `structural_check` — Các kiểm tra cấu trúc phức tạp.

## Loại bỏ cảnh báo (Suppressions)

Loại bỏ vi phạm ngay trong mã nguồn bằng các marker comment:

```dart
// guard-ignore-next-line: no_print_statements
print('debug');

// guard-ignore: no_print_statements
someLegacyCall(); // bao phủ nhiều dòng

// Ở đầu file:
// guard-ignore-file: no_print_statements, deprecated_api
```

Các suppression toàn cục cũng có thể được khai báo trong file `suppressions.yaml` của policy.

## Quy trình Baseline

1. **Lưu baseline** sau lần chạy đầu tiên:
   ```bash
   python guard/run.py --policy memox --baseline-save
   ```
2. **So sánh với baseline** trong các lần chạy sau:
   ```bash
   python guard/run.py --policy memox --baseline-diff
   ```
   Chỉ các vi phạm *mới* kể từ baseline đã lưu sẽ được báo cáo.

## Các định dạng đầu ra

- **terminal** — Bảng màu đẹp, dễ đọc khi sử dụng tương tác.
- **json** — Đầu ra dạng máy đọc, lý tưởng cho tích hợp CI.
- **markdown** — Báo cáo có cấu trúc, phù hợp cho bình luận PR hoặc tài liệu.

## Kiểm thử

Các bài kiểm thử đơn vị nằm trong `guard/tests/`:

```bash
python -m pytest guard/tests/
```

## Giấy phép

Dự án được cung cấp nguyên trạng (as-is) cho các quy trình kiểm soát chất lượng mã nội bộ.

---

Để biết thêm chi tiết, hãy tham khảo các ví dụ policy trong thư mục `guard/policies/` và các module engine trong `guard/engine/`.
