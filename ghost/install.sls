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

dbus:
  pkg.installed

npm install -g ghost-cli:
  cmd.run:
    - creates: /usr/bin/ghost

{{ ghost.path }}:
  file.directory:
    - user: {{ ghost.install_user }}
    - group: {{ ghost.install_user }}
    - dir_mode: 777

{% if ghost.db == 'mysql' %}
"ghost install --no-stack --no-prompt --no-setup-nginx --url {{ ghost.url }} --port {{ ghost.port }} --db {{ ghost.db }}  --dbhost {{ ghost.mysql.host }} --dbuser {{ ghost.mysql.user }} --dbpass {{ ghost.mysql.pass }}  --dbname {{ ghost.mysql.database }}":
  cmd.run:
    - cwd: {{ ghost.path }}
    - runas: {{ ghost.install_user }}
    - creates: {{ ghost.path }}/config.production.json
{% else %}
"ghost install --no-stack --no-prompt --no-setup-nginx  --url {{ ghost.url }} --port {{ ghost.port }} --db {{ ghost.db }}  --dbpath {{ ghost.sqlite }}":
  cmd.run:
    - cwd: {{ ghost.path }}
    - runas: {{ ghost.install_user }}
    - creates: {{ ghost.path }}/config.production.json
    - shell: /bin/bash
{% endif %}

{% for theme in ghost.themes %}
{{ theme.git_repository }}:
  git.latest:
    - target: {{ ghost.path }}/content/themes/{{ theme.name }}
    - user: ghost
{% endfor %}

{{ ghost.path }}/config.production.json:
  file.replace:
    - pattern: '"host": "127.0.0.1"'
    - repl: '"host": "{{ ghost.listen_addr }}"'
    - count: 1

{{ ghost.path }}_fix_permissions:
  file.directory:
    - name: {{ ghost.path }}
    - user: ghost
    - group: ghost
    - mode: 755
    - recurse:
      - user
      - group

ghost restart:
  cmd.run:
    - cwd: {{ ghost.path }}
    - runas: {{ ghost.install_user }}
    - watch:
      - file: {{ ghost.path }}/config.production.json