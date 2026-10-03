/**
 * Permission guard for pi, linked to ~/.pi/agent/extensions/guard.ts by
 * pi/install.sh.
 *
 * pi has no permission system of its own, so this restates the rules that
 * claude/settings.json and opencode/opencode.jsonc enforce for the other agents:
 * credential files are unreadable, writes outside the working directory and
 * destructive or irreversible commands need confirmation, and privilege
 * escalation and host control are refused. Without a UI (print/RPC mode),
 * anything that would ask is blocked.
 *
 * Like opencode's permission checks this is not a sandbox: bash commands are
 * matched as text, so a script can still do anything the user can.
 */

import { realpathSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, isAbsolute, resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// A path component named .secrets or .secrets.*, or a file ending in .secrets.
const SECRETS = /(^|\/)\.secrets(\.[^/]*)?(\/|$)|\.secrets$/;

const DENY_COMMANDS = [
	/\bsudo\b/,
	/(^|[;&|(]\s*)su\b/,
	/\bchown\b/,
	/\b(shutdown|reboot|systemctl|service)\b/,
	/\bgh\s+repo\s+delete\b/,
];

const ASK_COMMANDS = [
	/\brm\s+(-[a-zA-Z]*[rR]|--recursive)/,
	/\brmdir\b/,
	/\bgh\s+pr\s+(close|merge)\b/,
	/\bgit\s+push\b.*(\s-f\b|--force)/,
	/\bsrun\b/,
];

// Resolve symlinks of the longest existing prefix, so a link inside the
// working directory cannot point a write outside it.
function realish(path: string): string {
	try {
		return realpathSync(path);
	} catch {
		const parent = dirname(path);
		return parent === path ? path : resolve(realish(parent), path.slice(parent.length + 1));
	}
}

function absolute(path: string, cwd: string): string {
	const expanded = path === "~" || path.startsWith("~/") ? homedir() + path.slice(1) : path;
	return isAbsolute(expanded) ? expanded : resolve(cwd, expanded);
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		const input = event.input as Record<string, unknown>;
		const path = typeof input.path === "string" ? input.path : undefined;

		const ask = async (what: string) => {
			if (ctx.hasUI && (await ctx.ui.confirm("Allow?", what))) return undefined;
			return { block: true, reason: `Needs confirmation: ${what}` };
		};

		switch (event.toolName) {
			case "read":
			case "grep":
			case "find":
			case "ls":
				if (path && SECRETS.test(realish(absolute(path, ctx.cwd)))) {
					return { block: true, reason: "Credential files under .secrets are not readable" };
				}
				return undefined;

			case "write":
			case "edit": {
				if (!path) return undefined;
				const target = realish(absolute(path, ctx.cwd));
				const root = realish(ctx.cwd);
				if (target === root || target.startsWith(root + "/")) return undefined;
				return ask(`${event.toolName} outside the working directory: ${target}`);
			}

			case "bash": {
				const command = String(input.command ?? "");
				if (command.includes(".secrets")) {
					return { block: true, reason: "Credential files under .secrets are not readable" };
				}
				if (DENY_COMMANDS.some((p) => p.test(command))) {
					return { block: true, reason: `Command not allowed: ${command}` };
				}
				if (ASK_COMMANDS.some((p) => p.test(command))) return ask(command);
				return undefined;
			}
		}
		return undefined;
	});
}
