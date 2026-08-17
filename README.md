# Agent Active

A bar widget for [Omarchy](https://omarchy.org) that shows an icon when a coding agent (opencode, claude, codex, gemini, copilot, crush, grok, omp, pi) is running. When the agent finishes, it plays a completion sound and sends a clickable notification that focuses the agent's terminal window.

## Install

```sh
omarchy plugin add https://github.com/azzen/azzen.agent-active.git --enable
```

## Features

- Live status icon in the bar while any agent is running
- Tooltip showing which agents are active
- Completion sound when an agent finishes
- Click-to-focus notification that jumps to the agent's window

## Remove

```sh
omarchy plugin remove azzen.agent-active
```

## License

MIT
