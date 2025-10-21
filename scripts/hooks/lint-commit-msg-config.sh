#!/usr/bin/env bash
# scripts/setup-commitmsg-hook.sh
set -e

HOOK_PATH=".git/hooks/commit-msg"

if [ ! -d ".git/hooks" ]; then
  echo "❌ .git/hooks 디렉터리가 없습니다. Git 레포 루트에서 실행하세요."
  exit 1
fi

cat > "$HOOK_PATH" << 'EOF'
#!/usr/bin/env bash
# .git/hooks/commit-msg

MSG_FILE="$1"
COMMIT_MSG=$(grep -v '^#' "$MSG_FILE" | head -n1)

# ----- 패턴 정의 -----
# JIRA 키는 선택 사항 ([], 여러 개도 허용)
JIRA_OPT="(\\[([A-Z][A-Z0-9_-]*-[0-9]+)(,[[:space:]]*[A-Z][A-Z0-9_-]*-[0-9]+)*\\][[:space:]]+)?"
TYPE="(Feat|Fix|Docs|Style|Refactor|Test|Chore|Design|Comment|Rename|Remove|!BREAKING CHANGE|!HOTFIX)"
SCOPE="(\\([a-z0-9_-]+\\))?"       # 선택
SUBJECT=": .{1,50}$"               # 1~50자

PATTERN="^${JIRA_OPT}${TYPE}${SCOPE}${SUBJECT}"

# 머지/리버트 커밋은 검사 제외
if [[ "$COMMIT_MSG" =~ ^Merge\  || "$COMMIT_MSG" =~ ^Revert\  ]]; then
  exit 0
fi

if [[ ! "$COMMIT_MSG" =~ $PATTERN ]]; then
  echo "❌ 커밋 메시지 컨벤션 위반:"
  echo "   현재: \"$COMMIT_MSG\""
  echo "   형식: [JIRA-KEY(, ...)] Type(scope): subject(≤50)"
  echo "   예시: [S13P11B105-56] Feat(childcare): init spring dev setting"
  echo "         Feat(core): add cache layer"
  exit 1
fi
exit 0
EOF

chmod +x "$HOOK_PATH"
echo "✅ commit-msg 훅이 설치되었습니다: $HOOK_PATH"
