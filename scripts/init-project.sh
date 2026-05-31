#!/usr/bin/env bash
# init-project.sh — Dựng một dự án mới từ Agent Spec Hub toolkit.
#
# Cách dùng:
#   ./scripts/init-project.sh <đường-dẫn-dự-án-mới> "Tên Dự Án"
#
# Phân vai (Constitution):
#   [AI]    Script này tự dựng cấu trúc, copy template, git init.
#   [Người] Tạo repo remote + branch protection + secret KHÔNG nằm trong script (HITL, mục 1.5/7).
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
echo "==> XONG. Bước tiếp theo (con người):"
echo "  1. [Người] Tạo repo trên GitHub (qua MCP GitHub) + bật branch protection main/develop"
echo "  2. [Người] Setup secret/token (không hardcode)"
echo "  3. [Tech Lead] Mở constitution.md, điền marker 【ĐIỀN】 ở Section 3 (stack), 2.2, 〔CHỌN〕"
echo "  4. [PO/BO] Điền nội dung nghiệp vụ + AGENTS.md context"
echo "  5. Bắt đầu feature 001 theo phase Spec-Kit."
