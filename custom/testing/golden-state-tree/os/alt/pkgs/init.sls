{%- set alt_packages = [
    'curl',
    'tar',
    'git',
    'gcc',
    'gcc-c++',
    'make',
    'sudo',
    'sed',
    'which',
    'openssl',
    'procps',
    'python3',
    'python3-dev',
    'systemd',
    'xz',
] %}

{%- for pkg in alt_packages %}
alt-pkg-{{ pkg }}:
  cmd.run:
    - name: apt-get install -y {{ pkg }}
    - unless: rpm -q {{ pkg }}
{%- endfor %}

python3-pip:
  cmd.run:
    - name: apt-get install -y python3-module-pip
    - unless: rpm -q python3-module-pip
