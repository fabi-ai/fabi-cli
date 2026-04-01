---
name: fabi
version: 1.0.0
description: |
  Use the Fabi CLI to interact with the Fabi platform. Core workflow:
  `fabi login`, `fabi smartbook new` or `fabi smartbook resume`, `fabi chat`
  for conversational data analysis, `fabi build-app` for building React
  dashboards from notebook data, and `fabi deploy` for deploying built apps
  to Fabi.
  Use when asked to "fabi login", "fabi chat", "build a dashboard",
  "build a react app from fabi", "fabi build-app", "deploy", or
  "create a dashboard from this notebook".
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
---

# Fabi CLI

The Fabi CLI (`fabi`) connects to the [Fabi](https://fabi.ai) platform for data analysis and dashboard building.

## Installation

```bash
curl -fsSL https://github.com/fabi-ai/fabi-cli/releases/latest/download/installer.sh | bash
fabi install-skill
```

## Commands

### `fabi login` — Authenticate

```bash
fabi login
```

Opens a browser for OAuth login. Once complete, the session token is saved locally. All subsequent commands use this session automatically.

### `fabi chat` — Conversational Data Analysis

```bash
fabi smartbook new                         # Create a Smartbook first
fabi smartbook resume --notebook-uuid ... # Or resume an existing one
fabi chat "What tables do I have?"       # Send a prompt
fabi chat "Show me revenue by month"     # Ask about data
fabi chat --timeout 300 "Run this query" # Custom timeout (seconds)
```

Chat uses the currently selected Smartbook and streams the AI response. It does not create Smartbooks implicitly anymore. If no Smartbook is active, run:

- `fabi smartbook new`
- `fabi smartbook resume --notebook-uuid <uuid>`

**CRITICAL: Pass user prompts verbatim.** When relaying a user's request to `fabi chat`, pass their exact words. Do NOT add assumptions, reinterpret, or "improve" the prompt. The Fabi backend has its own context (connected data sources, notebook history) that gives meaning to ambiguous terms. Adding your own interpretation will contradict the actual definitions in the notebook. Let Fabi interpret the user's intent.

### `fabi build-app` — Build a React Dashboard

```bash
fabi build-app                                 # Write manifest to ~/.fabi/notebooks/<uuid>/manifest.json
fabi build-app -o manifest.json                # Save to a custom file
fabi build-app --notebook-uuid <notebook_uuid> # Override the current Smartbook
```

Fetches the notebook manifest — a JSON document describing available data (dataframes, tables, files) and API endpoints for querying it.

#### Workflow for building a dashboard:

1. Run `fabi build-app`
2. Read the manifest to understand available data
3. **Verify the backend is working** — call the query API to confirm you can fetch real data
4. **Understand the notebook semantics (MANDATORY)** — before writing any dashboard code:
   a. Fetch the full notebook to read the source SQL/Python for every dataframe
   b. Query each dataframe to see the actual data and column names
   c. Map out which dashboard sections can use existing dataframes vs need raw SQL
   d. **Never assume what a dataframe contains from its name alone.** Always read the source cell.
5. Build a Vite + React + TypeScript SPA dashboard

#### Pre-build checklist (must complete before writing App.tsx):

- [ ] Listed all dataframes with their schemas and source cell code
- [ ] Queried each dataframe to verify column names and sample data
- [ ] Identified which dashboard sections map to existing dataframes vs need raw SQL
- [ ] Verified at least one query works end-to-end through the proxy

#### Key rules:

- **Dataframes first** — notebook dataframes encode business logic and definitions. Before writing any dashboard query:
  1. Fetch the notebook cells to read the source SQL/Python
  2. Query dataframes directly as table names — do NOT re-derive their logic with raw SQL
  3. Only use raw DB tables for data the notebook doesn't already provide
- **Never assume semantics from names** — a name like `top_artists_df` tells you nothing about the ranking criteria. Read the source cell.
- **Client-side SPA only** — Vite + React. No SSR, no Next.js, no server components. Prefer bun over npm if available.
- **Credentials required** — every API call must include `withCredentials: true` (axios) or `credentials: 'include'` (fetch). **NEVER hardcode session tokens or Authorization headers in the React app.** The browser cookie handles auth automatically through the Vite proxy.
- **Subpath-safe assets** — deployed notebook apps are hosted under `/notebook/<uuid>/deployed-app/`, not the site root. Configure the frontend build to emit relative asset URLs (for Vite, set `base: "./"`) so generated bundles use `./assets/...` instead of `/assets/...`, which will 404 after deployment.
- **SQL for data access** — `POST /api/v2/notebooks/{uuid}/query` with `{"sql": "SELECT * FROM dataframe_name"}`. Reference artifact names as table names.

#### When to build a React app vs use Fabi Chat

Fabi's built-in UI supports basic dashboarding (plotly/altair charts, input filters, client-side pagination). But the following features require a custom React app — do NOT try to implement these via `fabi chat`:

- **Cross-filtering** — clicking a chart element filters other charts
- **Drill-downs** — clicking a summary row expands into detail views
- **Server-side pagination** — paginating large datasets via SQL LIMIT/OFFSET
- **Table pivots** — dynamic row/column pivoting with aggregations

If the user asks for any of these, build a React app.

### `fabi deploy` — Deploy React App to Fabi

```bash
fabi deploy ./dist                          # Deploy built app from dist/
fabi deploy ./dist --entry-path index.html  # Specify entry file (default: index.html)
fabi deploy ./dist --notebook-uuid <notebook_uuid> # Override the current Smartbook
```

Deploys a built React app to the current Fabi Smartbook. By default it uses the currently selected Smartbook workspace under `~/.fabi/notebooks/<notebook_uuid>`, but `--notebook-uuid` can target a different Smartbook explicitly. The app is bundled as a zip and uploaded.

**Full workflow:** `fabi smartbook new` or `fabi smartbook resume` → `fabi chat` → `fabi build-app` → build the React app → `bun run build` → `fabi deploy ./dist`

### `fabi smartbook` — Select a Smartbook and local workspace

```bash
fabi smartbook list -n 10
fabi smartbook new
fabi smartbook resume --notebook-uuid <notebook_uuid>
```

This is the entrypoint for Smartbook-scoped work.

- `fabi smartbook new` creates a new Smartbook and selects `~/.fabi/notebooks/<notebook_uuid>`
- `fabi smartbook resume` switches to an existing Smartbook and downloads its deployed app into that same local workspace, overwriting existing files there
- `fabi smartbook list` shows recent Smartbooks and marks the current one

### Local workspace model

Fabi CLI keeps Smartbook-local files under:

```bash
~/.fabi/notebooks/<notebook_uuid>
```

That directory is where you should expect:

- `manifest.json` written by `fabi build-app`
- your local app source or build output
- deployed app files downloaded by `fabi smartbook resume`

Passing `--notebook-uuid` to `fabi build-app` or `fabi deploy` is a one-off override. It does not switch the current Smartbook workspace.

#### Finding the notebook UUID:

- From a Fabi URL: `https://app.fabi.ai/notebook/<notebook_uuid>`
- From CLI config: `cat ~/.config/fabi/cli.json` and read the `workdir` value
- From the local workspace path: `~/.fabi/notebooks/<notebook_uuid>`
- Ask the user
