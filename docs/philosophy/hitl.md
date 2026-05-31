# HITL — Human In The Loop

> AI đề xuất. Con người chốt những gì rủi ro cao.

## Vấn đề

Trao toàn quyền cho AI Agent ở các hành động không hồi phục được (xóa dữ liệu, deploy production, đổi schema) là rủi ro không chấp nhận được. Nhưng bắt con người làm tay mọi thứ thì mất hết lợi ích của tự động hóa.

## Giải pháp — Mô hình phân vai 3 nhóm

| Nhóm | Ý nghĩa | Ví dụ |
|---|---|---|
| **[Người]** | Con người tự quyết, AI không được tự thực hiện | Merge, deploy, đổi schema, chốt scope, chốt risk level |
| **[AI→duyệt]** | AI sinh toàn bộ bản nháp, người review & phê duyệt mới có hiệu lực | spec, plan, tasks, ADR, kiến trúc, release note, evidence UAT |
| **[AI]** | Việc cơ học, ít rủi ro — AI tự làm, người giám sát | scaffold repo, sinh script/CI, tạo skeleton, chạy verify harness |

## Các hành động BẮT BUỘC con người phê duyệt

```
□ Deploy / Release production
□ Schema migration
□ Thay đổi security policy / nâng quyền
□ Xóa dữ liệu
□ Thay đổi hạ tầng
□ Approve PR / Merge code
□ Chốt scope chính thức
□ Nghiệm thu spec / feature
□ Chốt risk level (chỉ Tech Lead)
```

## Cách thể hiện HITL

HITL được thực hiện bằng approve/comment/đổi status trên Git Platform hoặc phê duyệt chính thức trên spec — **không bằng tin nhắn chat**.

## Phân tầng theo Risk Level

Mức độ kiểm soát tỉ lệ thuận với rủi ro: Low → Medium → High → Critical. Risk càng cao, càng nhiều cổng phê duyệt (multi-approval, rollback plan, post-release verification). Khi không chắc chắn → chọn mức cao hơn.
