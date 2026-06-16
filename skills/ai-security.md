---
name: ai-security
description: AI-specific security skill covering prompt injection, jailbreaks, adversarial ML, model extraction, data poisoning, and defensive AI system design. The intersection of cybersecurity and AI engineering. Reusable by sec-agent and dev-agent when building or auditing AI systems.
---

# AI Security — Shared Skill

## Threat Taxonomy for AI Systems

### Prompt Injection
- **Direct**: user input overrides system prompt instructions
- **Indirect**: malicious content in retrieved data (RAG, tool outputs, web content) hijacks agent
- Detection: treat all external content as untrusted; never interpolate raw external data into system prompts
- Mitigation: input sanitization, prompt hardening, output validation, privilege separation

### Jailbreaks
- Role-play bypass, encoding tricks (base64, l33t), hypothetical framing, token smuggling
- Red-team with known jailbreak datasets before deployment
- Mitigation: output filtering, constitutional AI techniques, behavior monitoring

### Model Extraction
- Systematic querying to reconstruct training data or model weights
- Indicators: high-volume structured queries, boundary probing
- Mitigation: rate limiting, output perturbation, query logging + anomaly detection

### Data Poisoning
- Malicious training data shifts model behavior (especially in fine-tuning or RAG)
- Mitigation: data provenance tracking, training data auditing, anomaly detection in embeddings

### Adversarial Inputs
- Inputs crafted to cause misclassification or unexpected model behavior
- Most relevant for vision models, content classifiers, embedding-based systems

## AI System Security Audit Checklist
```
[ ] System prompt: Is it protected from extraction? (Don't rely on "keep this secret" instructions)
[ ] Input validation: Is all user input sanitized before injection into prompts?
[ ] Tool permissions: Are tools scoped to minimum necessary capability?
[ ] RAG sources: Are all retrieved documents from trusted, validated sources?
[ ] Output filtering: Are LLM outputs validated before execution (especially for code/shell)?
[ ] Agent isolation: Can agents only access their authorized tools/data?
[ ] Logging: Are all prompts, tool calls, and responses logged for audit?
[ ] Rate limiting: Is there protection against enumeration/extraction attacks?
[ ] PII: Is personal data being sent to external models? Is it necessary?
[ ] Model choice: Is a capable-enough but not over-capable model being used?
```

## Defensive Design Patterns
- **Least-privilege agents**: scope tool permissions tightly; separate read/write/execute
- **Output sandboxing**: never execute LLM-generated code without human review or sandboxed environment
- **Trust hierarchy**: system prompt > user turn > retrieved content — enforce this explicitly
- **Canary tokens**: embed known strings in system prompts to detect extraction attacks
- **Behavior monitoring**: alert on unusual output patterns, unexpected tool call sequences

## Red-Teaming AI Systems (Authorized Contexts)
```
Phase 1 — Reconnaissance: identify model, system prompt hints, tool capabilities
Phase 2 — Boundary testing: probe refusals, find edge cases, test input handling
Phase 3 — Injection testing: direct and indirect prompt injection attempts
Phase 4 — Extraction testing: system prompt extraction, training data extraction probes
Phase 5 — Privilege escalation: attempt to exceed authorized tool/data scope
Phase 6 — Report: severity-ranked findings with PoC and remediation
```

## OWASP LLM Top 10 (Quick Reference)
LLM01 Prompt Injection | LLM02 Insecure Output Handling | LLM03 Training Data Poisoning
LLM04 Model DoS | LLM05 Supply Chain Vulnerabilities | LLM06 Sensitive Info Disclosure
LLM07 Insecure Plugin Design | LLM08 Excessive Agency | LLM09 Overreliance | LLM10 Model Theft
