<!--
SPDX-FileCopyrightText: 2020 Aaron Raimist
SPDX-FileCopyrightText: 2020 Chris van Dijk
SPDX-FileCopyrightText: 2020 Dominik Zajac
SPDX-FileCopyrightText: 2020 Mickaël Cornière
SPDX-FileCopyrightText: 2020-2024 MDAD project contributors
SPDX-FileCopyrightText: 2020-2024 Slavi Pantaleev
SPDX-FileCopyrightText: 2022 François Darveau
SPDX-FileCopyrightText: 2022 Julian Foad
SPDX-FileCopyrightText: 2022 Warren Bailey
SPDX-FileCopyrightText: 2023 Antonis Christofides
SPDX-FileCopyrightText: 2023 Felix Stupp
SPDX-FileCopyrightText: 2023 Pierre 'McFly' Marty
SPDX-FileCopyrightText: 2024-2026 Suguru Hirahara

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Setting up Paperless-ngx

This is an [Ansible](https://www.ansible.com/) role which installs [Paperless-ngx](https://www.paperless.online/) to run as a [Docker](https://www.docker.com/) container wrapped in a systemd service.

Paperless-ngx is a podcast management system that manages podcasts with multi-user support.

See the project's [documentation](https://www.paperless.online/docs/intro) to learn what Paperless-ngx does and why it might be useful to you.

## Prerequisites

To run a Paperless-ngx instance it is necessary to prepare a database and [Redis](https://redis.io/) database for managing cache data. For a database you can use [MariaDB](https://mariadb.org/) or [Postgres](https://www.postgresql.org/).

If you are looking for Ansible roles for them, you can check out these roles maintained by the [Mother-of-All-Self-Hosting (MASH)](https://github.com/mother-of-all-self-hosting) team:

- [ansible-role-mariadb](https://github.com/mother-of-all-self-hosting/ansible-role-mariadb)
- [ansible-role-postgres](https://github.com/mother-of-all-self-hosting/ansible-role-postgres)
- [ansible-role-redis](https://github.com/mother-of-all-self-hosting/ansible-role-redis)
- [ansible-role-valkey](https://github.com/mother-of-all-self-hosting/ansible-role-valkey)

## Adjusting the playbook configuration

To enable Paperless-ngx with this role, add the following configuration to your `vars.yml` file.

**Note**: the path should be something like `inventory/host_vars/mash.example.com/vars.yml` if you use the [MASH Ansible playbook](https://github.com/mother-of-all-self-hosting/mash-playbook).

```yaml
########################################################################
#                                                                      #
# paperless                                                            #
#                                                                      #
########################################################################

paperless_enabled: true

########################################################################
#                                                                      #
# /paperless                                                           #
#                                                                      #
########################################################################
```

### Set the hostname

To enable Paperless-ngx you need to set the hostname as well. To do so, add the following configuration to your `vars.yml` file. Make sure to replace `example.com` with your own value.

```yaml
paperless_hostname: "example.com"
```

After adjusting the hostname, make sure to adjust your DNS records to point the domain to your server.

**Note**: hosting Paperless-ngx under a subpath (by configuring the `paperless_path_prefix` variable) does not seem to be possible due to Paperless-ngx's technical limitations.

### Specify database

It is necessary to select database used by Paperless-ngx from MariaDB and Postgres.

To use Postgres, add the following configuration to your `vars.yml` file:

```yaml
paperless_database_type: postgres
```

Set `mariadb` to use MariaDB.

For other settings, check variables such as `paperless_database_*` on [`defaults/main.yml`](../defaults/main.yml).

### Configure a Redis database

It is necessary to set up a Redis database for the Paperless-ngx instance. Valkey can also be used instead.

To enable the Redis database for Paperless-ngx, add the following configuration to your `vars.yml` file:

```yaml
paperless_redis_hostname: YOUR_REDIS_SERVER_HOSTNAME_HERE
paperless_redis_port: 6379
```

Make sure to replace `YOUR_REDIS_SERVER_HOSTNAME_HERE` with your own value.

### Extending the configuration

There are some additional things you may wish to configure about the service.

Take a look at:

- [`defaults/main.yml`](../defaults/main.yml) for some variables that you can customize via your `vars.yml` file. You can override settings (even those that don't have dedicated playbook variables) using the `paperless_environment_variables_additional_variables` variable

## Installing

After configuring the playbook, run the installation command of your playbook as below:

```sh
ansible-playbook -i inventory/hosts setup.yml --tags=setup-all,start
```

If you use the MASH playbook, the shortcut commands with the [`just` program](https://github.com/mother-of-all-self-hosting/mash-playbook/blob/main/docs/just.md) are also available: `just install-all` or `just setup-all`

## Usage

After running the command for installation, Paperless-ngx becomes available at the specified hostname like `https://example.com`.

To get started, open the URL with a web browser, and register the account. **Note that the first registered user becomes an administrator automatically.**

## Troubleshooting

### Check the service's logs

You can find the logs in [systemd-journald](https://www.freedesktop.org/software/systemd/man/systemd-journald.service.html) by logging in to the server with SSH and running `journalctl -fu paperless` (or how you/your playbook named the service, e.g. `mash-paperless`).
