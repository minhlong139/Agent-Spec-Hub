# Đóng góp cho Agent Spec Hub

Cảm ơn bạn đã quan tâm! Toolkit này phục vụ cộng đồng team Dev áp dụng AI Agent vào SDLC.

## Nguyên tắc

- Mọi thay đổi tuân theo chính tư tưởng của toolkit: Specs-Driven, HITL, Harness Engineering.
- Tài liệu viết bằng tiếng Việt; giữ tiếng Anh cho thuật ngữ chuyên ngành và định danh mã nguồn.
- Một PR = một mục tiêu logic. Commit theo Conventional Commits (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`).

## Quy trình

1. Fork & tạo branch `feature/<short-name>` hoặc `fix/<short-name>`.
2. Thực hiện thay đổi. Nếu sửa template, kiểm tra `init-project.sh` vẫn chạy đúng.
3. Chạy `./scripts/verify-pr.sh` trước khi mở PR.
4. Mở PR kèm mô tả rõ ràng: vấn đề, cách giải quyết, ảnh hưởng.

## Thay đổi Constitution template

`docs/constitution.template.md` là lõi của toolkit. Khi sửa:

- Cập nhật `Sync Impact Report` trong block comment đầu file.
- Tăng version theo SemVer (xem mục Governance trong chính file đó).
- Ghi vào `CHANGELOG.md`.

## Báo lỗi / đề xuất

Mở Issue với nhãn phù hợp (`bug`, `enhancement`, `docs`, `question`).
