"""Compile the package and run state tests under Luau CLI."""
from pathlib import Path
from subprocess import run, DEVNULL
from sys import argv
from tempfile import TemporaryDirectory

if len(argv) != 3:
    raise SystemExit("Usage: python3 tests/run-cli.py LUAU LUAU_COMPILE")

root = Path(__file__).resolve().parents[1]
source = root / "RyouUI.lua"
smoke = root / "tests" / "Smoke.client.lua"
mock = root / "tests" / "RobloxMock.lua"
scripts = [source, smoke, mock, *sorted((root / "examples").glob("*.lua"))]
run([argv[2], *map(str, scripts)], check=True, stdout=DEVNULL)
with TemporaryDirectory() as folder:
    fixture = Path(folder) / "smoke.lua"
    assertion_code = smoke.read_text().split("\n", 2)[2]
    fixture.write_text(f"{mock.read_text()}\nlocal function module()\n{source.read_text()}"
                       f"\nend\nlocal UI = module()\n{assertion_code}")
    run([argv[1], str(fixture)], check=True)
