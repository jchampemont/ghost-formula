{% from 'ghost/map.jinja' import ghost, os_code_name with context %}

wget -qO- https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -:
  cmd.run:
    - unless: "apt-key list | grep gpg@nodesource.com"

deb https://deb.nodesource.com/node_6.x {{ os_code_name }} main:
  pkgrepo.managed:
    - humanname: node
    - dist: {{ os_code_name }}
    - file: /etc/apt/sources.list.d/nodesource.list
    - refresh_db: true

nodejs:
  pkg.installed

ghost-cli:
  npm.installed

{{ ghost.path }}:
  file.directory:
    - user: {{ ghost.install_user }}
    - group: {{ ghost.install_user }}
    - dir_mode: 755

{% if ghost.db == 'mysql' %}
ghost install --no-stack --no-prompt --no-setup-nginx --url {{ ghost.url }} --port {{ ghost.port }} --db {{ ghost.db }}  --dbhost {{ ghost.mysql.host }} --dbuser {{ ghost.mysql.user }} --dbpass {{ ghost.mysql.pass }}  --dbname {{ ghost.mysql.database }}:
{%- else -%}
ghost install --no-stack --no-prompt --no-setup-nginx  --url {{ ghost.url }} --port {{ ghost.port }} --db {{ ghost.db }}  --dbpath {{ ghost.sqlite }}:
{% endif -%}
  cmd.run:
    - cwd: {{ ghost.path }}
    - runas: {{ ghost.install_user }}
    - creates: {{ ghost.path }}/config.production.json

{% for theme in ghost.themes %}
{{ theme.git_repository }}:
  git.latest:
    - target: {{ ghost.path }}/content/themes/{{ theme.name }}
    - user: {{ ghost.install_user }}
{% endfor %}