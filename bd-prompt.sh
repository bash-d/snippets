# bd-prompt.sh: bd dependent colorized 'smart(er)' prompt

# MIT License
# ===========
#
# Copyright (C) 2018-2024 Joseph Tingiris <joseph.tingiris@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

_bd_prompt_ansi() {
    if type bd_ansi &> /dev/null; then 
        bd_ansi ${@}
    else
        if type bd-ansi &> /dev/null; then 
            bd-ansi ${@}
        else
            return
        fi
    fi
}

_bd_prompt() {
    local bd_prompt_color_term=0

    # set window title
    case "${TERM}" in
        alacritty*|ansi*|*color|screen*|*tmux*|*xterm*)
            # enable ansi sequences PS1
            bd_prompt_color_term=1

            local bd_prompt_window_title=''
            bd_prompt_window_title+="${USER}@"
            bd_prompt_window_title+="${HOSTNAME}"
            bd_prompt_window_title+=":${PWD}"

            echo -ne "\e]0;${bd_prompt_window_title}\a" # e = 033 (ESC), a = 007 (BEL)
            ;;
        *)
            echo "TERM=${TERM}"
            echo
            ;;
    esac

    # this space reserved for before prompt ...

    # construct dynamic PS1
    local bd_prompt_ps1=''

    if [ ${bd_prompt_color_term} -eq 1 ]; then
        bd_prompt_ps1+="\[$(_bd_prompt_ansi reset)\]"
        bd_prompt_ps1+="\[$(_bd_prompt_ansi bold)\]"
        bd_prompt_ps1+="\[$(_bd_prompt_color 2)\]"
    fi

    bd_prompt_ps1+='['

    if [ ${bd_prompt_color_term} -eq 1 ]; then
        bd_prompt_ps1+="\[$(_bd_prompt_color 3)\]"
    fi

    bd_prompt_ps1+="\u"

    if [ ${bd_prompt_color_term} -eq 1 ]; then
        bd_prompt_ps1+="\[$(_bd_prompt_color 2)\]"
    fi

    bd_prompt_ps1+='@'

    if [ ${bd_prompt_color_term} -eq 1 ]; then
        bd_prompt_ps1+="\[$(_bd_prompt_color 3)\]"
    fi

    bd_prompt_ps1+="\H"

    if [ ${bd_prompt_color_term} -eq 1 ]; then
        bd_prompt_ps1+="\[$(_bd_prompt_color 1)\]"
    fi

    bd_prompt_ps1+=" \w"

    if [ ${bd_prompt_color_term} -eq 1 ]; then
        bd_prompt_ps1+="\[$(_bd_prompt_color 2)\]"
    fi

    bd_prompt_ps1+=']'

    local bd_prompt_glyphs=''

    if [ ${bd_prompt_color_term} -eq 1 ]; then
        bd_prompt_ps1+="\[$(_bd_prompt_ansi reset)\]"
    fi

    # glyph: git is detected; do what?
    if [ -d .git ]; then
        #bd_prompt_glyphs+='♬ '
        bd_prompt_glyphs+='♪'
    fi

    # glyph: etc/bash.d is detected; add a symbol
    if [ -d etc/bash.d ]; then
        if type bd &> /dev/null; then
            bd_prompt_glyphs+='♭'
        fi
    fi

    [ ${#bd_prompt_glyphs} -gt 0 ] && bd_prompt_ps1+="${bd_prompt_glyphs}"

    # append colored/utf-8 symbols for # and $
    if [ ${bd_prompt_color_term} -eq 1 ]; then
        bd_prompt_ps1+="\[$(_bd_prompt_color 1)\]"
    fi

    [ "${USER}" == 'root' ] && bd_prompt_ps1+='♯' || bd_prompt_ps1+='$'

    # single symbols that are multibyte tend to have some additional visible space & an extra space is subjective
    bd_prompt_ps1+=' '

    [ ${bd_prompt_color_term} -eq 1 ] && bd_prompt_ps1+="\[$(_bd_prompt_ansi reset)\]"

    # set the promp
    PS1="${bd_prompt_ps1}"

    # reset cursor hack
    echo -ne '\x1b[ q'

    unset -v bd_prompt_color_term bd_prompt_window_title bd_prompt_ps1
}

_bd_prompt_color() {
    local bd_prompt_color_name

    # allow setting via ~/.bash-prompt_color
    [ -r ~/.bd_prompt_color ] &&  bd_prompt_color_name="$(grep -E -m 1 -e '^black$|^red$|^green$|^yellow$|^blue$|^magenta$|^cyan$|^white$|^gray$|^grey$' ~/.bd_prompt_color)"

    # allow alternate setting with a global
    [ -z "${bd_prompt_color_name}" ] && bd_prompt_color_name="${BD_PROMPT_COLOR}" # must match a valid color, exactly, or it will be white

    if [ "${USER}" == "${PROMPT_LOGNAME}" ] && [ "${USER}" != 'root' ]; then
        [ -z "${bd_prompt_color_name}" ] && bd_prompt_color_name="green"
        _bd_prompt_ansi fg_${bd_prompt_color_name}${1}
    else
        if [ "${USER}" == 'root' ]; then
            bd_prompt_color_name="yellow" # root is always yellow
            _bd_prompt_ansi fg_${bd_prompt_color_name}${1}
        else
            [ -z "${bd_prompt_color_name}" ] && bd_prompt_color_name="gray"
            _bd_prompt_ansi fg_${bd_prompt_color_name}${1}
        fi
    fi
}

[ ${#PROMPT_LOGNAME} -eq 0 ] && PROMPT_LOGNAME=$(logname 2> /dev/null)
[ ${#PROMPT_LOGNAME} -eq 0 ] && PROMPT_LOGNAME="${USER}"

PROMPT_COMMAND='_bd_prompt'
