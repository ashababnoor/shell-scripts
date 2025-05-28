#!/bin/sh

# Define Unicode code points for emojis
emoji_party_popper="\U0001F389"             # 🎉
emoji_confetti_ball="\U0001F38A"            # 🎊
emoji_sparkles="\U00002728"                 # ✨
emoji_page_with_curl="\U0001F4C3"           # 📃

# Define bold text and reset color and formatting
style_bold=$(echo -e '\033[1m')             # bold text
style_reset=$(echo -e '\033[0m')            # reset color and formatting

# Define 3-bit non-bold color codes
color_black=$(echo -e '\033[0;30m')         # Black
color_red=$(echo -e '\033[0;31m')           # Red
color_green=$(echo -e '\033[0;32m')         # Green
color_yellow=$(echo -e '\033[0;33m')        # Yellow
color_blue=$(echo -e '\033[0;34m')          # Blue
color_magenta=$(echo -e '\033[0;35m')       # Magenta
color_cyan=$(echo -e '\033[0;36m')          # Cyan
color_white=$(echo -e '\033[0;37m')         # White

# Define 3-bit background codes
color_black_bg=$(echo -e '\033[0;40m')      # Black Background
color_red_bg=$(echo -e '\033[0;41m')        # Red Background
color_green_bg=$(echo -e '\033[0;42m')      # Green Background
color_yellow_bg=$(echo -e '\033[0;43m')     # Yellow Background
color_blue_bg=$(echo -e '\033[0;44m')       # Blue Background
color_magenta_bg=$(echo -e '\033[0;45m')    # Magenta Background
color_cyan_bg=$(echo -e '\033[0;46m')       # Cyan Background
color_white_bg=$(echo -e '\033[0;47m')      # White Background

# Define 3-bit bold color color codes
color_black_bold=$(echo -e '\033[1;30m')    # Bold Black
color_red_bold=$(echo -e '\033[1;31m')      # Bold Red
color_green_bold=$(echo -e '\033[1;32m')    # Bold Green
color_yellow_bold=$(echo -e '\033[1;33m')   # Bold Yellow
color_blue_bold=$(echo -e '\033[1;34m')     # Bold Blue
color_magenta_bold=$(echo -e '\033[1;35m')  # Bold Magenta
color_cyan_bold=$(echo -e '\033[1;36m')     # Bold Cyan
color_white_bold=$(echo -e '\033[1;37m')    # Bold White

# Define 8-bit color non-bold codes
color_orage=$(echo -e '\033[38;5;214m')                 # Orange
color_dark_orange=$(echo -e '\033[38;5;208m')           # Dark Orange
color_orange_red=$(echo -e '\033[38;5;202m')            # Orange Red
color_light_sea_green=$(echo -e '\033[38;5;37m')        # Light Sea Green
color_dodger_blue=$(echo -e '\033[38;5;33m')            # Dodger Blue

# Define 8-bit color bold codes
color_orage_bold=$(echo -e '\033[1;38;5;214m')          # Bold Orange
color_dark_orange_bold=$(echo -e '\033[1;38;5;208m')    # Bold Dark Orange
color_orange_red_bold=$(echo -e '\033[1;38;5;202m')     # Bold Orange Red
color_light_sea_green_bold=$(echo -e '\033[1;38;5;37m') # Bold Light Sea Green
color_dodger_blue_bold=$(echo -e '\033[1;38;5;33m')     # Bold Dodger Blue

# Read more: 
#   1) https://en.wikipedia.org/wiki/ANSI_escape_code
#   2) https://www.ditig.com/256-colors-cheat-sheet 