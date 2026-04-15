---
name: fabi
version: 1.0.0
description: |
  Use the Fabi CLI to interact with the Fabi platform. Core workflow:
  `fabi login`, `fabi context` for downloading data semantics,
  `fabi smartbook new` or `fabi smartbook resume`, `fabi chat`
  for conversational data analysis, `fabi app build` for building React
  dashboards from notebook data, `fabi app preview` for previewing built apps
  from a Smartbook, and `fabi app publish` for publishing them to reports.
  Use when asked to "fabi login", "fabi context", "fabi chat", "build a dashboard",
  "build a react app from fabi", "fabi app build", "fabi app preview", "deploy", or
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

### `fabi context` — Download Data Context (MANDATORY FIRST STEP)

```bash
fabi context                    # Write fabi-context.md to current directory
fabi context -o /tmp/ctx.md     # Custom output path
```

**CRITICAL: Always run `fabi context` before any `fabi chat` or `fabi app build` command.** This downloads data source semantics and custom instructions as a Markdown file. Read it to understand what the data means — column definitions, how metrics like "top" or "best" are defined, and what business logic is encoded in the data.

Without this context, you will make wrong assumptions. For example, "top albums" might be ranked by streams, not sales. The semantics file tells you.

After running, read the output file with the Read tool (no bash/python needed).

### `fabi chat` — Conversational Data Analysis (Sub-Agent)

`fabi chat` is a **sub-agent** backed by Fabi's AI — not a simple query tool. It has full access to connected data sources, can collect context from the notebook, dry-run code, and execute complex multi-step data queries and analysis autonomously. Think of it as a capable data analyst you can delegate to.

**Delegate complex data work to `fabi chat`.** When you need to explore data, validate assumptions, run aggregations, join across tables, or prepare datasets for a dashboard, send the task to `fabi chat` rather than writing raw SQL yourself. The sub-agent understands the data semantics, can iterate on queries, and will return results you can build on. This is especially valuable for:

- **Data exploration** — discovering what tables/columns exist and what they mean
- **Complex queries** — multi-step aggregations, window functions, joins across sources
- **Data validation** — verifying assumptions about data shape, nulls, cardinality
- **Analysis preparation** — producing cleaned/aggregated dataframes that your React app can query directly. Prepared dataframes are **cached on the server**, so the dashboard queries them instead of re-running expensive raw SQL — this improves app performance significantly
- **Statistical & ML tasks** — Fabi can run regressions, clustering, forecasting, and other statistical/ML workloads server-side, producing result dataframes your app can consume

**Caveat: Use `fabi api` for schema/query validation, not `fabi chat`.** For quick tasks like validating SQL syntax or checking table schemas, call the notebook query API directly (`fabi api POST /api/v2/notebooks/<uuid>/query --data '{"sql":"..."}'`) — it is much faster than a full chat round-trip.

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

**CRITICAL: Read `fabi context` output first.** Before sending any chat prompt, read the context file to understand data semantics. This prevents you from adding wrong assumptions like "by sales" or "by revenue" when the data defines rankings differently.

### `fabi api` — Proxy authenticated Fabi API calls

```bash
fabi api GET /api/v2/notebooks/<notebook_uuid>
fabi api POST /api/v2/notebooks/<notebook_uuid>/query --data '{"sql":"SELECT * FROM dataframe_name"}'
```

Use this when you need to call Fabi backend APIs directly from the terminal. The CLI injects the proper authorization header automatically.

### `fabi app build` — Build a React Dashboard

```bash
fabi app build                                 # Write manifest.md into the current workspace
fabi app build -o manifest.json                # Save to a custom file
fabi app build --notebook-uuid <notebook_uuid> # Override the current Smartbook
```

Fetches the notebook manifest as a Markdown document describing available data (dataframes, tables, files, data source semantics), agent memory, and API endpoints. Read the output with the Read tool — no JSON parsing needed.

#### Workflow for building a dashboard:

1. Run `fabi context` and read the output to understand data semantics (if not already done)
2. Run `fabi app build` and read the manifest to understand available data, agent memory, and API endpoints
3. **Verify the backend is working** — use `fabi api` to call the query API and confirm you can fetch real data
4. **Understand the notebook semantics (MANDATORY)** — before writing any dashboard code:
   a. Fetch the full notebook to read the source SQL/Python for every dataframe
   b. Query each dataframe to see the actual data and column names
   c. Map out which dashboard sections can use existing dataframes vs need raw SQL
   d. **Never assume what a dataframe contains from its name alone.** Always read the source cell.
5. Build a Vite + React + TypeScript SPA dashboard

Use the Smartbook workspace as the app project directory:

- put app source files in the current workspace set via `fabi workdir set <path>`
- keep `dist/` there too when you build

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

### `fabi app preview` — Upload a Smartbook Preview App

```bash
fabi app preview ./dist                          # Upload built app from dist/
fabi app preview ./dist --entry-path index.html  # Specify entry file (default: index.html)
fabi app preview ./dist --notebook-uuid <notebook_uuid> # Override the current Smartbook
```

Uploads a built React app as the current preview for the selected Fabi Smartbook. By default it uses the currently selected Smartbook workspace under `~/.fabi/notebooks/<notebook_uuid>`, but `--notebook-uuid` can target a different Smartbook explicitly. The app is bundled as a zip and uploaded.

**Full workflow:** `fabi context` (understand data) → `fabi smartbook new` or `fabi smartbook resume` → `fabi chat` → `fabi app build` → build the React app → `bun run build` → `fabi app preview ./dist`

### `fabi app publish` — Publish App Preview to a Report

```bash
fabi app publish
fabi app publish --notebook-uuid <notebook_uuid>
```

Publishes the current app preview from a Smartbook to a report. This is the report-facing publish step, not the Smartbook preview upload step.

### `fabi smartbook` — Select a Smartbook and local workspace

```bash
fabi smartbook list -n 10
fabi smartbook current
fabi smartbook new
fabi smartbook resume --notebook-uuid <notebook_uuid>
```

This is the entrypoint for Smartbook-scoped work.

- `fabi smartbook new` creates a new Smartbook and selects `~/.fabi/notebooks/<notebook_uuid>`
- `fabi smartbook resume` switches to an existing Smartbook and downloads its deployed app into `dist/` inside that local workspace, overwriting existing files there
- `fabi smartbook list` shows recent Smartbooks and marks the current one
- `fabi smartbook current` prints the currently selected Smartbook URL and local workspace path

### Local workspace model

Fabi CLI keeps Smartbook-local files under:

```bash
~/.fabi/notebooks/<notebook_uuid>
```

That directory is where you should expect:

- `manifest.md` written by `fabi app build`
- your local app source files directly in that Smartbook directory
- your build output such as `dist/`
- deployed app files downloaded by `fabi smartbook resume` into `dist/`

Passing `--notebook-uuid` to `fabi app build`, `fabi app preview`, or `fabi app publish` is a one-off override. It does not switch the current Smartbook workspace.

#### Finding the notebook UUID:

- From a Fabi URL: `https://app.fabi.ai/notebook/<notebook_uuid>`
- From CLI config: `cat ~/.fabi/cli.json` and read the `workdir` value
- From the local workspace path: `~/.fabi/notebooks/<notebook_uuid>`
- Ask the user
