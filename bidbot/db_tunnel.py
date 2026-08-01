"""
Opens an SSH tunnel to the shared cloud database (mirrors the
'Standard TCP/IP over SSH' connection method used in MySQL Workbench).
Both app.py and build_index.py import get_tunnel() from here instead
of connecting to MySQL directly.
"""

import os
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