set -l fzf_theme_opts "\
--color=bg+:#f2efdb
--color=bg:#fffbef
--color=spinner:#5c6a72
--color=hl:#f85552
--color=fg:#5c6a72
--color=header:#f85552
--color=info:#8da101
--color=pointer:#5c6a72
--color=marker:#5c6a72
--color=fg+:#5c6a72
--color=prompt:#8da101
--color=hl+:#f85552
--color=selected-bg:#475258
--color=border:#e8e5cf
--color=label:#5c6a72"

if set -q FZF_DEFAULT_OPTS[1]; and test -n "$FZF_DEFAULT_OPTS"
    set -Ux FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS
$fzf_theme_opts"
else
    set -Ux FZF_DEFAULT_OPTS "$fzf_theme_opts"
end
