# Contributing Guide

AI Tips에 기여해주셔서 감사합니다!

## 카테고리

기여물은 아래 카테고리 중 하나에 해당해야 합니다:

| 카테고리 | 설명 | 예시 |
|---------|------|-----|
| `scripts/` | 자동화 스크립트 (bash, python 등) | weekly-retrospective |
| `skills/` | 커스텀 스킬 (.md 파일) | code-review, commit |
| `commands/` | 슬래시 커맨드 설정 | /fix, /test |
| `subagents/` | 커스텀 서브에이전트 정의 | explore, plan 커스텀 |
| `hooks/` | Claude Code 훅 설정 | pre-commit, post-tool |
| `prompts/` | 프롬프트 템플릿, CLAUDE.md 예시 | 시스템 프롬프트 |

## 기여 방법

### 1. 폴더 생성

```
카테고리/내-기여물-이름/
├── README.md          # 필수: TEMPLATE.md 형식 따르기
├── 실제파일들...       # 스크립트, 설정 파일 등
└── examples/          # 선택: 예시 파일들
```

### 2. README.md 작성

[TEMPLATE.md](./TEMPLATE.md)를 참고해서 작성해주세요.

**필수 항목:**
- 한 줄 설명
- 왜 만들었는지 (문제/해결)
- 사용 방법

**선택 항목:**
- 상세 설정
- 예시 출력
- 주의사항

### 3. PR 제출

1. 새 브랜치 생성: `feat/카테고리-이름` (예: `feat/scripts-auto-commit`)
2. 변경사항 커밋
3. PR 생성

## 작성 팁

- **실제 사용 경험**을 바탕으로 작성해주세요
- 왜 유용한지, 어떤 상황에서 쓰는지 구체적으로
- 코드보다 **맥락**이 중요합니다
- 한국어/영어 모두 가능

## 질문이 있으면

Issue를 열어주세요!