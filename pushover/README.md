# push-route — which devices get `push-alert` messages

`push-alert` (in `bin/`) sends to a Pushover **delivery group** whose key is
`PUSHOVER_ALERTS`. Who receives an alert is decided by that group's membership
on Pushover's servers, so `push-route` edits the membership rather than any
local config: a change applies at once on every machine and in every job that
is already running, and any machine with these dotfiles can make it.

```
push-route                  list the group's rows and whether each is on
push-route only phone       enable phone, disable your other devices
push-route on desktop       enable devices (several names allowed)
push-route off phone        disable devices
push-route all              enable every device of yours in the group
push-route add ipad         add a device row (it must be registered to your account)
push-route remove ipad      remove a device row
push-route setup            one row per registered device (first run)
push-route -n only phone    print what would change, change nothing
```

`bin/push-route` is a relative symlink to `pushover/push-route`, so it is on
`PATH` wherever `bin/` is. The script is stdlib-only Python 3 and avoids newer
syntax, so it runs on cluster Pythons too.

## How it works

A group row is a user key plus an optional device. A row **with** a device
delivers only to that device; one **without** (a whole-account row) delivers
to every device on the account. Pushover's Groups API
([pushover.net/api/groups](https://pushover.net/api/groups)) has
`enable_user` / `disable_user` / `add_user` / `remove_user`, each taking an
optional `device`.

- **`setup` first.** A whole-account row cannot be switched per device, and
  cannot be removed on its own: `remove_user` without a device drops every row
  of that user key. So `setup` removes your rows and adds one enabled row per
  device registered to your account (`users/validate`); on/off settings of
  earlier rows are lost in that case. Every other command refuses to run
  while a whole-account row of yours exists, rather than act on it by accident.
- **Every other call names a device.** Without one, `disable_user` would
  silence all your rows at once.
- **`only` enables before it disables**, so a failure halfway never leaves you
  with no device on.
- Other members of the group are listed but never touched.
- Unverified: that Pushover accepts several rows for one user key differing
  only by device. `push-route -n setup` then `push-route setup` settles it.

## Credentials

Read the same way as `push` and `push-alert`, environment first:
`PUSHOVER_API_TOKEN` and `PUSHOVER_USER_KEY` from `~/.secrets/pushover` (or
`PUSHOVER_CREDENTIALS`), `PUSHOVER_ALERTS` picked out of `~/.localrc` without
sourcing it. `PUSHOVER_USER_KEY` must be **your** user key, not the group key.
Management calls need an app token owned by the account that owns the group
(the docs say so; sending only needs any token). No key is ever printed.

## Trade-offs

- Routing is shared: turning a device off silences it for every sender. Routing
  by source (cluster A to the phone, cluster B to the desktop) would need a
  second group and key.
- `push -d <device>` / `PUSHOVER_DEVICE` still exist but are fixed when a job
  starts; keep them for one-off overrides.

## Tests

`pushover/tests/` runs against an in-memory fake of the group; nothing reaches
Pushover. Needs only pytest: `python3 -m pytest ~/.dotfiles/pushover/tests`.
