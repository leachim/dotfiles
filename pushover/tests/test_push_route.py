"""Tests for push-route. The Pushover API is faked; nothing leaves the machine."""

import importlib.machinery
import importlib.util
import io
import json
import urllib.error
from pathlib import Path

import pytest

CLI = Path(__file__).resolve().parents[1] / "push-route"
_loader = importlib.machinery.SourceFileLoader("push_route", str(CLI))
_spec = importlib.util.spec_from_loader("push_route", _loader)
pr = importlib.util.module_from_spec(_spec)
_loader.exec_module(pr)

ME, OTHER, GROUP = "u-me", "u-other", "g-alerts"


class FakeApi:
    """Applies membership calls to an in-memory group, like Pushover would."""

    def __init__(self, rows, registered=("phone", "desktop", "ipad")):
        self.rows = [dict(r) for r in rows]
        self.registered = list(registered)
        self.calls = []

    def group(self, group):
        return {"name": "Alerts", "users": [dict(r) for r in self.rows]}

    def devices(self, user):
        return list(self.registered)

    def member(self, group, action, user, device=None):
        self.calls.append((action, device))
        hit = [
            r
            for r in self.rows
            if r["user"] == user and (device is None or r.get("device") == device)
        ]
        if action == "add_user":
            self.rows.append(
                {"user": user, "device": device, "memo": "", "disabled": False}
            )
        elif action == "remove_user":
            self.rows = [r for r in self.rows if r not in hit]
        else:
            for r in hit:
                r["disabled"] = action == "disable_user"


def row(device, on=True, user=ME):
    return {"user": user, "device": device, "memo": "", "disabled": not on}


def state(api):
    return {(r["user"], r["device"]): not r["disabled"] for r in api.rows}


def run(argv, api):
    lines = []
    code = pr.run(argv, api=api, credentials=("tok", ME, GROUP), out=lines.append)
    return code, "\n".join(lines)


class TestSwitching:
    def test_only_enables_target_and_disables_the_rest(self):
        api = FakeApi([row("phone", False), row("desktop"), row("ipad")])
        run(["only", "phone"], api)
        assert state(api) == {
            (ME, "phone"): True,
            (ME, "desktop"): False,
            (ME, "ipad"): False,
        }

    def test_only_enables_before_disabling(self):
        # A failure mid-plan must not leave every device off.
        api = FakeApi([row("phone", False), row("desktop")])
        run(["only", "phone"], api)
        assert api.calls == [("enable_user", "phone"), ("disable_user", "desktop")]

    def test_only_leaves_other_members_alone(self):
        api = FakeApi([row("phone"), row("desktop"), row(None, user=OTHER)])
        run(["only", "phone"], api)
        assert state(api)[(OTHER, None)] is True

    def test_every_call_names_a_device(self):
        # Without a device, disable_user hits every row of the user.
        api = FakeApi([row("phone"), row("desktop"), row("ipad", False)])
        for argv in (["off", "phone"], ["on", "ipad"], ["only", "desktop"], ["all"]):
            run(argv, api)
        assert api.calls and all(device for _, device in api.calls)

    def test_no_op_makes_no_calls(self):
        api = FakeApi([row("phone"), row("desktop", False)])
        code, out = run(["only", "phone"], api)
        assert code == 0 and api.calls == [] and "nothing to change" in out

    def test_dry_run_changes_nothing(self):
        api = FakeApi([row("phone"), row("desktop")])
        code, out = run(["-n", "off", "phone"], api)
        assert api.calls == [] and "would off phone" in out

    def test_unknown_device_is_refused(self):
        api = FakeApi([row("phone")])
        with pytest.raises(pr.RouteError, match="not in the group: tablet"):
            run(["on", "tablet"], api)
        assert api.calls == []

    def test_whole_account_row_is_refused(self):
        api = FakeApi([row(None)])
        with pytest.raises(pr.RouteError, match="push-route setup"):
            run(["only", "phone"], api)
        assert api.calls == []


class TestMembership:
    def test_setup_splits_a_whole_account_row(self):
        api = FakeApi([row(None), row(None, user=OTHER)])
        run(["setup"], api)
        assert api.calls[0] == ("remove_user", None)
        assert state(api) == {
            (OTHER, None): True,
            (ME, "phone"): True,
            (ME, "desktop"): True,
            (ME, "ipad"): True,
        }

    def test_setup_only_adds_what_is_missing(self):
        api = FakeApi([row("phone", False)])
        run(["setup"], api)
        assert api.calls == [("add_user", "desktop"), ("add_user", "ipad")]
        assert state(api)[(ME, "phone")] is False

    def test_add_rejects_unregistered_device(self):
        api = FakeApi([row("phone")])
        with pytest.raises(pr.RouteError, match="not a device on your account"):
            run(["add", "watch"], api)

    def test_add_and_remove(self):
        api = FakeApi([row("phone")])
        run(["add", "desktop"], api)
        run(["remove", "phone"], api)
        assert state(api) == {(ME, "desktop"): True}


class TestListing:
    def test_list_marks_state_and_missing_devices(self):
        api = FakeApi([row("phone"), row("desktop", False), row(None, user=OTHER)])
        _, out = run([], api)
        assert "on   phone" in out
        assert "off  desktop" in out
        assert "[other member]" in out
        assert "not in the group: ipad" in out

    def test_list_warns_when_everything_is_off(self):
        api = FakeApi([row("phone", False)])
        _, out = run(["list"], api)
        assert "every device of yours is off" in out

    def test_keys_never_printed(self):
        api = FakeApi([row("phone"), row(None, user=OTHER)])
        _, out = run([], api)
        for secret in (ME, OTHER, GROUP, "tok"):
            assert secret not in out


class TestArgs:
    @pytest.mark.parametrize(
        "argv",
        [["frobnicate"], ["on"], ["all", "phone"], ["on", "bad name"], ["only"]],
    )
    def test_bad_arguments(self, argv):
        with pytest.raises(pr.RouteError):
            pr.parse_args(argv)


class TestCredentials:
    def test_reads_files_like_the_shell_would(self, tmp_path):
        (tmp_path / ".secrets").mkdir()
        (tmp_path / ".secrets" / "pushover").write_text(
            'export PUSHOVER_API_TOKEN="tok"\nPUSHOVER_USER_KEY=old\n'
            "PUSHOVER_USER_KEY='me'\n"
        )
        (tmp_path / ".localrc").write_text(
            "export PATH=/x\n  export PUSHOVER_ALERTS=grp\nSECRET=nope\n"
        )
        assert pr.load_credentials(env={}, home=str(tmp_path)) == ("tok", "me", "grp")

    def test_environment_wins(self, tmp_path):
        env = {
            "PUSHOVER_API_TOKEN": "t",
            "PUSHOVER_USER_KEY": "u",
            "PUSHOVER_ALERTS": "g",
        }
        assert pr.load_credentials(env=env, home=str(tmp_path)) == ("t", "u", "g")

    def test_missing_names_what_is_missing_only(self, tmp_path):
        env = {"PUSHOVER_API_TOKEN": "secret-token", "PUSHOVER_USER_KEY": "u"}
        with pytest.raises(pr.RouteError) as exc:
            pr.load_credentials(env=env, home=str(tmp_path))
        assert "PUSHOVER_ALERTS" in str(exc.value)
        assert "secret-token" not in str(exc.value)

    def test_group_key_as_user_key_is_refused(self, tmp_path):
        env = {
            "PUSHOVER_API_TOKEN": "t",
            "PUSHOVER_USER_KEY": "g",
            "PUSHOVER_ALERTS": "g",
        }
        with pytest.raises(pr.RouteError, match="group key"):
            pr.load_credentials(env=env, home=str(tmp_path))


class TestHttp:
    def opener(self, status, body):
        def fake(req, timeout):
            self.req = req
            if status != 200:
                raise urllib.error.HTTPError(
                    req.full_url, status, "err", {}, io.BytesIO(body)
                )
            return io.BytesIO(body)

        return fake

    def test_post_sends_token_in_body(self):
        api = pr.Pushover("tok", self.opener(200, b'{"status":1}'))
        api.member(GROUP, "disable_user", ME, "phone")
        assert self.req.full_url.endswith("/groups/g-alerts/disable_user.json")
        sent = dict(pair.split("=") for pair in self.req.data.decode().split("&"))
        assert sent == {"user": ME, "device": "phone", "token": "tok"}

    def test_400_surfaces_pushover_errors(self):
        body = json.dumps({"status": 0, "errors": ["device is invalid"]}).encode()
        api = pr.Pushover("tok", self.opener(400, body))
        with pytest.raises(pr.RouteError, match="device is invalid"):
            api.group(GROUP)

    def test_other_http_errors_do_not_leak_the_url(self):
        api = pr.Pushover("tok", self.opener(500, b"<html>"))
        with pytest.raises(pr.RouteError) as exc:
            api.group(GROUP)
        assert "tok" not in str(exc.value) and "500" in str(exc.value)
