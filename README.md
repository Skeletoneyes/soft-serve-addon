# Soft Serve — Home Assistant Add-on

Runs [`charmbracelet/soft-serve`](https://github.com/charmbracelet/soft-serve), a
self-hosted, SSH-native Git server, as a Home Assistant add-on. It provides
private git remotes hosted entirely on your own hardware — no web stack, no
database, no cloud.

## Why

A git repo is two things: **version history** (`.git/`, already on your own
disk) and **the remote** (the only third-party-touching part). This add-on
moves the remote onto the always-on HA host, so full git history + rollback
live inside the house with nothing on a third party's server.

## Install

1. **Add-ons → Add-on Store → ⋮ → Repositories** and add:
   `https://github.com/Skeletoneyes/soft-serve-addon`
2. Install **Soft Serve Git**.
3. In **Configuration**, add one or more `admin_keys` — your SSH **public**
   keys (e.g. `ssh-ed25519 AAAA...`). These keys get full admin rights.
4. Start the add-on.

## Use

```sh
# Browse / admin TUI
ssh -p 23231 <ha-host>

# Create a private repo
ssh -p 23231 <ha-host> repo create pai -p

# Clone / push
git clone ssh://<ha-host>:23231/pai
```

## Notes

- `admin_keys` are **public** keys — safe to store here; nothing secret lives in
  this repo.
- Data (repos + server state) persists on the add-on's `/data` volume via
  `SOFT_SERVE_DATA_PATH=/data`. Make sure your HA backups cover add-on data.
- Built for `aarch64` (Raspberry Pi). Add `amd64` to `config.yaml`'s `arch:`
  list if you need it elsewhere.
