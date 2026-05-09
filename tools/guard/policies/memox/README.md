# Policy: MemoX

Chính sách kiểm tra mã nguồn cho dự án **MemoX** (ứng dụng Flutter).

## Các file quy tắc

| File | Family | Mô tả |
|------|--------|-------|
| `coding_rules.yaml` | `coding` | Quy ước viết mã: import đúng, đặt tên, cấu trúc hàm, tránh pattern nguy hiểm |
| `architecture_rules.yaml` | `architecture` | Kiến trúc lớp: import direction, quy tắc tách layer, đặt tên file screen/provider/route |
| `normalized_rules.yaml` | `normalized` | Chuẩn hóa: cấm StateNotifier, bắt buộc Riverpod code-gen, dùng StringUtils |
| `project_contract.yaml` | `project` | Cấu trúc thư mục bắt buộc, các file must-exist |
| `global_rules.yaml` | `global` | Quy tắc chung: else, hardcoded string/color/fontSize, widget length |
| `legacy_rules.yaml` | `legacy` | Quy tắc cho code legacy: kiểm tra Riverpod syntax |
| `messages.yaml` | — | Thông báo đa ngôn ngữ (Tiếng Anh) |

## Các scope chính

- `all`, `ui`, `features`, `screens`, `domain_files`, `repository_files`, `provider_files`
- `non_legacy_app_source` — chỉ code mới, bỏ qua thư mục legacy

## Chạy kiểm tra

```bash
python guard/run.py --policy memox [tùy_chọn]
```
