# Specs-Driven Development

> Mọi thay đổi code đều bắt nguồn từ một spec đã được phê duyệt.

## Vấn đề

Khi AI Agent coding trực tiếp từ một prompt mơ hồ hoặc trao đổi miệng, kết quả thường lệch ý định, khó review, và không truy vết được "tại sao lại làm như vậy". Context biến mất sau cuộc hội thoại.

## Nguyên tắc

- **Spec là nguồn sự thật**, không phải chat/email/cuộc họp. Mọi quyết định đã chốt phải được ghi vào artifact Spec-Kit hoặc Issue.
- **Không coding từ trao đổi miệng.** Mọi thay đổi code phải liên kết tới một feature/spec trong `specs/`.
- Mỗi feature đi qua các phase tuần tự:

```
specify → design → clarify → plan → tasks → implement → test → uat → deploy
```

## Bộ artifact của một feature

| File | Nội dung |
|---|---|
| `spec.md` | Business spec, user story, acceptance criteria |
| `plan.md` | Technical plan: kiến trúc, API, data |
| `tasks.md` | Phân rã task kèm Definition of Done |
| `research.md` | Giả định, ràng buộc, phân tích |
| `design.md` | UI/UX prototype (nếu có giao diện) |
| `data-model.md` | Schema, ER diagram |
| `contracts/` | API spec, kiểu request/response |
| `quickstart.md` | Hướng dẫn setup, run, verify |

## AI đóng vai trò gì

AI **sinh nháp** cho mọi artifact (spec, plan, tasks), nhưng artifact chỉ có hiệu lực khi con người phụ trách phase đó **phê duyệt** (mô hình "AI làm – người duyệt"). Xem thêm [HITL](hitl.md).
