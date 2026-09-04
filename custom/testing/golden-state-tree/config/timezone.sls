{%- if grains['os_family'] == 'Arch' %}
{#- Salt's timezone.system state falls back to the systemd/timedatectl
   provider for Arch (no dedicated file-based provider registered), which
   needs a live systemd bus - unavailable during a container image build.
   Set /etc/localtime directly instead, exactly what timedatectl would do. #}
set-time-zone:
  file.symlink:
    - name: /etc/localtime
    - target: /usr/share/zoneinfo/Etc/UTC
    - force: True
{%- else %}
set-time-zone:
  timezone.system:
    - name: Etc/UTC
    - utc: True
{%- endif %}
