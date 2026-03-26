# RStudio Workshop Server

Throwaway NixOS server on Hetzner Cloud for the IQB causal inference workshop.

## Architecture

```
                  :80                    :8787
Browser ───> claim-server.py ───>  RStudio Server
              /          \
         /claim      /gallery
```

- **Hetzner VPS**: your-server-ip (x86_64-linux)
- **SSH**: `ssh root@your-server-ip` (key-based, no password)
- **RStudio Server**: port 8787
- **Claim server**: port 80 (Python, serves login page + DAG gallery)
- **NixOS**: 24.11, standalone flake (not part of the main nix-config flake)

## Files

| File | Purpose |
|------|---------|
| `flake.nix` | Standalone NixOS flake. Output: `nixosConfigurations.rstudio` |
| `configuration.nix` | System config: users, R packages, services, file deployment |
| `disk-config.nix` | Disko disk layout (hybrid BIOS+EFI, LVM) |
| `claim-server.py` | Python HTTP server: login claims (/), admin (/admin), gallery (/gallery) |
| `workshop-files/` | Files rsynced to every participant's home dir on activation |

## Credentials

- **Participant password**: `workshop` (all accounts, set in both `configuration.nix` and `claim-server.py`)
- **Admin page**: `http://your-server-ip/admin?key=changeme`
- **Gallery**: `http://your-server-ip/gallery`

## User accounts

20 accounts named after causal inference researchers (nightingale, pearl, rubin, hernan, etc.). Participants self-assign via the claim page at port 80. All accounts belong to the `gallery` group for shared write access to `/var/lib/gallery/`.

## R packages

Configured in `configuration.nix` under `services.rstudio-server.package`:

```
tidyverse broom quartets lavaan dagitty jsonlite lme4 brms
```

If you add packages, you must rebuild the server (see Deployment below).

## Workshop files

`workshop-files/` contains everything that gets deployed flat to participant home directories:

```
workshop-files/
  hello-world.R           # verification script
  causal-quartet.R        # exercise 1
  helpers.R               # exercise 1 helpers (lavaan)
  dag-collider.png        # DAG images for exercise 1
  dag-confounder.png
  dag-mediator.png
  dag-mbias.png
  dagitty-open-science.R  # exercise 2
  dagitty-helpers.R       # exercise 2 helpers (simulation, plot, submit)
  multilevel-confounding.R  # exercise 3
  multilevel-helpers.R      # exercise 3 helpers (DGP, brms formula)
  multilevel-data.rds       # exercise 3 pre-generated dataset
```

Files are copied by an activation script in `configuration.nix`. They deploy on every `nixos-rebuild switch` and on boot. To update files without a full rebuild, use rsync directly (see Quick file update below).

## Server directories

| Path | Purpose | Permissions |
|------|---------|-------------|
| `/home/<user>/` | Participant workspace | user-owned |
| `/opt/claim/claim-server.py` | Claim server script | root |
| `/var/lib/claim/state.json` | Claim state (who picked which login) | claim-server |
| `/var/lib/gallery/` | Gallery submissions (DAG + bias PNGs, metadata JSON) | 1775, group=gallery |

## Deployment

### Initial install (fresh server)

Uses nixos-anywhere to install NixOS on a fresh Hetzner VPS:

```bash
cd servers/rstudio
nix run github:nix-community/nixos-anywhere -- \
  --flake .#rstudio \
  --target-host root@your-server-ip
```

This wipes the disk, installs NixOS, and reboots. Only needed once.

### Rebuild after config changes

macOS does not have `nixos-rebuild`. Build on the server itself:

```bash
# 1. Copy the flake to the server
cd servers/rstudio
rsync -av --exclude='.git' . root@your-server-ip:/etc/nixos/

# 2. Rebuild on the server
ssh root@your-server-ip "cd /etc/nixos && nixos-rebuild switch --flake .#rstudio"
```

This applies all changes: new R packages, user accounts, activation scripts, systemd services.

### Quick file update (workshop files only, no rebuild)

If you only changed exercise files and don't need package or config changes:

```bash
# Copy files to all participant homes
scp workshop-files/* root@your-server-ip:/tmp/workshop-files/
ssh root@your-server-ip 'for u in nightingale athey hill stuart petersen maathuis didelez uhler perkovic schnitzer pearl rubin wright neyman hernan robins imbens haavelmo spirtes dawid; do rsync -a /tmp/workshop-files/ /home/$u/ && chown -R $u:users /home/$u; done'
```

### Update claim-server.py only

```bash
scp claim-server.py root@your-server-ip:/opt/claim/claim-server.py
ssh root@your-server-ip systemctl restart claim-server
```

## Claim server routes

| Route | Method | Purpose |
|-------|--------|---------|
| `/` | GET | Login claim page — participants pick a researcher name |
| `/` | POST | Claim a login (form submission) |
| `/admin?key=changeme` | GET | Admin view — see claims, unclaim individual or all |
| `/gallery` | GET | DAG gallery — auto-refreshes every 5s, shows submitted DAGs + bias plots |
| `/gallery/images/<file>` | GET | Serves PNG files from `/var/lib/gallery/` |

## Gallery system

Participants call `submit("Pair name")` from R (defined in `dagitty-helpers.R`). This writes:
- `<name>_<timestamp>_dag.png` — base R plot of their dagitty DAG
- `<name>_<timestamp>_bias.png` — ggplot2 bias comparison plot
- `<name>_<timestamp>_meta.json` — metadata (pair name, user, time)

All files go to `/var/lib/gallery/`. The claim server scans this directory and renders the gallery page.

## Admin operations

```bash
# Reset all claims (also available via web admin page)
ssh root@your-server-ip "rm -f /var/lib/claim/state.json"
ssh root@your-server-ip systemctl restart claim-server

# Clear gallery submissions
ssh root@your-server-ip "rm -f /var/lib/gallery/*"

# Check service status
ssh root@your-server-ip "systemctl status claim-server rstudio-server"

# View claim server logs
ssh root@your-server-ip "journalctl -u claim-server -f"

# Check which R packages are available
ssh root@your-server-ip "su - pearl -c 'Rscript -e \"installed.packages()[,1]\"'"
```

## Testing

Automated test script covers all 30 checks (services, endpoints, locale, files, packages, scripts, gallery submission):

```bash
ssh root@your-server-ip "bash /etc/nixos/test-workshop.sh"
```

Run this after every deployment. The script auto-detects R and library paths from the running RStudio wrapper.

## Gotchas

Things that broke and were fixed — don't reintroduce these:

- **claim-server.py is NOT managed by NixOS.** It lives at `/opt/claim/claim-server.py` and must be deployed separately with `scp` + `systemctl restart claim-server`. The `nixos-rebuild switch` only manages the systemd unit, not the script content.
- **`r-libs-user=~/R/library` breaks package loading.** This rsession.conf setting causes R to create an empty `~/R/library` that shadows the nix wrapper's library paths. Removed — do not re-add.
- **ggplot2 is 3.5.1 on NixOS 24.11.** The `ink`/`paper`/`accent` args to `theme_minimal()` require ≥3.5.2. Use `theme_set(theme_minimal())` + `theme_update()` instead.
- **Locale: use `C.UTF-8`, not `en_US.UTF-8`.** RStudio rsessions suffer from a glibc version mismatch between the R binary and locale-archive (known unresolved NixOS issue). `C.UTF-8` is built into glibc and doesn't need `LOCALE_ARCHIVE` at all. Set via `i18n.defaultLocale` and `~/.Renviron` (deployed by activation script). `en_US.UTF-8` will show "Setting LC_CTYPE failed" warnings despite `LOCALE_ARCHIVE` being in the process environment.
- **`nixos-rebuild` doesn't exist on macOS.** Must rsync the flake to the server and rebuild there. See Deployment section.
- **Workshop file sync needs a rebuild.** The activation script runs during `nixos-rebuild switch`. For quick updates without rebuild, use the rsync command in "Quick file update".
