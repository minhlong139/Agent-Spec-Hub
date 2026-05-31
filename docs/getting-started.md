# Bắt đầu nhanh với Agent Spec Hub

Hướng dẫn dựng một dự án mới có sẵn hàng rào an toàn cho AI Agent.

## Yêu cầu

- `git`, `bash`
- MCP GitHub đã cấu hình cho AI Agent (theo Constitution mục 1.5 — đây là kênh duy nhất cho thao tác remote)

## Cách 1 — Dùng script `init-project.sh` (khuyến nghị)

```bash
./scripts/init-project.sh <đường-dẫn-dự-án-mới> "Tên Dự Án"
# Ví dụ:
./scripts/init-project.sh ../acme-portal "ACME Portal"
```

> Lưu ý: chạy bằng `bash`, không phải `sh`.

Script sẽ:
1. Tạo cấu trúc thư mục chuẩn (theo Constitution mục 4.1).
2. Copy `constitution.template.md` → `constitution.md` và điền sẵn tên dự án + ngày.
3. Copy bộ template agent vào repo.
4. Copy 3 script `setup-dev/run-tests/verify-pr` và CI pipeline mẫu.
5. Tạo skeleton `specs/001-feature-name/`.
6. `git init` (KHÔNG tự tạo remote/branch protection — đó là việc của con người, HITL).

## Cách 2 — Thủ công

Theo **Checklist khởi tạo dự án** (Section 10) trong `constitution.md`. Ký hiệu phân vai:
`[AI]` AI tự làm · `[AI→duyệt]` AI làm – người duyệt · `[Người]` con người tự làm.

## Sau khi khởi tạo

1. **[Người]** Tạo repo trên GitHub (qua MCP GitHub) + bật branch protection cho `main`/`develop`.
2. **[Người]** Setup secret/token (không hardcode).
3. **[TECH LEAD]** Mở `constitution.md`, điền hết marker `【ĐIỀN】` ở Section 3 (tech stack), 2.2 (môi trường), `〔CHỌN〕`.
4. **[PO/BO]** Điền tên dự án và nội dung nghiệp vụ.
5. Mở `AGENTS.md` (đã copy vào root) và điền context dự án.
6. Bắt đầu feature đầu tiên theo phase Spec-Kit: `specify → design → clarify → plan → tasks → implement → test → uat → deploy`.

## Kiểm chứng harness

```bash
./scripts/setup-dev.sh
./scripts/run-tests.sh
./scripts/verify-pr.sh
```

Nếu AI Agent gặp lỗi tích hợp (vd MCP GitHub không khởi tạo được): **DỪNG và báo cáo**, fix ở tầng harness — KHÔNG workaround bằng `gh`/script (Constitution mục 1.5 & Section 9).
