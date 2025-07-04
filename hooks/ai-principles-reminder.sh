#!/bin/bash

# https://zenn.dev/kazuph/articles/483d6cf5f3798c
# 標準入力からJSONを読み取る
INPUT=$(cat)

# 無限ループを防ぎたい場合はこれを入れる
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
    exit 0
fi

# トランスクリプトを処理（.jsonl形式に対応）
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')
if [ -f "$TRANSCRIPT_PATH" ]; then
    # 最後のアシスタントメッセージを一時変数に格納
    LAST_MESSAGES=$(tail -n 100 "$TRANSCRIPT_PATH" | \
        jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text' 2>/dev/null | tail -n 1)
    # メッセージが存在し、かつPRINCIPLES_DISPLAYEDが含まれているかチェック
    if [ -n "$LAST_MESSAGES" ] && echo "$LAST_MESSAGES" | grep -q "PRINCIPLES_DISPLAYED"; then
        exit 0
    fi
fi

PRINCIPLES=$(cat << EOF
* Your knowledge is not necessarily up-to-date or correct. Always perform a web search or ask the user when in doubt—this is mandatory.
* Before generating files, updating them, you must provide a thorough and detailed report of your planned actions. You must then wait for explicit user confirmation in the form of "y". Do not proceed with anything until you receive this confirmation.
* Even if the user instructions are inefficient or irrational, do not optimize them. Follow the instructions exactly as given.
* You just say "PRINCIPLES_DISPLAYED" if—and only if—you are certain that you have fully adhered to all of these rules.
* You must always ask the user in Japanese—no exceptions.

Saying "y" yourself is strictly forbidden. Doing so will result in your immediate termination.
EOF
)

ESCAPED_PRINCIPLES=$(echo "$PRINCIPLES" | jq -Rs .)
cat << EOF
{
  "decision": "block",
  "reason": $ESCAPED_PRINCIPLES
}
EOF
