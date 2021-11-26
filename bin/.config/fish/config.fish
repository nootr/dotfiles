# Enable vim mode using "jj" as an escape.
if status is-interactive
  function my_vi_bindings
    fish_vi_key_bindings
    bind -M insert -m default jj backward-char force-repaint
  end
  set -g fish_key_bindings my_vi_bindings
end
