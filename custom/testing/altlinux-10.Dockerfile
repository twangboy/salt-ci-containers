FROM alt:p10

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

  apt-get install -y curl wget tar xz patchelf gcc openssl

  LIBCRYPTO_PATH=$(find /usr/lib64 /lib64 /usr/lib /lib -maxdepth 1 -name 'libcrypto.so*' 2>/dev/null | sort -V | tail -n1)
  [ -n "$LIBCRYPTO_PATH" ] && [ ! -e "$(dirname "$LIBCRYPTO_PATH")/libcrypto.so" ] && \
    ln -sf "$LIBCRYPTO_PATH" "$(dirname "$LIBCRYPTO_PATH")/libcrypto.so"

  wget https://packages.broadcom.com/artifactory/saltproject-generic/onedir/3007.6/salt-3007.6-onedir-linux-$ARCH.tar.xz
  tar xf salt-3007.6-onedir-linux-$ARCH.tar.xz

  ./salt/salt-call --local --pillar-root=/golden-pillar-tree --file-root=/golden-state-tree state.apply provision

  rm -rf salt
  rm -rf salt-3007.6-onedir-linux-$ARCH.tar.xz
  rm -rf golden-pillar-tree
  rm -rf golden-state-tree

  rm -rf /var/log/salt
  rm -rf /var/cache/salt
  rm -rf /etc/salt
  rm -rf /tmp/*
  apt-get clean
  rm -rf /var/cache/apt
EOF

CMD ["/bin/bash"]
