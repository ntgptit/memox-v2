# Retry Loop

> Vòng retry dùng chung cho cả [New Study Flow](./new-study-flow.md) và [SRS Review Flow](./srs-review-flow.md). Khái niệm nền: [Study Concepts](./study-concepts.md).

## Nguyên tắc

Retry loop ép user học đến khi toàn bộ flashcard trong mode hiện tại pass.

## Rule

- lượt đầu dùng toàn bộ batch
- các lượt sau chỉ dùng flashcard fail
- flashcard pass không quay lại trong mode hiện tại
- flashcard fail tiếp tục ở lại retry batch
- retry loop không giới hạn số lượt mặc định

## Điều kiện dừng

Retry loop chỉ dừng khi:

```txt
retryBatch.isEmpty == true
```

Đây là điều kiện **duy nhất**. Không có max retry count.

## Ví dụ minh họa

Batch ban đầu có 10 flashcard. Số lượt dưới đây chỉ là một kịch bản có thể xảy ra.

Lượt 1:

- đúng 6
- sai 4
- retry batch = 4

Lượt 2:

- đúng 2 trong 4
- sai 2
- retry batch = 2

Lượt 3:

- đúng 1 trong 2
- sai 1
- retry batch = 1

Lượt 4:

- đúng 0 trong 1
- sai 1
- retry batch = 1

Lượt 5:

- đúng 1 trong 1
- sai 0
- retry batch = 0

Khi retry batch rỗng:

- mode hiện tại pass
- chuyển bước tiếp theo theo rule của flow hiện tại

## Lưu ý cho dev

- số lượt trong ví dụ chỉ là minh họa
- thực tế có thể là 1 lượt, 3 lượt, 10 lượt hoặc nhiều hơn
- **không hardcode max retry count**
- điều kiện thoát duy nhất là `retryBatch.isEmpty`
- flashcard pass được loại khỏi retry batch ngay trong lượt đang chạy, không đợi cuối lượt

## Tài liệu liên quan

- [Study Concepts](./study-concepts.md)
- [New Study Flow](./new-study-flow.md)
- [SRS Review Flow](./srs-review-flow.md)
- [Study Modes](./study-modes.md)
