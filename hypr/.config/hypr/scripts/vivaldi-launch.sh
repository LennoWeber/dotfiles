#!/usr/bin/env sh
# Vivaldi: weniger unnötige System-Dialoge beim Start.
# Hinweis: Bekannter Bug (Forum VB-97469), wenn „Beim Start: Homepage“ und
# Homepage = Startseite → Portal-Dialog „xdg-open“. Dafür gibt es
# policies/managed/restore-session.json (RestoreOnStartup = letzte Sitzung).

exec /usr/bin/vivaldi \
  --no-default-browser-check \
  "$@"
