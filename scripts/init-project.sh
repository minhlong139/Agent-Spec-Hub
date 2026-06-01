#!/usr/bin/env bash
# init-project.sh — Dựng một dự án mới từ Agent Spec Hub toolkit.
#
# Cách dùng:
#   ./scripts/init-project.sh <đường-dẫn-dự-án-mới> "Tên Dự Án"
#
# Phân vai (Constitution mục 1.5 — xem chi tiết tại docs/constitution.template.md):
#   [AI/Script] Dựng cấu trúc thư mục, copy template, git init — KHÔNG cần GitHub.
#   [Người]     Tạo repo remote trên GitHub (thủ công hoặc qua MCP GitHub).
#   [Script]    setup-github.sh — chạy SAU KHI repo đã có trên GitHub:
#                 labels · Project IDs · mcp-server/.env · GitHub Actions Variables
#                 (được phép dùng gh CLI vì đây là tác vụ setup một lần, không phải runtime)
#   [MCP]       Mọi tác vụ runtime (sync task, đẩy PR, duyệt PR) → CHỈ qua MCP GitHub.
set -euo pipefail

TARGET="${1:-}"
PROJECT_NAME="${2:-}"

if [ -z "$TARGET" ] || [ -z "$PROJECT_NAME" ]; then
  echo "Cách dùng: $0 <đường-dẫn-dự-án-mới> \"Tên Dự Án\""
  exit 1
fi

TOOLKIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TODAY="$(date +%Y-%m-%d)"

echo "==> Dựng dự án '$PROJECT_NAME' tại: $TARGET"
mkdir -p "$TARGET"

# 1. Cấu trúc thư mục chuẩn (Constitution Section 4.1)
mkdir -p "$TARGET"/{specs,design,src,tests/{unit,integration,e2e},infra/environments,docs/{architecture,api,runbooks},decisions,knowledge,postmortems,scripts,qa/reports,.github/workflows}

# 2. Constitution: copy template -> constitution.md, điền sẵn tên + ngày
sed -e "s/【ĐIỀN: 〘PO\/BO〙 Tên dự án \/ sản phẩm 】/$PROJECT_NAME/" \
    -e "0,/【ĐIỀN: YYYY-MM-DD 】/s//$TODAY/" \
    -e "0,/【ĐIỀN: YYYY-MM-DD 】/s//$TODAY/" \
    "$TOOLKIT_DIR/docs/constitution.template.md" > "$TARGET/constitution.md"

# 3. Template agent -> root
cp "$TOOLKIT_DIR"/templates/agents/*.md "$TARGET/"

# 4. Scripts bắt buộc
cp "$TOOLKIT_DIR"/scripts/{setup-dev.sh,run-tests.sh,verify-pr.sh} "$TARGET/scripts/"
# Copy setup-github.sh — chạy sau khi repo đã tạo trên GitHub
cp "$TOOLKIT_DIR/scripts/setup-github.sh" "$TARGET/scripts/setup-github.sh"
chmod +x "$TARGET"/scripts/*.sh

# 5. CI pipeline mẫu (bỏ qua nếu không tìm thấy — vd file ẩn không được đồng bộ)
if [ -f "$TOOLKIT_DIR/.github/workflows/ci.yml" ]; then
  cp "$TOOLKIT_DIR/.github/workflows/ci.yml" "$TARGET/.github/workflows/ci.yml"
else
  echo "  (Không thấy ci.yml trong toolkit — bỏ qua, bạn có thể thêm sau)"
fi

# 6. .gitignore — tự sinh để không phụ thuộc file ẩn của toolkit
if [ -f "$TOOLKIT_DIR/.gitignore" ]; then
  cp "$TOOLKIT_DIR/.gitignore" "$TARGET/.gitignore"
else
  cat > "$TARGET/.gitignore" <<'GITIGNORE'
# Dependencies
node_modules/
.venv/
__pycache__/

# Build
dist/
build/
.next/
out/

# Env & secrets — KHÔNG commit (Constitution mục 1.2, 11)
.env
.env.*
*.local
secrets/
*.pem
*.key

# Agent-specific / local config (Constitution mục 1.4)
.claude/
.cursor/
.aider*
*.local.md

# IDE / OS
.idea/
.vscode/
.DS_Store
Thumbs.db

# Logs
*.log
logs/
GITIGNORE
fi

# 7. Skeleton feature đầu tiên
cp -r "$TOOLKIT_DIR/templates/specs/NNN-feature-name" "$TARGET/specs/001-feature-name"
cp -r "$TOOLKIT_DIR/templates/design/NNN-feature-name" "$TARGET/design/001-feature-name"

# 8. git init (KHÔNG tạo remote/branch protection — đó là việc của con người)
(
  cd "$TARGET"
  git init -q
  git add -A
  # Dùng identity local nếu máy chưa cấu hình global, để commit khởi tạo không fail
  git -c user.name="${GIT_AUTHOR_NAME:-Agent Spec Hub}" \
      -c user.email="${GIT_AUTHOR_EMAIL:-init@agentspechub.local}" \
      commit -q -m "chore: khởi tạo dự án từ Agent Spec Hub" \
    || echo "  (Bỏ qua commit khởi tạo — bạn có thể tự commit sau)"
)

echo ""
echo "==> XONG. Bước tiếp theo:"
echo ""
echo "  ── SETUP (con người & script) ──────────────────────────────────────"
echo "  1. [Người]     Tạo repo trên GitHub (thủ công hoặc qua MCP GitHub)"
echo "  2. [Người]     Push code lên remote:"
echo "                   cd $TARGET"
echo "                   git remote add origin https://github.com/OWNER/REPO.git"
echo "                   git push -u origin main"
echo ""
echo "  3. [Script]    Chạy setup-github.sh để hoàn tất cấu hình GitHub:"
echo "                   cd $TARGET"
echo "                   ./scripts/setup-github.sh"
echo "                 Script này (được phép dùng gh CLI) sẽ tự động:"
echo "                   • Tạo 9 GitHub Labels"
echo "                   • Lấy GitHub Project v2 IDs & Column IDs"
echo "                   • Sinh mcp-server/.env cho MCP server"
echo "                   • Set GitHub Actions Variables"
echo ""
echo "  4. [Người]     Branch Protection (main):"
echo "                   Repo → Settings → Branches → Add rule"
echo "                   ✅ Require PR (1 approval) + status check: quality-gate"
echo "                   ✅ Do not allow bypassing"
echo ""
echo "  5. [Người]     Setup secret/token (không hardcode)"
echo ""
echo "  ── NỘI DUNG (Tech Lead & PO) ───────────────────────────────────────"
echo "  6. [Tech Lead]  Mở constitution.md → điền marker 【ĐIỀN】"
echo "                   (Section 3: tech stack, Section 2.2: môi trường, 〔CHỌN〕)"
echo "  7. [PO/BO]      Điền nội dung nghiệp vụ + AGENTS.md context"
echo ""
echo "  ── RUNTIME (MCP GitHub — không dùng gh) ────────────────────────────"
echo "  8. [Dev]        Cài MCP server (sau khi mcp-server/.env đã có):"
echo "                   cd $TARGET/mcp-server"
echo "                   docker compose --env-file .env up -d --build"
echo "  9. Bắt đầu feature 001 theo phase Spec-Kit qua MCP GitHub."
echo ""
echo "  📌 Lưu ý: Sau bước setup, mọi tác vụ runtime (tạo/sync Issue, PR, review)"
echo "     PHẢI qua MCP GitHub. Nếu MCP lỗi → hỏi người dùng, KHÔNG tự dùng gh."
