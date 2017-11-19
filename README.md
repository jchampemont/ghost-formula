# ghost-formula
Formula for the Ghost blog platform (https://ghost.org/).

See the full [Salt Formulas installation and usage instructions](http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html).

## Available states
### `ghost.install`
Installs the ghost blog platform.

Example pillar:

```
ghost:
  install_user: deploy
  path: /apps/ghost
  url: https://blog.example.com
  port: 2368
  listen_addr: 0.0.0.0
  db: mysql # or sqlite3
  mysql:
    host: localhost
    user: ghost
    pass: password
    database: ghost
  sqlite: /apps/ghost.db
  themes:
    - name: myblog
      git_repository: https://github.com/jchampemont/myblog-ghost-theme.git
```

Ths install user must have sudo permissions without password.