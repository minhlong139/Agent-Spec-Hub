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

## Quy tắc viết script (scripts/)

Áp dụng "quy tắc vàng" của Harness Engineering: mỗi lần sửa lỗi để lại cải tiến lâu dài, script không được vỡ vì môi trường khác nhau.

- **Chạy bằng `bash`, không phải `sh`.** Script dùng heredoc/brace-expansion nên `sh` (dash) sẽ lỗi. Luôn có shebang `#!/usr/bin/env bash` và `set -euo pipefail`.
- **Không giả định file ẩn luôn tồn tại.** File ẩn (`.gitignore`, `.github/`) có thể không đi theo khi toolkit được sao chép/đồng bộ. Nếu cần, **tự sinh** thay vì `cp` thẳng.
- **Fail mềm với tác vụ tùy chọn.** Thiếu file tùy chọn (vd `ci.yml`) thì cảnh báo và bỏ qua, không dừng cả script. Chỉ fail cứng với tác vụ cốt lõi.
- **Không phụ thuộc cấu hình máy.** `git commit` khởi tạo dùng identity dự phòng (`-c user.name`/`-c user.email`) để không vỡ khi máy chưa cấu hình global.
- **Test trước khi commit:** chạy `init-project.sh` ra một thư mục tạm và kiểm tra cây kết quả + git log.

## Báo lỗi / đề xuất

Mở Issue với nhãn phù hợp (`bug`, `enhancement`, `docs`, `question`).
