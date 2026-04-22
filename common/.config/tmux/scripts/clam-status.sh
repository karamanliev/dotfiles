#!/usr/bin/env sh

if [ "$(clamctl status 2>/dev/null)" = "on" ]; then
  printf '#[default] #[fg=#{fg_color}]On  '
fi
