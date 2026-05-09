# Policy Template

Chính sách mẫu tối thiểu — điểm khởi đầu để tạo policy mới cho một dự án.

## Các file

| File | Mục đích |
|------|----------|
| `config.yaml` | Cấu hình chung: tên dự án, scopes, families, profiles, exit policy |
| `coding_rules.yaml` | Ví dụ quy tắc đơn giản (`forbidden_token`) |
| `messages.yaml` | Catalog thông báo mẫu |

## Hướng dẫn sử dụng

1. Sao chép toàn bộ thư mục `_template/` thành thư mục mới, ví dụ `policies/my_project/`.
2. Cập nhật `config.yaml`:
   - Thay `name` và `project.name`
   - Điều chỉnh `root_marker` nếu cần
   - Định nghĩa các `scopes`, `families`, `profiles` phù hợp
3. Thêm/xóa các file `*_rules.yaml` theo nhu cầu.
4. Cập nhật `messages.yaml` nếu dùng thông báo tùy chỉnh.
5. Chạy: `python guard/run.py --policy my_project`
