---
name: ai-engineering
description: LLM integration, agent architecture, RAG pipelines, prompt engineering, and AI system design. Use when building AI-powered features, designing multi-agent systems, working with Claude/OpenAI/OSS models, or evaluating LLM outputs. Reusable by dev-agent and orchestrator-agent.
---

# AI Engineering — Shared Skill

## Model Selection (Current, 2026)
| Use Case | Model |
|----------|-------|
| Complex reasoning, agents, long context | claude-opus-4-8 |
| Balanced performance/cost | claude-sonnet-4-6 (default) |
| Fast, high-volume tasks | claude-haiku-4-5 |
| Storytelling, creative | claude-fable-5 |

Always verify current model IDs via the `claude-api` skill before hardcoding — model names change.

## Anthropic SDK Patterns
```python
import anthropic
client = anthropic.Anthropic()

# Standard call
response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    messages=[{"role": "user", "content": prompt}]
)

# Streaming
with client.messages.stream(model=..., ...) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)

# Tool use
response = client.messages.create(
    model="claude-sonnet-4-6",
    tools=[{"name": "...", "description": "...", "input_schema": {...}}],
    messages=[...]
)
```

## Prompt Engineering Principles
- System prompt: role, constraints, output format — not task instructions
- User turn: the actual task — keep it focused
- Few-shot examples outperform long instructions for format enforcement
- Chain of thought: ask model to reason before answering for complex tasks
- Avoid: "Do not X" framings — prefer positive constraints
- Temperature: 0 for deterministic/factual, 0.7-1.0 for creative, 1.0 for diversity

## RAG Architecture
```
Query → Embed → Vector Search → Retrieved Chunks → Augmented Prompt → LLM → Response
```
- Chunk size: 512-1024 tokens with 10-20% overlap
- Rerank retrieved chunks before injecting (cross-encoder or LLM-based)
- Citation: always track source for retrieved content
- Eval: measure retrieval recall separately from generation quality

## Agent Patterns
- **ReAct**: reason + act loop (think → tool call → observe → repeat)
- **Orchestrator-subagent**: route tasks to specialized agents (current system pattern)
- **Reflection**: agent critiques own output before returning
- **Parallelization**: independent subtasks dispatched simultaneously

## AI System Evaluation
- Define eval criteria before building (not after)
- Automated evals: exact match, semantic similarity, LLM-as-judge
- Human evals: for nuanced quality, safety, and alignment
- Track: latency, token cost, error rate, quality score per task type
- Red-team before shipping: adversarial prompts, edge cases, jailbreaks

## Context Window Management
- Track token usage explicitly; never assume headroom
- Summarize conversation history when approaching limits
- Prefer structured data (JSON) over prose for tool outputs
- Cache expensive prefixes with prompt caching where available
