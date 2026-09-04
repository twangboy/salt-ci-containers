include:
  - pkgs.cron
  - pkgs.curl
  - pkgs.dmidecode
  {%- if grains['osrelease'] == '13' and  grains['osarch'] != 'arm64' %}
  - pkgs.dnsutils
  {%- elif grains['osrelease'] != '13' %}
  - pkgs.dnsutils
  {%- endif %}
  - pkgs.docker
  - pkgs.file
  - pkgs.gcc
  - pkgs.gpg
  - pkgs.git
  - pkgs.iproute2
  - pkgs.ipset
  - pkgs.libcurl
  - pkgs.libffi
  - pkgs.libgit2
  - pkgs.libsodium
  - pkgs.libxml
  - pkgs.libxslt
  - pkgs.make
  - pkgs.man
  - pkgs.nginx
  - pkgs.openldap
  - pkgs.openssl
  - pkgs.openssl-dev
  - pkgs.patch
  - pkgs.ping
  - pkgs.python3
  - pkgs.python3-pip
  - pkgs.rng-tools
  - pkgs.rsync
  - pkgs.sed
  - pkgs.ssh
  - pkgs.sudo
  - pkgs.swig
  - pkgs.tar
  - pkgs.zlib
  {#- HashiCorp no longer publishes a Release file for trixie (13) #}
  {%- if grains['osrelease'] != '13' and grains['osarch'] != 'arm64' %}
  - pkgs.vault
  {%- endif %}
  - pkgs.jq
  - pkgs.xz
  - pkgs.tree
  - pkgs.cargo {#-
  - pkgs.awscli
  - pkgs.amazon-cloudwatch-agent #}
  - pkgs.samba

  {#- OS Specific packages install #}
  - .apt-utils
  - .libdpkg-perl
  - .timesync
