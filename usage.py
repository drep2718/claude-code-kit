#!/usr/bin/env python3
"""Parse Claude Code transcripts into cross-session token usage.
Writes a markdown log (human/Obsidian) + JSON (dashboard). Read-only on transcripts.
Usage: usage.py [--json]   (default writes ~/.claude/token-usage.md and prints JSON)
"""
import json, os, sys, glob
from collections import defaultdict
from datetime import datetime, timezone

HOME = os.path.expanduser("~")
PROJECTS = os.path.join(HOME, ".claude", "projects")
MD_OUT = os.path.join(HOME, ".claude", "token-usage.md")

# Rough $/1M tokens (Sonnet-class) — estimate only. Cache reads are ~10x cheaper
# than fresh input, cache writes ~1.25x; output is the expensive one.
PRICE_IN, PRICE_OUT = 3.0, 15.0
PRICE_CACHE_READ, PRICE_CACHE_WRITE = 0.30, 3.75


def day_of(ts):
    try:
        return datetime.fromisoformat(ts.replace("Z", "+00:00")).astimezone(timezone.utc).strftime("%Y-%m-%d")
    except Exception:
        return None


def collect():
    per_day = defaultdict(lambda: {"in": 0, "out": 0, "cache": 0, "cr": 0, "cc": 0, "sessions": set(), "msgs": 0})
    per_proj = defaultdict(lambda: {"in": 0, "out": 0, "cache": 0, "cr": 0, "cc": 0, "sessions": set()})
    tot = {"in": 0, "out": 0, "cache": 0, "cr": 0, "cc": 0, "sessions": set(), "msgs": 0}

    for f in glob.glob(os.path.join(PROJECTS, "**", "*.jsonl"), recursive=True):
        sid = os.path.basename(f)[:-6]
        proj = os.path.basename(os.path.dirname(f)).lstrip("-").replace("-", "/")
        fday = datetime.fromtimestamp(os.path.getmtime(f), timezone.utc).strftime("%Y-%m-%d")
        try:
            with open(f, "r", errors="ignore") as fh:
                for line in fh:
                    if '"usage"' not in line:
                        continue
                    try:
                        ev = json.loads(line)
                    except Exception:
                        continue
                    u = (ev.get("message") or {}).get("usage")
                    if not isinstance(u, dict):
                        continue
                    i = (u.get("input_tokens") or 0)
                    o = (u.get("output_tokens") or 0)
                    cr = (u.get("cache_read_input_tokens") or 0)
                    cc = (u.get("cache_creation_input_tokens") or 0)
                    c = cr + cc
                    d = day_of(ev.get("timestamp", "")) or fday
                    for bucket in (per_day[d], per_proj[proj], tot):
                        bucket["in"] += i; bucket["out"] += o
                        bucket["cache"] += c; bucket["cr"] += cr; bucket["cc"] += cc
                        bucket["sessions"].add(sid)
                    per_day[d]["msgs"] += 1; tot["msgs"] += 1
        except Exception:
            continue

    def cost(d):
        return round(d["in"] / 1e6 * PRICE_IN + d["out"] / 1e6 * PRICE_OUT
                     + d["cr"] / 1e6 * PRICE_CACHE_READ + d["cc"] / 1e6 * PRICE_CACHE_WRITE, 2)

    days = []
    for d in sorted(per_day.keys())[-30:]:
        r = per_day[d]
        days.append({"day": d, "in": r["in"], "out": r["out"], "cache": r["cache"],
                     "total": r["in"] + r["out"] + r["cache"], "sessions": len(r["sessions"]),
                     "msgs": r["msgs"], "cost": cost(r)})
    projs = []
    for p in sorted(per_proj, key=lambda k: -(per_proj[k]["in"] + per_proj[k]["out"] + per_proj[k]["cache"]))[:10]:
        r = per_proj[p]
        projs.append({"project": p or "(unknown)", "total": r["in"] + r["out"] + r["cache"],
                      "sessions": len(r["sessions"]), "cost": cost(r)})
    return {
        "generatedAt": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "totals": {"in": tot["in"], "out": tot["out"], "cache": tot["cache"],
                   "total": tot["in"] + tot["out"] + tot["cache"],
                   "sessions": len(tot["sessions"]), "msgs": tot["msgs"], "cost": cost(tot)},
        "days": days, "projects": projs,
    }


def write_md(data):
    t = data["totals"]
    def k(n): return f"{n/1000:.1f}K" if n < 1e6 else f"{n/1e6:.2f}M"
    lines = [
        "# Token usage — across all sessions", "",
        f"_Generated {data['generatedAt']} by `cckit usage`. Parsed from ~/.claude/projects transcripts._", "",
        f"- **Total tokens:** {t['total']:,} ({k(t['total'])})  ·  **Sessions:** {t['sessions']}  ·  **Assistant turns:** {t['msgs']}",
        f"- **Input:** {t['in']:,} · **Output:** {t['out']:,} · **Cache:** {t['cache']:,}",
        f"- **Est. cost:** ${t['cost']:,.2f} _(rough blended estimate)_", "",
        "## Last 30 active days", "",
        "| Day | Total | Output | Sessions | Est. $ |", "|---|--:|--:|--:|--:|",
    ]
    for d in reversed(data["days"]):
        lines.append(f"| {d['day']} | {d['total']:,} | {d['out']:,} | {d['sessions']} | ${d['cost']:.2f} |")
    lines += ["", "## Top projects by tokens", "", "| Project | Total | Sessions | Est. $ |", "|---|--:|--:|--:|"]
    for p in data["projects"]:
        lines.append(f"| {p['project']} | {p['total']:,} | {p['sessions']} | ${p['cost']:.2f} |")
    lines.append("")
    with open(MD_OUT, "w") as fh:
        fh.write("\n".join(lines))


if __name__ == "__main__":
    data = collect()
    write_md(data)
    print(json.dumps(data))
