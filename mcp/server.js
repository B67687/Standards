import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { execSync } from "child_process";
import { readFileSync } from "fs";

const PROJECT = "/home/nami/projects/dev/standards";

function run(cmd, cwd = PROJECT) {
  try {
    const out = execSync(cmd, { cwd, encoding: "utf-8", timeout: 120000 });
    return { stdout: out.trim(), stderr: "", exitCode: 0 };
  } catch (e) {
    return {
      stdout: e.stdout?.trim() || "",
      stderr: e.stderr?.trim() || e.message,
      exitCode: e.status ?? 1,
    };
  }
}

const server = new Server(
  { name: "standards", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "list_standards",
        description: "List all 31 standards with their check counts and compliance scores. Returns the full standards catalog, optionally filtered by domain.",
        inputSchema: {
          type: "object",
          properties: {
            domain: {
              type: "string",
              description: "Filter by domain (e.g. 'docs', 'universal', 'backend', 'security', 'infra', 'ai', 'quality')",
            },
          },
        },
      },
      {
        name: "run_audit",
        description: "Run the 152-check audit suite against a single repo or directory. Calls audit.sh with all supported flags.",
        inputSchema: {
          type: "object",
          properties: {
            target: {
              type: "string",
              description: "Path to repo or directory to audit (default: .)",
              default: ".",
            },
            standard: {
              type: "string",
              description: "Only check specific standard by ID (e.g. 'readme-quality', 'license')",
            },
            domain: {
              type: "string",
              description: "Only check standards in a given domain (e.g. 'security', 'docs')",
            },
            fix: {
              type: "boolean",
              description: "Apply additive, safe auto-fixes (default: false)",
              default: false,
            },
            force: {
              type: "boolean",
              description: "Apply all fixes including destructive (default: false)",
              default: false,
            },
            report: {
              type: "string",
              enum: ["terminal", "json", "quiet"],
              description: "Output format (default: terminal)",
              default: "terminal",
            },
            exit_code: {
              type: "boolean",
              description: "Exit with error code on failure for CI gating (default: false)",
              default: false,
            },
            agent_reviews: {
              type: "boolean",
              description: "Run agent-check.sh after audit to process pending evaluations (default: false)",
              default: false,
            },
          },
        },
      },
      {
        name: "run_multi_audit",
        description: "Batch audit across all repos under a base directory. Calls audit-all.sh to discover and audit multiple repos.",
        inputSchema: {
          type: "object",
          properties: {
            dir: {
              type: "string",
              description: "Base directory to search for git repos (default: .)",
              default: ".",
            },
            repos_file: {
              type: "string",
              description: "Path to file with repo paths (one per line, skips discovery)",
            },
            agent_reviews: {
              type: "boolean",
              description: "Run agent-check.sh after each audit (default: false)",
              default: false,
            },
          },
        },
      },
      {
        name: "run_check",
        description: "Run a single specific check by name.",
        inputSchema: {
          type: "object",
          properties: {
            check: {
              type: "string",
              description: "Check name (e.g. 'readme-quality', 'license', 'commit-conventions')",
            },
            target: {
              type: "string",
              description: "Path to repo or directory (default: .)",
              default: ".",
            },
          },
          required: ["check"],
        },
      },
      {
        name: "run_agent_evals",
        description: "Process agent evaluation requests. Wraps agent-check.sh for subjective AI quality checks.",
        inputSchema: {
          type: "object",
          properties: {
            eval_dir: {
              type: "string",
              description: "Directory containing agent eval JSON files (default: CWD/.omo/audit/agent-evals)",
            },
            result_dir: {
              type: "string",
              description: "Output directory for agent result JSON files (default: derived from eval_dir)",
            },
            mode: {
              type: "string",
              enum: ["process-pending"],
              description: "Operation mode (default: process-pending)",
              default: "process-pending",
            },
          },
        },
      },
      {
        name: "get_standard_detail",
        description: "Read the full documentation for a specific standard by ID.",
        inputSchema: {
          type: "object",
          properties: {
            standard: {
              type: "string",
              description: "Standard ID (e.g. 'readme-quality', 'license', 'commit-conventions')",
            },
          },
          required: ["standard"],
        },
      },
      {
        name: "run_self_audit",
        description: "Run the full audit suite against the standards repo itself (dogfooding).",
        inputSchema: {
          type: "object",
          properties: {
            fix: {
              type: "boolean",
              description: "Apply auto-fixes (default: false)",
              default: false,
            },
            exit_code: {
              type: "boolean",
              description: "Exit with error on failure (default: false)",
              default: false,
            },
          },
        },
      },
      {
        name: "generate_dashboard",
        description: "Generate the compliance dashboard HTML for a target directory.",
        inputSchema: {
          type: "object",
          properties: {
            target: {
              type: "string",
              description: "Base directory to scan for repos (default: /home/nami/projects/dev)",
              default: "/home/nami/projects/dev",
            },
          },
        },
      },
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case "list_standards": {
      let raw;
      try {
        raw = readFileSync(`${PROJECT}/standards.json`, "utf-8");
      } catch {
        return { content: [{ type: "text", text: "Error: could not read standards.json" }] };
      }
      const data = JSON.parse(raw);
      let list = data.standards || [];

      if (args?.domain) {
        const domain = args.domain.toLowerCase();
        list = list.filter(s => s.domains?.toLowerCase().includes(domain));
      }

      const lines = list.map(s =>
        `• ${s.id} — ${s.name} (${s.check_count} checks) — ${s.description.split(".")[0]}`
      );
      return {
        content: [{
          type: "text",
          text: `## Standards Catalog (${list.length} standards)\n\n${lines.join("\n")}`,
        }],
      };
    }

    case "run_audit": {
      const target = args?.target || ".";
      const standard = args?.standard ? `--standard ${args.standard}` : "";
      const domain = args?.domain ? `--domain ${args.domain}` : "";
      const fix = args?.fix ? "--fix" : "";
      const force = args?.force ? "--force" : "";
      const report = args?.report ? `--report ${args.report}` : "";
      const exitFlag = args?.exit_code ? "--exit-code" : "";
      const agentFlag = args?.agent_reviews ? "--agent-reviews" : "";
      const flags = [standard, domain, fix, force, report, exitFlag, agentFlag].filter(Boolean).join(" ");
      const result = run(`bash scripts/audit.sh ${flags} "${target}"`);
      return {
        content: [{
          type: "text",
          text: result.exitCode === 0
            ? `✅ Audit passed\n${result.stdout.slice(-3000)}`
            : `⚠️ Audit found issues (exit ${result.exitCode})\n${result.stderr.slice(-3000)}`,
        }],
      };
    }

    case "run_multi_audit": {
      const dir = args?.dir || ".";
      const reposFlag = args?.repos_file ? `--repos-file "${args.repos_file}"` : "";
      const agentFlag = args?.agent_reviews ? "--agent-reviews" : "";
      const flags = [reposFlag, agentFlag].filter(Boolean).join(" ");
      const result = run(`bash scripts/audit-all.sh ${flags} --dir "${dir}"`);
      return {
        content: [{
          type: "text",
          text: result.exitCode === 0
            ? `✅ Multi-repo audit passed\n${result.stdout.slice(-3000)}`
            : `⚠️ Multi-repo audit found issues (exit ${result.exitCode})\n${result.stderr.slice(-3000)}`,
        }],
      };
    }

    case "run_check": {
      if (!args?.check) throw new Error("check argument required");
      const target = args?.target || ".";
      const result = run(`bash scripts/audit.sh --standard ${args.check} --report quiet "${target}"`);
      // Extract the summary lines from audit output
      const summary = result.stdout.split("\n").filter(l => /✓|✗|⟳/.test(l)).join("\n");
      return {
        content: [{
          type: "text",
          text: result.exitCode === 0
            ? `✅ ${args.check}: passed\n${summary || "(no issues)"}`
            : `❌ ${args.check}: failed\n${result.stderr.slice(-1000)}`,
        }],
      };
    }

    case "run_agent_evals": {
      const evalDir = args?.eval_dir ? `--eval-dir "${args.eval_dir}"` : "";
      const resultDir = args?.result_dir ? `--result-dir "${args.result_dir}"` : "";
      const mode = args?.mode || "process-pending";
      const modeFlag = mode === "process-pending" ? "--process-pending" : "";
      const flags = [evalDir, resultDir, modeFlag].filter(Boolean).join(" ");
      const result = run(`bash scripts/agent-check.sh ${flags}`);
      return {
        content: [{
          type: "text",
          text: result.exitCode === 0
            ? `✅ Agent evals processed\n${result.stdout.slice(-2000)}`
            : `⚠️ Some evals still pending\n${result.stderr.slice(-2000)}`,
        }],
      };
    }

    case "get_standard_detail": {
      if (!args?.standard) throw new Error("standard argument required");
      let raw;
      try {
        raw = readFileSync(`${PROJECT}/standards.json`, "utf-8");
      } catch {
        return { content: [{ type: "text", text: "Error: could not read standards.json" }] };
      }
      const data = JSON.parse(raw);
      const entry = (data.standards || []).find(s => s.id === args.standard);
      if (!entry) {
        return { content: [{ type: "text", text: `Standard not found: ${args.standard}` }] };
      }
      if (!entry.doc) {
        return { content: [{ type: "text", text: `Standard "${args.standard}" has no documentation file.` }] };
      }
      try {
        const content = readFileSync(entry.doc, "utf-8");
        return { content: [{ type: "text", text: `# ${entry.name}\n\n${content}` }] };
      } catch {
        return { content: [{ type: "text", text: `Error reading doc: ${entry.doc}` }] };
      }
    }

    case "run_self_audit": {
      const fix = args?.fix ? "--fix" : "";
      const exitFlag = args?.exit_code ? "--exit-code" : "";
      const flags = [fix, exitFlag].filter(Boolean).join(" ");
      const result = run(`bash scripts/audit.sh ${flags} .`);
      return {
        content: [{
          type: "text",
          text: result.exitCode === 0
            ? `✅ Self-audit passed\n${result.stdout.slice(-2000)}`
            : `⚠️ Self-audit found issues (exit ${result.exitCode})\n${result.stderr.slice(-2000)}`,
        }],
      };
    }

    case "generate_dashboard": {
      const target = args?.target || "/home/nami/projects/dev";
      const result = run(`bash scripts/dashboard.sh "${target}"`);
      let dashboardPath = `${PROJECT}/docs/dashboard.html`;
      let dashboardUrl = "";
      try {
        dashboardUrl = readFileSync(`${PROJECT}/docs/dashboard_url.txt`, "utf-8").trim();
      } catch {}
      return {
        content: [{
          type: "text",
          text: result.exitCode === 0
            ? `✅ Dashboard generated\n${result.stdout.slice(-1000)}\n\nDashboard: ${dashboardUrl || dashboardPath}`
            : `❌ Dashboard generation failed\n${result.stderr}`,
        }],
      };
    }

    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
