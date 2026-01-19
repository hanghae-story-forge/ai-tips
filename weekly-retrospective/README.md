# Claude Code Weekly Retrospective

Claude Code 사용 패턴을 분석해서 주간 회고를 자동으로 생성하는 스크립트입니다.

## 왜 만들었나요

매주 Claude와 어떤 대화를 했는지, 그 속에서 무엇을 배웠는지 정리하려고 하면 속도가 너무 빠르고 변화도 잦아서 따라가기가 어렵습니다. 그래서 자동으로 회고를 생성해주는 스크립트를 만들어서, 나 스스로를 돌아보는 시간을 갖도록 했습니다.

## 이렇게 쓰고 있어요

매주 금요일 오전 11시에 자동 실행되도록 설정해두고, 한 주간 Claude Code를 어떻게 활용했는지 돌아보는 용도로 사용하고 있습니다.

파일로 저장하면 잘 안 열어보게 될 것 같아서, 슬랙 MCP를 연결해 개인 DM으로 받도록 설정해뒀어요.

### 분석 항목

- **프로젝트별 사용량**: 어떤 프로젝트에서 많이 썼는지
- **시간대별 패턴**: 언제 주로 사용하는지
- **입력 내용 기반 회고**: 실제 대화 내용을 바탕으로 3가지 관점에서 회고
  - 성장 영역 (개선점)
  - AI 활용 분석
  - 자동화 제안

## 사용 방법

### 1. 수동 실행

```bash
./weekly-retrospective.sh
```

### 2. 자동 실행 (macOS launchd)

**launchd**는 macOS의 시스템 스케줄러입니다. 슬립 모드나 화면 잠금 상태에서도 작업을 실행할 수 있어서, 정해진 시간에 자동으로 스크립트를 돌리기에 적합합니다.

#### 설정 방법

```bash
# 1. plist 파일을 LaunchAgents 디렉토리에 복사
cp com.claude.weekly-retrospective.plist ~/Library/LaunchAgents/

# 2. plist 파일 내 경로를 본인 환경에 맞게 수정
# /Users/username/ 부분을 실제 경로로 변경

# 3. launchd에 등록
launchctl load ~/Library/LaunchAgents/com.claude.weekly-retrospective.plist
```

#### 관리 명령어

```bash
# 상태 확인
launchctl list | grep claude

# 즉시 실행
launchctl start com.claude.weekly-retrospective

# 등록 해제
launchctl unload ~/Library/LaunchAgents/com.claude.weekly-retrospective.plist
```

#### plist 주요 설정

| 키 | 설명 |
|----|------|
| `StartCalendarInterval` | 실행 시간 (Weekday: 5=금요일, Hour: 18=오후 6시) |
| `StandardOutPath` | 로그 출력 경로 |
| `EnvironmentVariables` | 환경 변수 (PATH, HOME, CLAUDE_CODE_OAUTH_TOKEN 등) |

> ⚠️ `CLAUDE_CODE_OAUTH_TOKEN` 환경 변수를 plist에 추가해야 Claude CLI가 정상 동작합니다.

> 참고: [macOS launchd/launchctl 사용법](https://wikidocs.net/blog/@eh_note/5487/)

### 3. 자동 실행 (Linux cron)

```bash
# Every Friday at 6 PM
0 18 * * 5 /path/to/weekly-retrospective.sh
```

## 설정

환경 변수로 커스터마이즈 가능합니다:

```bash
# 14 days analysis, opus model, stdout output
RETROSPECTIVE_DAYS=14 \
RETROSPECTIVE_MODEL=opus \
RETROSPECTIVE_FORMAT=stdout \
./weekly-retrospective.sh
```

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `RETROSPECTIVE_DAYS` | `7` | 분석 기간 |
| `RETROSPECTIVE_MODEL` | `sonnet` | Claude 모델 |
| `RETROSPECTIVE_FORMAT` | `file` | `file` / `stdout` |
| `RETROSPECTIVE_OUTPUT_DIR` | `~/.claude/retrospectives` | 출력 경로 |

## 필요한 것

- Claude Code CLI
- jq (`brew install jq`)
