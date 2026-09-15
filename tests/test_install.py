import subprocess
import glob
import os
import pytest

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


@pytest.fixture(scope="module")
def deb_path():
    deb_files = glob.glob(os.path.join(PROJECT_ROOT, "wifi-watchdog_*.deb"))
    assert len(deb_files) >= 1, "No .deb package found. Run 'make deb' first."
    return max(deb_files, key=os.path.getmtime)


@pytest.fixture(scope="module")
def installed():
    pytest.skip("Installation test requires sudo access")
    yield


def test_service_installed(deb_path, installed):
    result = subprocess.run(
        ["systemctl", "is-enabled", "wifi-watchdog.service"],
        capture_output=True, text=True
    )
    assert result.stdout.strip() == "enabled", "Service not enabled"


def test_service_running(deb_path, installed):
    result = subprocess.run(
        ["systemctl", "is-active", "wifi-watchdog.service"],
        capture_output=True, text=True
    )
    assert result.stdout.strip() == "active", "Service not active"


def test_service_unit_exists(deb_path, installed):
    result = subprocess.run(
        ["systemctl", "cat", "wifi-watchdog.service"],
        capture_output=True, text=True
    )
    assert result.returncode == 0, "Service unit not found"
    assert "wifi-watchdog.sh" in result.stdout
    assert "-c /etc/default/wifi-watchdog" in result.stdout


def test_script_exists(deb_path):
    result = subprocess.run(
        ["dpkg-deb", "-c", deb_path], capture_output=True, text=True
    )
    assert "/usr/local/bin/wifi-watchdog.sh" in result.stdout


def test_config_exists(deb_path):
    result = subprocess.run(
        ["dpkg-deb", "-c", deb_path], capture_output=True, text=True
    )
    assert "/etc/default/wifi-watchdog" in result.stdout


def test_service_unit_packaged(deb_path):
    result = subprocess.run(
        ["dpkg-deb", "-c", deb_path], capture_output=True, text=True
    )
    assert "/lib/systemd/system/wifi-watchdog.service" in result.stdout