function printLogo {
  c0=$(printf '\033[0m')
  c1=$(printf '\033[38;5;165m')
  c2=$(printf '\033[38;5;55m')
  cat <<EOF
${c1}
  ▟█▙                                                     ▟█▙                         ▟█▙
  ███                                                     ███                         ▜█▛
  █▛▀                                                     █▛▀
  ▘▟████████▙   ███▄██████▙    ▟████████▙    ▟████████▙   ▘▟████████▙    ▟████████▙   ███  ███▄██████▙ 
  ███      ▀▀▀  ▀▀▀      ▀▀▀  ▀▀▀      ▀▀▀  ▀▀▀      ${c2}▀▀▀${c1}  ▀▀▀      ▀▀▀  ▀▀▀      ▀▀▀  ▀▀▀  ▀▀▀      ███
  ███     ██████████    ██████████    ██████████    ██████████    ██████████    ███████████████     ███
  ███      ▄▄▄  ▄▄▄      ${c2}▄▄▄${c1}  ▄▄▄      ▄▄▄  ▄▄▄      ${c2}▄▄▄${c1}  ▄▄▄      ▄▄▄  ▄▄▄      ▄▄▄  ▄▄▄  ▄▄▄      ███
   ▜████████▛   ███${c2}███████▛${c1}    ▜████████▛    ▜████████▛   ███${c2}██████${c1}███   ▜██████████  ███  ███${c2}██████${c1}███
${c0}
EOF
}
