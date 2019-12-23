#Reload systemd services
class forward::systemdreload {
  # Reload the system daemon
  exec { '/usr/bin/systemctl daemon-reload':
    refreshonly => true,
  }
}
