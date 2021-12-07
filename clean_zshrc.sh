#!/bin/bash

PATTERN="# ================ ANY TEXT AFTER THIS IS ADDED BY AUTO-GENERATED TOOLS ================"

get_content(){
    sed -ne "/${PATTERN}/,$ p" $HOME/.zshrc | tail -n +3
    # grep -Pzo "${PATTERN}(.*\n)*" $HOME/.zshrc | tail -n +3
}

get_content >> $HOME/.zshenv
num_lines=$(get_content | wc -l)
cat $HOME/.zshrc | head -n "-$num_lines" > $HOME/.zshrc.tmp  # I think due to piping can't directly write to .zshrc
cat $HOME/.zshrc.tmp > $HOME/.zshrc
rm $HOME/.zshrc.tmp
