# CamCore Listmonk deployment

This directory contains the CamCore deployment layer for Listmonk on Ganymede.

## Design

- Host: Ganymede (`192.168.5.101`)
- Public news URL: `https://camcore.au/news`
- Local Listmonk bind: `192.168.5.101:9001`
- Listmonk container IP: `172.24.0.2`
- PostgreSQL container IP: `172.24.0.3`
- Docker network: `camcore-listmonk` (`172.24.0.0/28`)
- Sender/reply mailbox when mail is later enabled: `help@camcore.au`
- Outbound relay when mail is later enabled: Ganymede Postfix -> Microsoft 365

## Safety state

The supplied Compose file starts Listmonk with `--passive` and does not configure SMTP.

This is intentional. In this state:

- campaigns are not processed by the campaign manager;
- no SMTP server is configured in Listmonk;
- the UI, lists, templates, subscribers and public archive can be prepared safely;
- production sending must not be enabled until a Jayden-only test campaign has been reviewed.

Removing `--passive` is a deliberate production-enablement change and should be made separately.

## First deployment

On Ganymede:

```bash
sudo mkdir -p /opt/camcore/listmonk/{uploads,postgres}
sudo chown -R "$USER":"$USER" /opt/camcore/listmonk

cd /opt/camcore/listmonk
git clone https://github.com/camcoreau/listmonk.git source
cd source
git checkout agent/camcore-deployment-live
cd deploy/camcore
cp .env.example .env
```

Generate two different long random passwords and place them in `.env` for:

- `LISTMONK_ADMIN_PASSWORD`
- `LISTMONK_DB_PASSWORD`

Then validate and start:

```bash
docker compose --env-file .env config
docker compose --env-file .env up -d
docker compose --env-file .env ps
docker logs --tail 100 camcore-listmonk
```

Expected first-start log text includes the passive-mode notice that campaigns will not be processed.

## Initial Listmonk settings

Open the local admin console at:

`http://192.168.5.101:9001/admin`

Before any public route is enabled, configure:

- Site name: `CamCore News & Updates`
- Root URL: `https://camcore.au/news`
- Public archive: enabled
- Public subscription page: disabled initially
- From email: `CamCore <help@camcore.au>`
- Logo/favicon: CamCore assets

Do not configure an SMTP server during the initial deployment.

The custom public template in `static/public/templates/index.html` prefixes Listmonk public static assets with `RootURL`, allowing the public archive and subscriber-facing pages to work behind the `/news` gateway while leaving Listmonk's admin/API routes private.

## Public gateway

The CamCore portal should proxy only subscriber-facing Listmonk routes under `/news` and strip the `/news` prefix before forwarding them to `http://192.168.5.101:9001`.

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
