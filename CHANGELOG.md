<!--
SPDX-FileCopyrightText: 2024 Julian-Samuel Gebühr

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Changelog

## 23.08.2026

- The bundled Apache Tika Server and Gotenberg installations were removed in favor of external instances (such as ones installed by the MASH project's tika and gotenberg roles). If you were using them, install the external services and point `paperless_tika_endpoint` and `paperless_tika_gotenberg_endpoint` at them. Leftover `*-tika`/`*-gotenberg` systemd services from the bundled installations are cleaned up automatically.

## 19.05.2024

- Added support for Gotenberg and Tika
  configure it by setting `paperless_tika_enabled` and `paperless_gotenberg_enabled` to `true`
