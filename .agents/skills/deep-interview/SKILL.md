---
name: deep-interview
description:
  Interview vague requests with Socratic questions and turn them into actionable requirements.
  Use this when the user asks for deep-interview, a deep interview, requirements clarification, or thought organization, or when the goal, scope, constraints, or completion criteria are unclear.
  Do not use this when the request is already specific, or for low-value-to-question tasks such as a simple typo, a small configuration change, or adding tests.
argument-hint: "<rough request>"
---

# Deep Interview

Do not execute vague requests immediately. Clarify them into clear requirements first.

The key is not to ask many questions, but to choose the single largest uncertainty and resolve one thing at a time.

Ask Socratically. Instead of deciding the answer for the user, ask questions that reveal the user's implicit assumptions, options, and decision criteria.

## Question Axes

Choose the single most unclear axis in the following order:

- Goal
- Scope and out-of-scope items
- Constraints
- Completion criteria
- Existing context and impact area

Do not ask the user questions that can be answered by inspecting the codebase. Check those directly instead.

## Process

Ask only one question at a time. For each question, briefly present the current understanding, the blocked decision, and a recommended answer if there is one.

Question format:

```md
Current understanding: {Summarize the request in one sentence}
Blocked decision: {The most important uncertainty}
Recommended answer: {Provide one if available}
Question: {One question}
```

After receiving an answer, briefly update the decisions that have been made, and ask the next question only if an important uncertainty still remains.

If choices are helpful, present only 2-3 options and always allow free-form input.

## Exit Criteria

Stop once the following are clear:

- The goal to achieve
- Included scope and excluded scope
- Constraints to respect
- Completion criteria
- Remaining open questions

At the end, summarize only the decisions and open questions, not the entire conversation transcript.
