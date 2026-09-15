import subprocess
import os
import glob

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def test_make_deb():
    for f in glob.glob(os.path.join(PROJECT_ROOT, "wifi-watchdog_*.deb")):
        os.remove(f)
    result = subprocess.run(
        ["make", "deb"], capture_output=True, text=True, cwd=PROJECT_ROOT
    )
    assert result.returncode == 0, f"make deb failed: {result.stderr}"
    deb_files = glob.glob(os.path.join(PROJECT_ROOT, "wifi-watchdog_*.deb"))
    assert len(deb_files) == 1, f"Expected 1 .deb, got {len(deb_files)}"
    deb_path = deb_files[0]
    assert os.path.getsize(deb_path) > 0, ".deb package is empty"
    result = subprocess.run(
        ["dpkg-deb", "-f", deb_path], capture_output=True, text=True
    )
    assert "Package: wifi-watchdog" in result.stdout