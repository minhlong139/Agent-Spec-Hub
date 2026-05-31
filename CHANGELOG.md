# Changelog

Tuân theo [Keep a Changelog](https://keepachangelog.com/) và [Semantic Versioning](https://semver.org/).

## [1.0.1] - 2026-05-31

### Fixed
- `init-project.sh` không còn fail khi file ẩn (`.gitignore`, `.github/ci.yml`) của toolkit không được đồng bộ: tự sinh `.gitignore`, fail mềm với `ci.yml`, `git commit` dùng identity dự phòng.

### Added
- Quy tắc viết script trong `CONTRIBUTING.md` (chạy bằng bash, không giả định file ẩn, fail mềm tác vụ tùy chọn).
- Mục "Ví dụ điển hình: script phụ thuộc file ẩn" trong `docs/philosophy/harness-engineering.md`.

## [1.0.0] - 2026-05-31

### Added
- Constitution template lõi (`docs/constitution.template.md`) với 13 mục: ngôn ngữ làm việc, nguyên tắc cốt lõi, kiến trúc, tech stack, repo standards, SDLC, risk tiering, HITL, DoD, Harness Engineering, init checklist, absolute rules, governance.
- Mô hình phân vai 3 nhóm: `[Người]` / `[AI→duyệt]` / `[AI]`.
- Quy tắc kênh tương tác GitHub (chỉ MCP, cấm fallback âm thầm sang gh/script).
- Bộ template agent: AGENTS, PO, TECHLEAD, DEV, QA, DESIGN.
- Template Spec-Kit: spec / plan / tasks / research / design / data-model / quickstart.
- Scripts: `init-project.sh`, `setup-dev.sh`, `run-tests.sh`, `verify-pr.sh`.
- CI pipeline mẫu.
- Tài liệu triết lý: Specs-Driven, HITL, Harness Engineering.
