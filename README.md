<!-- CAMCORE-REPOSITORY-BRANDING:START -->
<p align="center">
  <a href="https://camcore.au">
    <img src=".github/brand/camcore-repository-banner.svg" alt="CamCore" width="520">
  </a>
</p>
<!-- CAMCORE-REPOSITORY-BRANDING:END -->

# CamCore News & Updates deployment

This repository is CamCore's deployment fork of
[listmonk](https://github.com/knadh/listmonk). It carries the reviewed
configuration used to integrate the upstream application with **CamCore –
Cameron Family Secure Network**.

> **CamCore is a privately owned and operated family technology network that
> delivers secure, reliable and professionally managed digital services for the
> Cameron household, Cameron-Media and associated family operations.**

**Built for Home. Engineered Like Enterprise.**

## CamCore scope

- **Application source:** listmonk remains an upstream project maintained by
  knadh and its contributors. CamCore does not claim authorship of the upstream
  application.
- **Runtime image:** the CamCore deployment uses the official
  `listmonk/listmonk:v6.2.0` image. This repository does not publish a separate
  CamCore application image.
- **Deployment layer:** [`deploy/camcore/`](deploy/camcore/) contains the
  Compose stack, safe bootstrap and operating guidance for CamCore.
- **Safety boundary:** campaign processing starts in passive mode. The intended
  public surface is the subscriber-facing [`/news`](https://camcore.au/news)
  gateway; the administration console and private API are not public routes.
- **State:** repository contents describe the source and deployment contract.
  They do not by themselves prove that a particular revision is deployed or
  that the live service is healthy.

See the [CamCore deployment guide](deploy/camcore/README.md) for configuration,
verification, backup and controlled mail-enablement guidance.

The upstream application remains licensed under the
[GNU Affero General Public License v3.0](LICENSE).

---

## Upstream listmonk documentation

<a href="https://zerodha.tech"><img src="https://zerodha.tech/static/images/github-badge.svg" align="right" /></a>

[![listmonk-logo](https://user-images.githubusercontent.com/547147/231084896-835dba66-2dfe-497c-ba0f-787564c0819e.png)](https://listmonk.app)

listmonk is a standalone, self-hosted, newsletter and mailing list manager. It is fast, feature-rich, and packed into a single binary. It uses a PostgreSQL database as its data store.

[![listmonk-dashboard](https://github.com/user-attachments/assets/689b5fbb-dd25-4956-a36f-e3226a65f9c4)](https://listmonk.app)

Visit [listmonk.app](https://listmonk.app) for more info. Check out the [**live demo**](https://demo.listmonk.app).

## Installation

### Docker

The latest image is available on DockerHub at [`listmonk/listmonk:latest`](https://hub.docker.com/r/listmonk/listmonk/tags?page=1&ordering=last_updated&name=latest).
Download and use the sample [docker-compose.yml](https://github.com/knadh/listmonk/blob/master/docker-compose.yml).


```shell
# Download the compose file to the current directory.
curl -LO https://github.com/knadh/listmonk/raw/master/docker-compose.yml

# Run the services in the background.
docker compose up -d
```
Visit `http://localhost:9000`

See [installation docs](https://listmonk.app/docs/installation)

__________________

### Binary
- Download the [latest release](https://github.com/knadh/listmonk/releases) and extract the listmonk binary.
- `./listmonk --new-config` to generate config.toml. Edit it.
- `./listmonk --install` to setup the Postgres DB (or `--upgrade` to upgrade an existing DB. Upgrades are idempotent and running them multiple times have no side effects).
- Run `./listmonk` and visit `http://localhost:9000`

See [installation docs](https://listmonk.app/docs/installation)
__________________


## Developers
listmonk is free and open source software licensed under AGPLv3. If you are interested in contributing, refer to the [developer setup](https://listmonk.app/docs/developer-setup). The backend is written in Go and the frontend is Vue with Buefy for UI. 


## License
listmonk is licensed under the AGPL v3 license.
