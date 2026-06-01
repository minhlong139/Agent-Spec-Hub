<div align="center">

# Agent Spec Hub

**Bộ toolkit mã nguồn mở giúp các team Dev áp dụng AI Agent vào SDLC — tự động hóa quản lý quy trình phần mềm theo tư tưởng Specs-Driven · HITL · Harness Engineering.**

</div>

---

## Agent Spec Hub là gì?

Agent Spec Hub là một **toolkit khởi tạo (starter kit)** dành cho team phát triển phần mềm muốn đưa AI Agent (Claude, Gemini, Codex, Cursor, Copilot...) vào vòng đời phát triển một cách **có kiểm soát, có truy vết, và có thể lặp lại**.

Toolkit cung cấp sẵn:

- Một bản **Constitution** (hiến pháp kỹ thuật) chuẩn hóa — nguồn sự thật cao nhất cho cả người lẫn AI Agent.
- Bộ **template tài liệu** theo quy trình Spec-Kit: `spec → plan → tasks`.
- Bộ **rule cho từng vai AI Agent** (PO, Tech Lead, Dev, QA, Design).
- Bộ **script chuẩn hóa** (`setup-dev`, `run-tests`, `verify-pr`) + script `init-project` để dựng dự án mới trong vài phút.

Mục tiêu: để một team có thể **bắt tay vào dự án ngay**, với hàng rào an toàn (guardrails) cho AI Agent được cài đặt sẵn.

## Ba tư tưởng cốt lõi

| Tư tưởng | Ý nghĩa |
|---|---|
| **Specs-Driven** | Mọi thay đổi code đều bắt nguồn từ một spec đã được phê duyệt. Không coding từ trao đổi miệng. Spec là nguồn sự thật. → [`docs/philosophy/specs-driven.md`](docs/philosophy/specs-driven.md) |
| **HITL** (Human In The Loop) | Các quyết định rủi ro cao (merge, deploy, đổi schema, chốt scope...) luôn cần con người phê duyệt. AI đề xuất — người chốt. → [`docs/philosophy/hitl.md`](docs/philosophy/hitl.md) |
| **Harness Engineering** | Khi AI thất bại, sửa môi trường/context/verification thay vì đổi model. Mỗi lần sửa lỗi để lại cải tiến lâu dài trong repo. → [`docs/philosophy/harness-engineering.md`](docs/philosophy/harness-engineering.md) |

## Cấu trúc toolkit

```text
agent-spec-hub/
├── README.md
├── LICENSE                       # MIT
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── CHANGELOG.md
├── docs/
│   ├── constitution.template.md  # ★ Lõi — hiến pháp kỹ thuật của dự án
│   ├── getting-started.md        # Hướng dẫn bắt đầu nhanh
│   └── philosophy/
│       ├── specs-driven.md
│       ├── hitl.md
│       └── harness-engineering.md
├── templates/
│   ├── agents/                   # Rule cho từng vai AI Agent
│   │   ├── AGENTS.md
│   │   ├── PO_AGENT.md
│   │   ├── TECHLEAD_AGENT.md
│   │   ├── DEV_AGENT.md
│   │   ├── QA_AGENT.md
│   │   └── DESIGN_AGENT.md
│   ├── specs/NNN-feature-name/   # Template artifact Spec-Kit
│   └── design/NNN-feature-name/  # Template artifact thiết kế
├── scripts/
│   ├── init-project.sh           # Dựng dự án mới từ toolkit
│   ├── setup-dev.sh
│   ├── run-tests.sh
│   └── verify-pr.sh
└── .github/workflows/ci.yml      # CI pipeline mẫu (lint + test + build)
```

## Bắt đầu nhanh

```bash
# 1. Clone toolkit
git clone <repo-url> agent-spec-hub && cd agent-spec-hub

# 2. Dựng một dự án mới từ toolkit
./scripts/init-project.sh ../my-new-project "Tên Dự Án"

# 3. Mở dự án vừa tạo, điền các marker 【ĐIỀN】 trong constitution.md
cd ../my-new-project
```

Chi tiết: xem [`docs/getting-started.md`](docs/getting-started.md).

## Ngôn ngữ

Toolkit này dùng **tiếng Việt** làm ngôn ngữ chính cho tài liệu, giữ nguyên thuật ngữ chuyên ngành và định danh mã nguồn bằng tiếng Anh. Đây cũng là một quy tắc bắt buộc với AI Agent (xem Constitution mục 0).

## Đóng góp

Xem [`CONTRIBUTING.md`](CONTRIBUTING.md). Mọi đóng góp tuân theo [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).

## Giấy phép

[MIT](LICENSE).
