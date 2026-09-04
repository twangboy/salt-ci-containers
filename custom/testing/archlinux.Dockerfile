FROM archlinux/archlinux:latest

COPY golden-pillar-tree golden-pillar-tree
COPY golden-state-tree golden-state-tree

RUN <<EOF
  set -e

  if [ $(uname -m) = "x86_64" ]; then
    export ARCH=x86_64
  else
    export ARCH=arm64
  fi
  export SALT_VERSION=3007.13

  # Arch's container image ships a mostly-empty pacman DB and no guaranteed
  # populated keyring - refresh + populate before installing anything, or
  # package installs fail intermittently on a fresh container.
  pacman -Sy --noconfirm archlinux-keyring
  pacman -Su --noconfirm --needed curl wget tar xz gcc openssl systemd

  wget https://packages.broadcom.com/artifactory/saltproject-generic/onedir/$SALT_VERSION/salt-$SALT_VERSION-onedir-linux-$ARCH.tar.xz
  tar xf salt-$SALT_VERSION-onedir-linux-$ARCH.tar.xz

  ./salt/salt-call --local --pillar-root=/golden-pillar-tree --file-root=/golden-state-tree state.apply provision

  rm -rf salt
  rm -rf salt-$SALT_VERSION-onedir-linux-$ARCH.tar.xz
  rm -rf golden-pillar-tree
  rm -rf golden-state-tree

  rm -rf /var/log/salt
  rm -rf /var/cache/salt
  rm -rf /etc/salt
  rm -rf /tmp/*

  # salt-bootstrap CI starts test containers with /usr/lib/systemd/systemd
  # as the entrypoint - verify Arch's systemd package actually put it there
  # rather than assuming, same precaution as altlinux-10/11.Dockerfile.
  mkdir -p /usr/lib/systemd
  SYSTEMD_BIN=$(find /usr/lib/systemd /lib/systemd /bin /usr/bin -maxdepth 1 -name systemd -type f 2>/dev/null | head -n1)
  [ -n "$SYSTEMD_BIN" ] && [ ! -e /usr/lib/systemd/systemd ] && ln -sf "$SYSTEMD_BIN" /usr/lib/systemd/systemd

  pacman -Scc --noconfirm
EOF

CMD ["/bin/bash"]
