"""Compile the package and run state tests under Luau CLI."""
from json import loads
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
neo = root / "tests" / "NeoState.lua"
showcase = root / "examples" / "NeoShowcase.lua"
assets = root / "tests" / "NeoAssets.lua"
manifest = loads((root / "assets" / "neo" / "manifest.json").read_text())
sizes = ", ".join(f'["{asset["path"].rsplit("/", 1)[1]}"]={asset["bytes"]}' for asset in manifest["assets"])
scripts = [source, smoke, mock, neo, assets, *sorted((root / "examples").glob("*.lua"))]
run([argv[2], *map(str, scripts)], check=True, stdout=DEVNULL)
with TemporaryDirectory() as folder:
    fixture = Path(folder) / "smoke.lua"
    assertion_code = smoke.read_text().split("\n", 2)[2]
    fixture.write_text(f"{mock.read_text()}\nlocal function module()\n{source.read_text()}"
                       f"\nend\nlocal UI = module()\ndo\n{assertion_code}\nend\n{neo.read_text()}"
                       f"\nlocal function showcase()\n{showcase.read_text()}\nend\n"
                       "local window = showcase()(UI, { Open = false, Motion = 'Off' })\n"
                       "window:Open()\nassert(#window.Tabs == 5 and window.Opened)\nwindow:Destroy()\n"
                       f"print('Neo Sidebar showcase: OK')\n{assets.read_text()}\n"
                       f'testNeoAssets(module, {{{sizes}}}, "{manifest["revision"]}")\n')
    run([argv[1], str(fixture)], check=True)
