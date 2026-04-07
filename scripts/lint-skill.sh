#!/bin/bash
# lint-skill.sh — 扫描 SKILL.md 中的已知反模式，输出缺陷计数
# 用于 autoresearch 的 verify 命令

SKILL="$1"
if [ -z "$SKILL" ]; then
  SKILL="$(dirname "$0")/../SKILL.md"
fi

defects=0

grep_count() {
  local c
  c=$(grep -cE "$1" "$SKILL" 2>/dev/null)
  echo "${c:-0}"
}

# 1. 相对路径 cp/cd：使用 ./ 而非绝对路径（容易导致项目创建到错误位置）
c=$(grep_count '(cp -r|cp |cd )\.\/')
defects=$((defects + c))

# 2. 在 skill 目录下创建项目文件
c=$(grep_count 'cp.*template.*\.\/')
defects=$((defects + c))

# 3. 缺少 PM 确认门控：阶段二到五应该有确认步骤
for phase in "阶段二" "阶段三" "阶段四" "阶段五"; do
  phase_start=$(grep -n "^## .*${phase}" "$SKILL" | head -1 | cut -d: -f1)
  if [ -n "$phase_start" ]; then
    next_section=$(awk -v start="$phase_start" 'NR > start && /^## / {print NR; exit}' "$SKILL")
    if [ -z "$next_section" ]; then
      next_section=$(wc -l < "$SKILL")
    fi
    has_gate=$(sed -n "${phase_start},${next_section}p" "$SKILL" | grep -cE '(确认|门控|询问.*PM)' 2>/dev/null)
    has_gate=${has_gate:-0}
    if [ "$has_gate" -eq 0 ]; then
      defects=$((defects + 1))
    fi
  fi
done

# 4. bash 命令块缺少强制执行标注
while IFS= read -r line_num; do
  context_start=$((line_num - 3))
  if [ "$context_start" -lt 1 ]; then context_start=1; fi
  has_enforce=$(sed -n "${context_start},${line_num}p" "$SKILL" | grep -cE '(必须|严禁|强制|MUST|CRITICAL)' 2>/dev/null)
  has_enforce=${has_enforce:-0}
  if [ "$has_enforce" -eq 0 ]; then
    defects=$((defects + 1))
  fi
done < <(grep -n '```bash' "$SKILL" | cut -d: -f1)

# 5. 缺少错误处理
npm_count=$(grep_count '^\s*(npm |npx )')
err_count=$(grep_count '(如果.*失败|失败.*则|失败.*提示)')
if [ "$npm_count" -gt 0 ] && [ "$err_count" -eq 0 ]; then
  defects=$((defects + 2))
fi

# 6. 模糊指令
c=$(grep_count '(可以考虑|建议.*可以|也许|或许可以|不一定)')
defects=$((defects + c))

# 7. 缺少 pwd 验证
cd_count=$(grep_count '^\s*cd ')
pwd_count=$(grep_count 'pwd')
if [ "$cd_count" -gt 0 ] && [ "$pwd_count" -eq 0 ]; then
  defects=$((defects + 1))
fi

echo "$defects"
