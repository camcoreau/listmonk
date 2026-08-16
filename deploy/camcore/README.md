# CamCore Listmonk deployment

This directory contains the CamCore deployment layer for Listmonk on Ganymede.

## Design

- Host: Ganymede (`192.168.5.101`)
- Public news URL: `https://camcore.au/news`
- Local Listmonk bind: `192.168.5.101:18088`
- Listmonk container IP: `172.24.0.2`
- PostgreSQL container IP: `172.24.0.3`
- Docker network: `camcore-listmonk` (`172.24.0.0/28`)
- Sender/reply mailbox when mail is later enabled: `help@camcore.au`
- Outbound relay when mail is later enabled: Ganymede Postfix -> Microsoft 365
- Runtime management: Portainer Git-backed stack

Port `9001` is reserved by the Portainer Agent on Ganymede and must not be used by Listmonk.

## Safety state

The supplied Compose stack is deliberately non-sending by default.

Startup order is:

1. PostgreSQL becomes healthy.
2. The one-shot `install` service runs Listmonk's idempotent install/upgrade.
3. The one-shot `bootstrap` service applies `bootstrap.sql`.
4. The long-running Listmonk app starts with `--passive`.

The safety bootstrap:

- disables Listmonk v6.2.0's seeded example SMTP entries;
- sets the initial site name to `CamCore News & Updates`;
- sets the canonical root URL to `https://camcore.au/news`;
- sets the default sender identity to `CamCore <help@camcore.au>`;
- enables the public archive;
- disables public self-subscription and opt-in confirmation initially;
- leaves any future real CamCore SMTP configuration untouched on later redeployments.

In addition, passive mode prevents the campaign manager from processing campaigns. Production sending must not be enabled until a Jayden-only test campaign has been reviewed.

## Portainer deployment

Create the persistent directories once on Ganymede:

```bash
sudo mkdir -p /opt/camcore/listmonk/{uploads,postgres}
```

Create a Portainer stack with:

- Name: `camcore-listmonk`
- Build method: Repository
- Repository URL: `https://github.com/camcoreau/listmonk.git`
- Repository reference during testing: `refs/heads/agent/camcore-deployment-live`
- Compose path: `deploy/camcore/compose.yml`

Set these environment variables in Portainer:

```env
LISTMONK_BIND_IP=192.168.5.101
LISTMONK_BIND_PORT=18088
LISTMONK_ADMIN_USER=camcore_admin
LISTMONK_ADMIN_PASSWORD=<long random password>
LISTMONK_DB_PASSWORD=<different long random password>
```

Deploy from Portainer. The `install` and `bootstrap` containers should exit successfully after doing their one-shot work. `camcore-listmonk-db` should remain healthy and `camcore-listmonk` should remain running.

Expected application log text includes:

`running in passive mode. won't process campaigns.`

It should no longer initialise the seeded `username@smtp.yoursite.com` SMTP messenger.

## Initial access

Open the private/local admin console at:

`http://192.168.5.101:18088/admin`

The bootstrap already applies the initial CamCore site name, root URL, sender identity and public archive settings. SMTP remains disabled.

The custom public template in `static/public/templates/index.html` prefixes Listmonk public static assets with `RootURL`, allowing subscriber-facing pages to work behind the `/news` gateway while leaving Listmonk's admin/private API routes off the public CamCore site.

## Public gateway

The CamCore portal proxies only subscriber-facing Listmonk routes under `/news` and strips the `/news` prefix before forwarding them to `http://192.168.5.101:18088`.

Public routes include the archive, campaign views, tracking links, subscription pages, public assets and public captcha endpoints. `/admin` and private `/api` routes must not be exposed through `camcore.au/news`.

## Mail relay enablement - later phase

Current Ganymede Postfix users must remain working:

- `requests.camcore.au` (`192.168.5.24`)
- YouTrack (`172.21.0.4`)
- Tautulli (`172.21.0.5`)
- Beszel (`172.21.0.6`)

When SMTP is deliberately enabled for Listmonk, add only the fixed Listmonk application address to Postfix trust:

```bash
sudo postconf -e 'mynetworks = 127.0.0.0/8, 192.168.4.0/22, 172.21.0.0/16, 172.24.0.2/32'
sudo postfix check
sudo systemctl reload postfix
```

Then configure Listmonk SMTP to submit to `192.168.5.101:25` without authentication, using `help@camcore.au` as the sender/reply mailbox.

Before removing passive mode, send a test only to a dedicated Jayden test list and verify successful delivery through Microsoft 365.

## Backups

Back up both persistent directories:

- `/opt/camcore/listmonk/postgres`
- `/opt/camcore/listmonk/uploads`

The PostgreSQL data directory is the critical state and should be included in the normal CamCore backup process before production use.
