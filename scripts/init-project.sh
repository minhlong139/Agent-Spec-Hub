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

# 8. Spec Kit tooling (.specify/ + skills /speckit-*) — quy trình tự động hoá
#    Cài & khởi tạo bộ công cụ Spec Kit chính thức (github/spec-kit) để dự án có
#    sẵn .specify/ và các skill /speckit-* (specify/plan/tasks/implement...).
#    Đặt TRƯỚC git init để mọi file Spec Kit nằm trong commit khởi tạo.
#    Harness Engineering (mục 9): nếu thiếu công cụ thì DỪNG có kiểm soát + báo
#    cáo rõ ràng, KHÔNG workaround ngầm. Bỏ qua chủ động bằng SKIP_SPECKIT=1.
if [ "${SKIP_SPECKIT:-0}" = "1" ]; then
  echo "==> (SKIP_SPECKIT=1 — bỏ qua khởi tạo Spec Kit)"
else
  # 8.1 Đảm bảo có 'specify' CLI. Bản mới bundle template trong package nên
  #     KHÔNG cần tải asset từ GitHub release (vốn đã bị gỡ → init bản cũ lỗi 404).
  if ! command -v specify >/dev/null 2>&1; then
    if command -v uv >/dev/null 2>&1; then
      echo "==> Chưa có 'specify' CLI — cài từ nguồn git qua uv (bundle template, không cần mạng để init)..."
      uv tool install specify-cli --from git+https://github.com/github/spec-kit.git \
        || echo "  (!) Cài specify CLI thất bại — bỏ qua bước Spec Kit (xem hướng dẫn cuối)."
    else
      echo "  (!) Không thấy cả 'specify' lẫn 'uv' — bỏ qua Spec Kit."
      echo "      Cài uv rồi chạy lại, hoặc init Spec Kit thủ công (xem hướng dẫn cuối)."
    fi
  fi

  # 8.2 Khởi tạo .specify/ + skills vào dự án. --force vì thư mục đã có file;
  #     --no-git để KHÔNG tạo repo riêng (bước 9 mới git init). Đã kiểm chứng:
  #     init chỉ THÊM file mới, không ghi đè constitution.md/specs đã dựng ở trên.
  if command -v specify >/dev/null 2>&1; then
    echo "==> Khởi tạo Spec Kit (.specify/ + skills /speckit-*) cho dự án..."
    (
      cd "$TARGET"
      specify init --here --ai claude --script sh --force --no-git \
        || echo "  (!) 'specify init' thất bại — dự án vẫn dùng được, init Spec Kit sau (xem hướng dẫn cuối)."
    )
    # 8.3 Một nguồn sự thật (Constitution 1.1) + cấm tài liệu song song (4.2):
    #     đồng bộ constitution chính thức (root) vào nơi Spec Kit tooling đọc,
    #     thay cho template rỗng [PROJECT_NAME] mà specify init sinh ra.
    if [ -f "$TARGET/constitution.md" ] && [ -d "$TARGET/.specify/memory" ]; then
      cp "$TARGET/constitution.md" "$TARGET/.specify/memory/constitution.md"
      echo "  (Đã đồng bộ constitution.md -> .specify/memory/constitution.md)"
    fi
  fi
fi

# 9. git init (KHÔNG tạo remote/branch protection — đó là việc của con người)
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
echo "  5. Bắt đầu feature 001 theo phase Spec-Kit (skill /speckit-specify, /speckit-plan...)."
echo ""
if ! command -v specify >/dev/null 2>&1 || [ ! -d "$TARGET/.specify" ]; then
  echo "==> Spec Kit CHƯA được khởi tạo. Để có .specify/ + skill /speckit-*:"
  echo "     1) Cài uv:        curl -LsSf https://astral.sh/uv/install.sh | sh"
  echo "     2) Cài CLI mới:   uv tool install specify-cli --from git+https://github.com/github/spec-kit.git"
  echo "     3) Init trong dự án: cd \"$TARGET\" && specify init --here --ai claude --script sh --force --no-git"
  echo "        (CLI bản mới bundle template — KHÔNG dùng bản cũ tải asset GitHub, vốn lỗi 404)"
fi
