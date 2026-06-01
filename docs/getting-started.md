# Bắt đầu nhanh với Agent Spec Hub

Hướng dẫn dựng một dự án mới có sẵn hàng rào an toàn cho AI Agent.

---

## Yêu cầu

| Tool | Kiểm tra | Ghi chú |
|------|---------|---------|
| `git`, `bash` | `git --version` | Bắt buộc |
| GitHub CLI (`gh`) | `gh --version` | Dùng cho `setup-github.sh` — https://cli.github.com |
| `jq` | `jq --version` | `brew install jq` / `apt install jq` |
| Docker Desktop | `docker --version` | Dùng để chạy MCP server |
| MCP GitHub | Cấu hình trong Claude Desktop | Kênh bắt buộc cho **runtime** (Issue, PR, review) |

> 📌 **Phân biệt kênh GitHub (xem Constitution mục 1.5):**
> - **Setup (một lần)** — `scripts/setup-github.sh` dùng `gh` CLI → tạo labels, lấy Project IDs, sinh `.env`
> - **Runtime (hàng ngày)** — Issue, PR, review, merge, sync task → **chỉ qua MCP GitHub**
>   Nếu MCP lỗi trong runtime → hỏi người dùng trước khi dùng `gh`, không được tự fallback

---

## Luồng khởi tạo đầy đủ

```
┌─────────────────────────────────────────────────────────────┐
│  BƯỚC 1: init-project.sh (AI/Script)                        │
│  Dựng cấu trúc local — không cần GitHub                     │
├─────────────────────────────────────────────────────────────┤
│  BƯỚC 2: Tạo repo GitHub (Người)                            │
│  Thủ công hoặc qua MCP GitHub + push code                   │
├─────────────────────────────────────────────────────────────┤
│  BƯỚC 3: setup-github.sh (Script — gh CLI)                  │
│  Labels · Project IDs · mcp-server/.env · Actions Variables │
├─────────────────────────────────────────────────────────────┤
│  BƯỚC 4: Cấu hình thủ công (Người)                          │
│  Branch Protection · Secret · Staging URL · CI deploy cmd   │
├─────────────────────────────────────────────────────────────┤
│  BƯỚC 5: Nội dung (Tech Lead + PO)                          │
│  Điền constitution.md · AGENTS.md · tech stack              │
├─────────────────────────────────────────────────────────────┤
│  BƯỚC 6: MCP server (Dev)                                   │
│  docker compose up → test get_my_tasks                      │
├─────────────────────────────────────────────────────────────┤
│  RUNTIME: Mọi tác vụ qua MCP GitHub                         │
│  Tạo Issue · Đẩy PR · Review · Merge · Sync task            │
└─────────────────────────────────────────────────────────────┘
```

---

## Bước 1 — Khởi tạo cấu trúc local

```bash
# Clone Agent Spec Hub toolkit
git clone https://github.com/your-org/agent-spec-hub.git
cd agent-spec-hub

# Chạy installer
./scripts/init-project.sh <đường-dẫn-dự-án-mới> "Tên Dự Án"

# Ví dụ:
./scripts/init-project.sh ../acme-portal "ACME Portal"
```

> Chạy bằng `bash`, không phải `sh`.

Script `init-project.sh` sẽ tự động:
1. Tạo cấu trúc thư mục chuẩn (specs, design, src, tests, docs, infra...).
2. Copy `constitution.template.md` → `constitution.md`, điền sẵn tên dự án + ngày.
3. Copy toàn bộ template agents (AGENTS.md, PO_AGENT.md, DEV_AGENT.md...).
4. Copy scripts: `setup-dev.sh`, `run-tests.sh`, `verify-pr.sh`, **`setup-github.sh`**.
5. Copy CI pipeline mẫu vào `.github/workflows/`.
6. Tạo skeleton `specs/001-feature-name/` và `design/001-feature-name/`.
7. `git init` + commit khởi tạo.

---

## Bước 2 — Tạo repo trên GitHub và push

```bash
cd <đường-dẫn-dự-án-mới>

# Tạo repo trên GitHub (chọn một trong hai cách):
# Cách A: Thủ công tại github.com → New repository
# Cách B: Qua MCP GitHub trong Claude

# Sau khi tạo repo xong, push code lên:
git remote add origin https://github.com/OWNER/REPO.git
git push -u origin main
```

---

## Bước 3 — Chạy setup-github.sh (gh CLI — setup một lần)

```bash
cd <đường-dẫn-dự-án-mới>

# Đảm bảo gh CLI đã login và có đủ scope
gh auth login
gh auth refresh -h github.com -s project   # Cần scope "project" cho GitHub Projects v2

# Chạy setup
chmod +x scripts/setup-github.sh
./scripts/setup-github.sh
```

Script sẽ hỏi GitHub Owner, Repo name, Project number rồi tự động:

| Tác vụ | Công cụ | Kết quả |
|--------|---------|---------|
| Tạo 9 GitHub Labels | `gh label create` (idempotent) | `spec`, `task`, `bug`, `qc`, `ready`, `in-progress`, `in-review`, `planned`, `needs-fix` |
| Lấy GitHub Project v2 IDs | `gh project list` + GraphQL | `PROJECT_ID`, `STATUS_FIELD_ID` |
| Lấy Column Option IDs | `gh project field-list` | `COL_BACKLOG`, `COL_READY`, `COL_IN_PROGRESS`, `COL_IN_REVIEW`, `COL_DONE` |
| Sinh `mcp-server/.env` | Script | File config cho MCP server |
| Set GitHub Actions Variables | `gh variable set` | `PROJECT_NUMBER`, `STATUS_FIELD_ID`, `COL_*` |

> **Tại sao được dùng `gh` ở đây?** Đây là tác vụ setup một lần, không phải runtime.
> Constitution mục 1.5 cho phép `gh` CLI trong luồng setup. Xem chi tiết tại `constitution.md`.

---

## Bước 4 — Cấu hình thủ công trên GitHub (Người)

**Branch Protection** (bắt buộc):
```
Repo → Settings → Branches → Add rule → Branch: main
✅ Require pull request before merging (Required approvals: 1)
✅ Require status checks to pass: quality-gate
✅ Do not allow bypassing the above settings
❌ Allow force pushes ← tắt
```

**Staging URL** (nếu có CI deploy):
```bash
gh variable set STAGING_URL --body "https://staging.yourapp.com" --repo OWNER/REPO
```

**Deploy command trong CI**: Mở `.github/workflows/ci.yml`, tìm `Deploy to Staging`, thay `echo "Deployed"` bằng lệnh thực tế.

**Secret/Token**: Lưu trong GitHub Secrets hoặc Secret Manager — không hardcode.

---

## Bước 5 — Điền nội dung (Tech Lead + PO)

```bash
# Mở và điền hai file này trước khi làm bất kỳ feature nào:
open constitution.md                    # Điền Section 3 (tech stack), 2.2 (môi trường), 〔CHỌN〕
open AGENTS.md                          # Điền context dự án cho AI agents đọc
```

Tech Lead điền: tech stack, naming conventions, Definition of Done, environments.
PO/BO điền: tên sản phẩm, mục tiêu nghiệp vụ, scope.

Sau khi điền xong:
```bash
git add constitution.md AGENTS.md
git commit -m "docs: fill project constitution and agent context"
git push
```

---

## Bước 6 — Cài đặt MCP server (mỗi Dev)

Sau khi `mcp-server/.env` đã được sinh bởi `setup-github.sh`:

```bash
cd mcp-server
docker compose --env-file .env up -d --build
```

Thêm vào `~/Library/Application Support/Claude/claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "dev-mcp": {
      "command": "docker",
      "args": ["exec", "-i", "dev-mcp", "node", "dist/index.js"]
    }
  }
}
```

Restart Claude Desktop. Test:
```
get_my_tasks username:your-github-username
```

---

## Runtime — Mọi tác vụ qua MCP GitHub

Sau khi setup xong, **toàn bộ tác vụ hàng ngày** đều qua MCP GitHub:

| Tác vụ | Lệnh MCP |
|--------|----------|
| Xem task được assign | `get_my_tasks username:X` |
| Bắt đầu task | `start_task issue:N` |
| Giao feature cho Dev | `assign_feature feature:X assignee:Y` |
| Submit để review | `submit_for_review issue:N summary:"..." test_results:"..."` |
| Đưa branch manual vào workflow | `adopt_task issue:N` |
| Kiểm tra drift board ↔ branch | `audit_tasks` |

**Nếu MCP GitHub lỗi trong runtime:**
```
1. Dừng tác vụ đang thực hiện
2. Thông báo: "MCP GitHub không khả dụng — [mô tả lỗi]"
3. Hỏi người dùng: "Tôi có thể dùng gh CLI thay thế cho [tác vụ X] không?"
4. Chỉ tiến hành bằng gh nếu người dùng đồng ý
5. Nhắc người dùng fix MCP trước khi tiếp tục
```
**KHÔNG tự fallback âm thầm** — đây là vi phạm Constitution mục 1.5.

---

## Kiểm chứng harness

```bash
cd <đường-dẫn-dự-án>
./scripts/setup-dev.sh      # Cài dependencies, kiểm tra môi trường
./scripts/run-tests.sh      # Chạy test suite (unit + integration)
./scripts/verify-pr.sh      # Kiểm tra PR checklist trước khi submit
```

---

## Cách 2 — Khởi tạo thủ công

Nếu không dùng script, làm theo **Checklist Section 10** trong `constitution.md`. Ký hiệu phân vai:
- `[AI]` — AI tự làm
- `[AI→duyệt]` — AI làm, người phê duyệt
- `[Người]` — con người tự làm (HITL)
- `[Script-gh]` — script dùng gh CLI (hợp lệ cho setup)
