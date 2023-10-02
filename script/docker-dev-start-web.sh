#!/usr/bin/env bash
  set -xeuo pipefail
  ./script/wait-for-tcp.sh db 5432
  ./script/wait-for-tcp.sh redis 6379
  if [[ -f ./tmp/pids/server.pid ]]; then
    rm ./tmp/pids/server.pid
  fi
  
  npm rebuild esbuild && yarn
  
  bundle

  if ! [[ -f .db-created ]]; then
    bin/rails db:create
    bin/rails db:migrate
    bin/rails db:fixtures:load
  fi
    bin/rails db:reset
    touch .db-created

  if ! [[ -f .db-seeded ]]; then
    bin/rails db:seed
    touch .db-seeded
  fi
  foreman start -f Procfile.dev