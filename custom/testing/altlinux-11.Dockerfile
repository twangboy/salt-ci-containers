FROM alt:p11

COPY golden-pillar-tree golden-pillar-tree
COPY golden-state-tree golden-state-tree

RUN <<EOF
  set -e

  if [ $(uname -m) = "x86_64" ]; then
    export ARCH=x86_64
  else
    export ARCH=arm64
  fi

  apt-get update
  chmod -x /usr/lib/rpm/0ldconfig.filetrigger

  # apt-get install can intermittently fail with a spurious RPM
  # "erase skipped" / package-erase conflict under QEMU arm64
  # emulation. Retry a few times before giving up; unlike the
  # ldconfig retry precedent in ubuntu-22.04.Dockerfile, this install
  # is load-bearing for every later step in this file, so exhausting
  # the retries is fatal.
  for i in 1 2 3 4 5; do
    apt-get install -y curl wget tar xz patchelf gcc openssl && break
    echo "apt-get install attempt $i failed, retrying..."
    [ "$i" -eq 5 ] && exit 1
    sleep 1
  done

  LIBCRYPTO_PATH=$(find /usr/lib64 /lib64 /usr/lib /lib -maxdepth 1 -name 'libcrypto.so*' 2>/dev/null | sort -V | tail -n1)
  [ -n "$LIBCRYPTO_PATH" ] && [ ! -e "$(dirname "$LIBCRYPTO_PATH")/libcrypto.so" ] && \
    ln -sf "$LIBCRYPTO_PATH" "$(dirname "$LIBCRYPTO_PATH")/libcrypto.so"

  wget https://packages.broadcom.com/artifactory/saltproject-generic/onedir/3007.6/salt-3007.6-onedir-linux-$ARCH.tar.xz
  tar xf salt-3007.6-onedir-linux-$ARCH.tar.xz

  LIBC_PATH=$(find /usr/lib64 /lib64 /usr/lib /lib -maxdepth 1 -name 'libc.so.6' 2>/dev/null | head -n1)
  [ -n "$LIBC_PATH" ] && [ ! -e "$(dirname "$LIBC_PATH")/libpthread.so.0" ] && \
    ln -sf "$LIBC_PATH" "$(dirname "$LIBC_PATH")/libpthread.so.0"

  ./salt/salt-call --local --pillar-root=/golden-pillar-tree --file-root=/golden-state-tree state.apply provision

  rm -rf salt
  rm -rf salt-3007.6-onedir-linux-$ARCH.tar.xz
  rm -rf golden-pillar-tree
  rm -rf golden-state-tree

  rm -rf /var/log/salt
  rm -rf /var/cache/salt
  rm -rf /etc/salt
  rm -rf /tmp/*

  # salt-bootstrap CI starts test containers with /usr/lib/systemd/systemd
  # as the entrypoint. ALT's systemd package doesn't install the binary
  # there, so locate it and symlink it into place.
  mkdir -p /usr/lib/systemd
  SYSTEMD_BIN=$(find /usr/lib/systemd /lib/systemd /bin /usr/bin -maxdepth 1 -name systemd -type f 2>/dev/null | head -n1)
  [ -n "$SYSTEMD_BIN" ] && [ ! -e /usr/lib/systemd/systemd ] && ln -sf "$SYSTEMD_BIN" /usr/lib/systemd/systemd

  # ALT's apt-get (apt-rpm) keeps its package lists under /var/cache/apt
  # itself, unlike Debian's apt which keeps them in /var/lib/apt/lists.
  # Wiping the whole tree leaves apt-get update unable to run in
  # containers started from this image, so only clear the archive cache.
  apt-get clean
  rm -rf /var/cache/apt/archives/*
EOF

CMD ["/bin/bash"]
