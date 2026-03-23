# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "requests>=2,<3",
#     "mcp>=1.2.0,<2",
# ]
# ///

from os import path
from typing import Annotated
import subprocess
import requests
from pathlib import Path
from mcp.server.fastmcp import FastMCP

BASE_URL = "http://127.0.0.1:52000"

app = FastMCP("ported_tim_tester")


def _call(endpoint: str, body: dict | None = None) -> str:
    resp = requests.post(f"{BASE_URL}{endpoint}", json=body or {})
    resp.raise_for_status()
    return resp.text


@app.tool()
def run_object(
    name: Annotated[str, "Object name"],
    length: Annotated[int, "Object length in frames"],
    parameters: Annotated[
        dict[str, dict],
        'Parameters map. Each value is {"type": "scalar", "value": "..."} or {"type": "ease", "start": "...", "end": "..."}',
    ] = {},
) -> str:
    """Create and run an object, returning the nonce."""
    return _call(
        "/run_object", {"name": name, "length": length, "parameters": parameters}
    )


@app.tool()
def run_effect(
    source_path: Annotated[str, "Source image file path"],
    name: Annotated[str, "Effect name"],
    length: Annotated[int, "Object length in frames"],
    parameters: Annotated[
        dict[str, dict],
        'Parameters map. Each value is {"type": "scalar", "value": "..."} or {"type": "ease", "start": "...", "end": "..."}',
    ] = {},
) -> str:
    """Apply an effect on a source image, returning the nonce."""
    return _call(
        "/run_effect",
        {
            "source_path": source_path,
            "name": name,
            "length": length,
            "parameters": parameters,
        },
    )


script_dir = Path(__file__).parent.resolve()
aviutl2_dir = script_dir / ".." / ".aviutl2-cli" / "development"


@app.tool()
def launch() -> str:
    """Launch the AviUtl2 process. This should be called before any other tool."""
    subprocess.Popen([aviutl2_dir / "aviutl2.exe"], cwd=aviutl2_dir)
    return "AviUtl2 launched"


last_log_line = 0


@app.tool()
def fetch_new_logs() -> str:
    """Fetch new log lines from the AviUtl2 process."""
    global last_log_line
    log_dir = aviutl2_dir / "data" / "Log"
    if not log_dir.exists():
        return "Log directory does not exist"
    log_files = sorted(
        log_dir.glob("*.log"), key=lambda f: f.stat().st_mtime, reverse=True
    )
    if not log_files:
        return "No log files found"
    latest_log = log_files[0]
    with latest_log.open("r", encoding="shift_jis", errors="ignore") as f:
        lines = f.readlines()
    new_lines = lines[last_log_line:]
    last_log_line += len(new_lines)
    return "".join(new_lines) if new_lines else "No new log lines"


@app.tool()
def quit() -> str:
    """Quit the AviUtl2 process."""
    return _call("/quit")


if __name__ == "__main__":
    app.run()
