# Policy: Spaced Learning App

Chính sách kiểm tra mã nguồn cho dự án **Spaced Learning App** (ứng dụng Flutter).

## Các file quy tắc

| File | Family | Mô tả |
|------|--------|-------|
| `coding_rules.yaml` | `coding` | Quy ước viết mã, import, đặt tên, cấu trúc hàm |
| `architecture_rules.yaml` | `architecture` | Kiến trúc lớp, quy tắc tách layer, cấm import sai |
| `normalized_rules.yaml` | `normalized` | Chuẩn hóa: cấm StateNotifier, bắt buộc Riverpod code-gen |
| `global_rules.yaml` | `global` | Quy tắc chung: else, hardcoded string/color/fontSize |
| `messages.yaml` | — | Thông báo đa ngôn ngữ (Tiếng Anh) |

## Đặc điểm so với MemoX

- Cấu trúc thư mục sử dụng `lib/core/` thay vì `lib/app/` làm gốc DI và routes
- Một số tên quy tắc và pattern khác nhau do cấu trúc dự án khác
- Bỏ qua một số rule đặc thù của MemoX (ví dụ: theme token rules)

## Chạy kiểm tra

```bash
python guard/run.py --policy spaced_learning_app [tùy_chọn]
```
