"""
Opens an SSH tunnel to the shared cloud database (mirrors the
'Standard TCP/IP over SSH' connection method used in MySQL Workbench).
Both app.py and build_index.py import get_tunnel() from here instead
of connecting to MySQL directly.
"""

import os

# sshtunnel (last released 2021) unconditionally references paramiko.DSSKey
# when it loads, but recent paramiko versions removed DSA key support
# entirely (DSA is deprecated/insecure). We're not authenticating with a
# DSA key anyway, so a harmless stand-in satisfies the lookup without
# needing to downgrade paramiko.
import paramiko
if not hasattr(paramiko, "DSSKey"):
    paramiko.DSSKey = paramiko.RSAKey

from sshtunnel import SSHTunnelForwarder

_tunnel = None


def get_tunnel():
    global _tunnel
    if _tunnel is None:
        _tunnel = SSHTunnelForwarder(
            (os.environ["SSH_HOST"], int(os.environ.get("SSH_PORT", 22))),
            ssh_username=os.environ["SSH_USER"],
            ssh_password=os.environ["SSH_PASSWORD"],
            remote_bind_address=(
                os.environ.get("DB_HOST", "127.0.0.1"),
                int(os.environ.get("DB_PORT", 3306)),
            ),
        )
        _tunnel.start()
    return _tunnel


def get_db_port() -> int:
    """
    Returns the local port app.py/build_index.py should connect MySQL to.

    - USE_SSH_TUNNEL=true  (default, for laptops off-campus): opens an SSH
      tunnel to the DB server and returns the tunnel's local bound port.
    - USE_SSH_TUNNEL=false (for running directly ON the DB server, e.g. a
      deployed instance on ccscloud itself): skips the tunnel entirely and
      returns DB_PORT as-is, since MySQL is already local from there.
    """
    if os.environ.get("USE_SSH_TUNNEL", "true").lower() == "false":
        return int(os.environ.get("DB_PORT", 3306))
    return get_tunnel().local_bind_port