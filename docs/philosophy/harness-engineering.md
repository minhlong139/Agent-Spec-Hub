# Harness Engineering

> Khi AI thất bại, sửa cái khung quanh nó — đừng vội đổi model.

## Vấn đề

Khi một AI Agent làm sai, phản xạ thường thấy là "đổi model mạnh hơn" hoặc "retry". Cả hai đều không giải quyết gốc rễ, và lỗi sẽ lặp lại với người tiếp theo.

## Nguyên tắc

AI Agent hoạt động tốt hay không phụ thuộc vào **cái khung (harness)** quanh nó: đặc tả task, context được cung cấp, môi trường thực thi, cơ chế verification, và quản lý state. Khi Agent thất bại, kiểm tra theo thứ tự sau **trước khi đổi model**:

| Lớp | Triệu chứng | Cách xử lý |
|---|---|---|
| Đặc tả task | Agent hiểu sai scope | Cập nhật spec.md / mô tả issue / acceptance criteria |
| Cung cấp context | Agent không biết quy ước | Cập nhật AGENTS.md, plan.md, ADR |
| Môi trường thực thi | Thiếu dependency, sai version | Cập nhật setup-dev.sh, devcontainer |
| Phản hồi verify | Agent nói "xong" khi chưa đúng | Bắt buộc chạy verify-pr.sh trước khi tuyên bố hoàn thành |
| Quản lý state | Task dài bị mất context | Ghi vào comment Issue/PR, worklog trong tasks.md |
| Tích hợp công cụ/MCP | MCP lỗi, không kết nối | Fix tận gốc tại config/token/setup; CẤM workaround bằng gh/script |
| Vòng lặp chẩn đoán | Lỗi lặp lại | Cập nhật artifact/script/instruction, không chỉ retry |

## Quy tắc vàng

**Mỗi lần sửa lỗi AI phải để lại một cải tiến lâu dài trong repo.** Không để AI tiêu tốn context để tự khám phá lại những quy ước đã biết.

## Ví dụ điển hình: fallback âm thầm

AI Agent cố khởi tạo MCP GitHub nhưng thất bại, rồi tự "chữa cháy" bằng `gh` CLI hoặc script. Đây là lỗi tầng *tích hợp công cụ* + *thiếu kỷ luật báo lỗi*. Cách xử lý đúng: Agent **DỪNG và báo cáo blocker**, con người fix cấu hình MCP tận gốc. Quy tắc này được mã hóa cứng trong Constitution mục 1.5.

## Ví dụ điển hình: script phụ thuộc file ẩn

`init-project.sh` từng `cp` thẳng `.gitignore`/`.github/` từ toolkit. Khi toolkit được sao chép/đồng bộ mà file ẩn không đi theo, lệnh `cp` fail và vỡ toàn bộ quá trình init. Áp dụng quy tắc vàng — sửa luôn ở repo thay vì để người dùng tự xoay xở:

- Script **tự sinh** `.gitignore` khi không tìm thấy (không phụ thuộc file ẩn của toolkit).
- File tùy chọn (vd `ci.yml`) thiếu thì **cảnh báo và bỏ qua**, không fail.
- `git commit` khởi tạo dùng identity dự phòng để không vỡ khi máy chưa cấu hình `user.name/email`.

**Bài học chung cho mọi script trong toolkit:** không giả định file ẩn luôn tồn tại; tác vụ tùy chọn phải fail mềm (cảnh báo + tiếp tục), chỉ fail cứng với tác vụ cốt lõi; mọi script chạy bằng `bash`, không phải `sh`. Quy tắc này được ghi trong `CONTRIBUTING.md`.
