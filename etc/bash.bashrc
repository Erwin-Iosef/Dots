#
# /etc/bash.bashrc
#
#export  QT_QPA_PLATFORMTHEME=qt6ct
alias startw=startplasma-wayland
alias logoff='sudo pkill -u $USER'
alias yay=paru
alias neofetch=fastfetch
EDITOR=vim

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Prevent doublesourcing
if [[ -z "${BASHRCSOURCED}" ]] ; then
  BASHRCSOURCED="Y"
  # the check is bash's default value
  [[ "$PS1" = '\s-\v\$ ' ]] && PS1='[\u@\h \W]\$ '
  case ${TERM} in
    Eterm*|alacritty*|aterm*|foot*|gnome*|konsole*|kterm*|putty*|rxvt*|tmux*|xterm*)
      PROMPT_COMMAND+=('printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"')
      ;;
    screen*)
      PROMPT_COMMAND+=('printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"')
      ;;
  esac
fi

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
fi

command_not_found_handle() {
  local pkg=$(pacman -Fq "$1")

  if [[ -z "$pkg" ]]; then
          printf "bash: command not found: %s\n" "$1"
  else
          printf  "\"%s\" may be found in the following package(s):\n\t%s\n" "$1" "$pkg"
  fi

  return 127
}

function pacmanlistoptdeps(){
  LC_ALL=C.UTF-8 pacman -Qei | sed '/^[^NO ]/d;/None$/d' | awk 'BEGIN{RS=ORS="\n\n";FS=OFS="\n\\S"} /Optional Deps/ {print $1"\nO"$2}' | sed 's/^Optional Deps   ://;/\[installed\]$/d;s/\s\+/ /'
}
