{%- if grains['os_family'] in ('RedHat', 'Suse')  %}
  {%- set client_pkg = "openssh-clients" -%}
  {%- set server_pkg = "openssh-server" -%}
{%- elif grains['os_family'] == 'Arch' %}
  {#- Arch ships a single 'openssh' package providing both client and server #}
  {%- set client_pkg = "openssh" -%}
  {%- set server_pkg = "openssh" -%}
{%- else %}
  {%- set client_pkg = "openssh-client" -%}
  {%- set server_pkg = "openssh-server" -%}
{%- endif %}

ssh-client:
  pkg.installed:
    - name: {{ client_pkg }}

ssh-server:
  pkg.installed:
    - name: {{ server_pkg }}
