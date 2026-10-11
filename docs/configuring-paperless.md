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

This is an [Ansible](https://www.ansible.com/) role which installs [Paperless-ngx](https://paperless-ngx.com) to run as a [Docker](https://www.docker.com/) container wrapped in a systemd service.

Paperless-ngx is a community-supported open-source document management system that transforms your physical documents into a searchable online archive to organize them paperless.

See the project's [documentation](https://docs.paperless-ngx.com/) to learn what Paperless-ngx does and why it might be useful to you.

## Prerequisites

To run a Paperless-ngx instance it is necessary to prepare a database and [Redis](https://redis.io/) database for managing cache data. For a database you can use [MariaDB](https://mariadb.org/), [Postgres](https://www.postgresql.org/), or [SQLite](https://www.sqlite.org/). The SQLite database file will be automatically created by the service if it is enabled.

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

### Set administrator's account details

You also need to specify administrator's account details by adding the following configuration to your `vars.yml` file:

```yaml
paperless_environment_variables_paperless_admin_user: ADMIN_USER_USERNAME_HERE
paperless_environment_variables_paperless_admin_password: ADMIN_USER_PASSWORD_HERE
```

Generating a strong password (e.g. `pwgen -s 64 1`) is recommended for `paperless_environment_variables_paperless_admin_password`.

>[!NOTE]
> Subsequent changes to them will not affect the existing user.

### Configuring database

#### Specify database (optional)

You can specify a database used by Paperless-ngx. By default it is configured to use Postgres.

To use SQLite, add the following configuration to your `vars.yml` file:

```yaml
paperless_database_type: sqlite
```

Set `mariadb` to use MariaDB. The SQLite database is stored in the directory specified with `paperless_data_path`.

For other settings, check variables such as `paperless_database_*` on [`defaults/main.yml`](../defaults/main.yml).

#### Configuring connection to the database server (optional)

>[!NOTE]
> Connecting to MariaDB via a Unix socket is not supported on this role.

By default the role is configured to establish the connection to the database server via a Unix socket. You can mount the Unix socket by adding the following configuration to your `vars.yml` file:

```yaml
# Specify the path to the Postgres Unix socket path on the host (bind-mount source)
paperless_database_postgres_socket_path_host: ""
```

Setting it enables to connect to the database server via Unix socket mounted in the container.

If TCP connection is preferred, connection via the Unix socket can be disabled by adding the following configuration to your `vars.yml` file:

```yaml
# Disable the connection to the Postgres server via a Unix socket
paperless_database_postgres_socket_enabled: false
```

### Configure a Redis database

It is necessary to set up a Redis database for the Paperless-ngx instance. Valkey can also be used instead.

To enable the Redis database for Paperless-ngx, add the following configuration to your `vars.yml` file:

```yaml
paperless_redis_hostname: YOUR_REDIS_SERVER_HOSTNAME_HERE
paperless_redis_port: 6379
```

Make sure to replace `YOUR_REDIS_SERVER_HOSTNAME_HERE` with your own value.

### Enabling additional languages for OCR (optional)

If you're dealing with languages other than the ones for which [OCR support is installed by default (English, German, French, Italian, Spanish)](https://docs.paperless-ngx.com/configuration/#PAPERLESS_OCR_LANGUAGES), you may wish to adjust `paperless_ocr_languages_custom`. This variable takes a list of 3-letter language codes (as seen on [this page](https://tesseract-ocr.github.io/tessdoc/Data-Files-in-different-versions.html)).

Doing this will instruct the container image to install additional `tesseract-ocr-{LANGUAGE}` packages on startup.

Example:

```yml
# Add OCR support for Bulgarian and Japanese
paperless_ocr_languages_custom:
  - bul
  - jpn
```

### Configuring Apache Tika Server integration with Gotenberg (optional)

You can optionally have the instance connect to [Apache Tika Server](http://tika.apache.org/) for parsing and converting document files (such as ".doc", ".xlsx" and ".odt"). It is required for parsing emails (".eml") as well. Note that Apache Tika Server integration requires a [Gotenberg](https://gotenberg.dev/) instance.

To enable the integration, add the following configuration to your `vars.yml` file:

```yaml
paperless_environment_variables_paperless_tika_enabled: true

paperless_environment_variables_paperless_tika_endpoint: YOUR_TIKA_INSTANCE_ENDPOINT_HERE

paperless_environment_variables_paperless_tika_gotenberg_endpoint: YOUR_GOTENBERG_INSTANCE_ENDPOINT_HERE
```

Make sure to replace `YOUR_TIKA_INSTANCE_ENDPOINT_HERE` and `YOUR_GOTENBERG_INSTANCE_ENDPOINT_HERE` with your own values.

If you are looking for an Ansible role for Apache Tika Server and Gotenberg, you can check out [ansible-role-tika](https://radicle.network/nodes/iris.radicle.network/rad%3Azbk3MzAN6SX6d8pa9DT2kHDscyr6) and [ansible-role-gotenberg](https://github.com/mother-of-all-self-hosting/ansible-role-gotenberg) maintained by the [Mother-of-All-Self-Hosting (MASH)](https://github.com/mother-of-all-self-hosting) team.

>[!NOTE]
> The bundled Apache Tika Server and Gotenberg installations that this role used to provide have been removed.

### Configuring a mailer (optional)

You can configure a mailer to enable email functions such as email address verification, password recovery, etc.

To configure the SMTP mailer, add the following configuration to your `vars.yml` file as below (adapt to your needs):

```yaml
# Specify SMTP server hostname
paperless_environment_variables_paperless_email_host: ""

# Specify SMTP server port number
paperless_environment_variables_paperless_email_port: 587

# Specify SMTP server username
paperless_environment_variables_paperless_email_host_user: ""

# Specify SMTP server password
paperless_environment_variables_paperless_email_host_password: ""

# Specify the email address that emails will be sent from
paperless_environment_variables_paperless_email_from: ""

# Set to `true` to enable TLS encryption
paperless_environment_variables_paperless_email_use_tls: true

# Set to `true` to enable SSL encryption
paperless_environment_variables_paperless_email_use_ssl: false
```

>[!WARNING]
> Without setting an authentication method such as DKIM, SPF, and DMARC for your hostname, emails are most likely to be quarantined as spam at recipient's mail servers. The worst scenario is that your server's IP address or hostname will be included in the spam list such as the one managed by [Spamhaus](https://www.spamhaus.org/). If you have set up a mail server with the [MASH project's exim-relay Ansible role](https://github.com/mother-of-all-self-hosting/ansible-role-exim-relay), you can enable DKIM signing with it. Refer [its documentation](https://github.com/mother-of-all-self-hosting/ansible-role-exim-relay/blob/main/docs/configuring-exim-relay.md#enable-dkim-support-optional) for details.

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

Refer to the [official documentation](https://docs.paperless-ngx.com/) to learn how to use Paperless-ngx.

## Troubleshooting

### Check the service's logs

You can find the logs in [systemd-journald](https://www.freedesktop.org/software/systemd/man/systemd-journald.service.html) by logging in to the server with SSH and running `journalctl -fu paperless` (or how you/your playbook named the service, e.g. `mash-paperless`).
