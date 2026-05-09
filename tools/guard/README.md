# Guard Engine

Thư mục này chứa toàn bộ engine kiểm tra mã nguồn và các chính sách (policy) mẫu.

## Cấu trúc

```
guard/
├── run.py              # Điểm vào CLI — chạy engine với tham số từ dòng lệnh
├── requirements.txt    # Các thư viện Python cần thiết
├── engine/             # Module lõi của engine
├── policies/           # Các chính sách kiểm tra cho từng dự án
└── tests/              # Bài kiểm thử đơn vị
```

## Cách chạy

```bash
python guard/run.py --policy <ten_policy> [tuy_chon]
```

Xem thêm tài liệu tổng thể ở `README.md` ở thư mục gốc của dự án.
