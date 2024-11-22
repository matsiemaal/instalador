#!/bin/bash

get_mysql_root_password() {
  
  print_banner
  printf "${WHITE} 💻 Voer een wachtwoord in voor de gebruiker Deploy en de database (geen speciale tekens gebruiken):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " mysql_root_password
}

get_link_git() {
  
  print_banner
  printf "${WHITE} 💻 Voer de GitHub-link in van de Whaticket die u wilt installeren:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " link_git
}

get_instancia_add() {
  
  print_banner
  printf "${WHITE} 💻 Geef een naam op voor de instantie/het bedrijf dat wordt geïnstalleerd (gebruik geen spaties of speciale tekens, gebruik kleine letters):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " instancia_add
}

get_max_whats() {
  
  print_banner
  printf "${WHITE} 💻 Geef het aantal WhatsApp-verbindingen op dat ${instancia_add} kan registreren:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " max_whats
}

get_max_user() {
  
  print_banner
  printf "${WHITE} 💻 Geef het aantal gebruikers/medewerkers op dat ${instancia_add} kan registreren:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " max_user
}

get_frontend_url() {
  
  print_banner
  printf "${WHITE} 💻 Voer het domein van de FRONTEND/PANEEL in voor ${instancia_add}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " frontend_url
}

get_backend_url() {
  
  print_banner
  printf "${WHITE} 💻 Voer het domein van de BACKEND/API in voor ${instancia_add}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " backend_url
}

get_frontend_port() {
  
  print_banner
  printf "${WHITE} 💻 Voer de poort in voor de FRONTEND van ${instancia_add}; Bijvoorbeeld: 3000 tot 3999 ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " frontend_port
}

get_backend_port() {
  
  print_banner
  printf "${WHITE} 💻 Voer de poort in voor de BACKEND van deze instantie; Bijvoorbeeld: 4000 tot 4999 ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " backend_port
}

get_redis_port() {
  
  print_banner
  printf "${WHITE} 💻 Voer de poort in voor REDIS/BERICHTPLANNING van ${instancia_add}; Bijvoorbeeld: 5000 tot 5999 ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " redis_port
}

get_empresa_delete() {
  
  print_banner
  printf "${WHITE} 💻 Voer de naam in van de instantie/het bedrijf dat u wilt verwijderen (gebruik dezelfde naam als bij de installatie):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_delete
}

get_empresa_atualizar() {
  
  print_banner
  printf "${WHITE} 💻 Voer de naam in van de instantie/het bedrijf dat u wilt bijwerken (gebruik dezelfde naam als bij de installatie):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_atualizar
}

get_empresa_bloquear() {
  
  print_banner
  printf "${WHITE} 💻 Voer de naam in van de instantie/het bedrijf dat u wilt blokkeren (gebruik dezelfde naam als bij de installatie):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_bloquear
}

get_empresa_desbloquear() {
  
  print_banner
  printf "${WHITE} 💻 Voer de naam in van de instantie/het bedrijf dat u wilt deblokkeren (gebruik dezelfde naam als bij de installatie):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_desbloquear
}

get_empresa_dominio() {
  
  print_banner
  printf "${WHITE} 💻 Voer de naam in van de instantie/het bedrijf waarvoor u de domeinen wilt wijzigen (let op: voer beide domeinen in, ook als u er maar één wijzigt):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_dominio
}

get_alter_frontend_url() {
  
  print_banner
  printf "${WHITE} 💻 Voer het NIEUWE domein van de FRONTEND/PANEEL in voor ${empresa_dominio}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_frontend_url
}

get_alter_backend_url() {
  
  print_banner
  printf "${WHITE} 💻 Voer het NIEUWE domein van de BACKEND/API in voor ${empresa_dominio}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_backend_url
}

get_alter_frontend_port() {
  
  print_banner
  printf "${WHITE} 💻 Voer de poort in voor de FRONTEND van de instantie/het bedrijf ${empresa_dominio}; De poort moet hetzelfde zijn als opgegeven tijdens de installatie ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_frontend_port
}

get_alter_backend_port() {
  
  print_banner
  printf "${WHITE} 💻 Voer de poort in voor de BACKEND van de instantie/het bedrijf ${empresa_dominio}; De poort moet hetzelfde zijn als opgegeven tijdens de installatie ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_backend_port
}

get_urls() {
  get_mysql_root_password
  get_link_git
  get_instancia_add
  get_max_whats
  get_max_user
  get_frontend_url
  get_backend_url
  get_frontend_port
  get_backend_port
  get_redis_port
}

software_update() {
  get_empresa_atualizar
  frontend_update
  backend_update
}

software_delete() {
  get_empresa_delete
  deletar_tudo
}

software_bloquear() {
  get_empresa_bloquear
  configurar_bloqueio
}

software_desbloquear() {
  get_empresa_desbloquear
  configurar_desbloqueio
}

software_dominio() {
  get_empresa_dominio
  get_alter_frontend_url
  get_alter_backend_url
  get_alter_frontend_port
  get_alter_backend_port
  configurar_dominio
}

inquiry_options() {
  
  print_banner
  printf "${WHITE} 💻 Welkom bij de Whaticket SaaS Manager. Selecteer de volgende actie:${GRAY_LIGHT}"
  printf "\n\n"
  printf "   [0] Whaticket installeren\n"
  printf "   [1] Whaticket bijwerken\n"
  printf "   [2] Whaticket verwijderen\n"
  printf "   [3] Whaticket blokkeren\n"
  printf "   [4] Whaticket deblokkeren\n"
  printf "   [5] Domeinen van Whaticket wijzigen\n"
  printf "\n"
  read -p "> " option

  case "${option}" in
    0) get_urls ;;

    1) 
      software_update 
      exit
      ;;

    2) 
      software_delete 
      exit
      ;;
    3) 
      software_bloquear 
      exit
      ;;
    4) 
      software_desbloquear 
      exit
      ;;
    5) 
      software_dominio 
      exit
      ;;        

    *) exit ;;
  esac
}
