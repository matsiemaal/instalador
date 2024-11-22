#!/bin/bash
# 
# Systeembeheer

#######################################
# Maakt een gebruiker aan
# Argumenten:
#   Geen
#######################################
system_create_user() {
  print_banner
  printf "${WHITE} 💻 Nu gaan we een gebruiker maken voor de instantie...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  useradd -m -p $(openssl passwd -crypt ${mysql_root_password}) -s /bin/bash -G sudo deploy
  usermod -aG sudo deploy
EOF

  sleep 2
}

#######################################
# Clone repositories met Git
# Argumenten:
#   Geen
#######################################
system_git_clone() {
  print_banner
  printf "${WHITE} 💻 Downloaden van de Whaticket-code...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
  git clone ${link_git} /home/deploy/${instancia_add}/
EOF

  sleep 2
}

#######################################
# Update systeem
# Argumenten:
#   Geen
#######################################
system_update() {
  print_banner
  printf "${WHITE} 💻 Systeem bijwerken voor Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt -y update
  sudo apt-get install -y libxshmfence-dev libgbm-dev wget unzip fontconfig locales gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils
EOF

  sleep 2
}

#######################################
# Verwijder systeem
# Argumenten:
#   Geen
#######################################
deletar_tudo() {
  print_banner
  printf "${WHITE} 💻 Verwijderen van Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  docker container rm redis-${empresa_delete} --force
  cd && rm -rf /etc/nginx/sites-enabled/${empresa_delete}-frontend
  cd && rm -rf /etc/nginx/sites-enabled/${empresa_delete}-backend  
  cd && rm -rf /etc/nginx/sites-available/${empresa_delete}-frontend
  cd && rm -rf /etc/nginx/sites-available/${empresa_delete}-backend
  
  sleep 2

  sudo su - postgres
  dropuser ${empresa_delete}
  dropdb ${empresa_delete}
  exit
EOF

sleep 2

sudo su - deploy <<EOF
 rm -rf /home/deploy/${empresa_delete}
 pm2 delete ${empresa_delete}-frontend ${empresa_delete}-backend
 pm2 save
EOF

  sleep 2

  print_banner
  printf "${WHITE} 💻 Verwijderen van instantie/bedrijf ${empresa_delete} is succesvol uitgevoerd...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
}

#######################################
# Blokkeer systeem
# Argumenten:
#   Geen
#######################################
configurar_bloqueio() {
  print_banner
  printf "${WHITE} 💻 Blokkeren van Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

sudo su - deploy <<EOF
 pm2 stop ${empresa_bloquear}-backend
 pm2 save
EOF

  sleep 2

  print_banner
  printf "${WHITE} 💻 Blokkeren van instantie/bedrijf ${empresa_bloquear} is succesvol uitgevoerd...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
}

#######################################
# Deblokkeer systeem
# Argumenten:
#   Geen
#######################################
configurar_desbloqueio() {
  print_banner
  printf "${WHITE} 💻 Deblokkeren van Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

sudo su - deploy <<EOF
 pm2 start ${empresa_bloquear}-backend
 pm2 save
EOF

  sleep 2

  print_banner
  printf "${WHITE} 💻 Deblokkeren van instantie/bedrijf ${empresa_desbloquear} is succesvol uitgevoerd...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
}

#######################################
# Wijzig domein systeem
# Argumenten:
#   Geen
#######################################
configurar_dominio() {
  print_banner
  printf "${WHITE} 💻 Wijzig domeinen van Whaticket...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  cd && rm -rf /etc/nginx/sites-enabled/${empresa_dominio}-frontend
  cd && rm -rf /etc/nginx/sites-enabled/${empresa_dominio}-backend  
  cd && rm -rf /etc/nginx/sites-available/${empresa_dominio}-frontend
  cd && rm -rf /etc/nginx/sites-available/${empresa_dominio}-backend
EOF

sleep 2

  sudo su - deploy <<EOF
  cd && cd /home/deploy/${empresa_dominio}/frontend
  sed -i "1c\REACT_APP_BACKEND_URL=https://${alter_backend_url}" .env
  cd && cd /home/deploy/${empresa_dominio}/backend
  sed -i "2c\BACKEND_URL=https://${alter_backend_url}" .env
  sed -i "3c\FRONTEND_URL=https://${alter_frontend_url}" .env 
EOF

sleep 2
   
   backend_hostname=$(echo "${alter_backend_url/https:\/\/}")

 sudo su - root <<EOF
  cat > /etc/nginx/sites-available/${empresa_dominio}-backend << 'END'
server {
  server_name $backend_hostname;
  location / {
    proxy_pass http://127.0.0.1:${alter_backend_port};
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;
  }
}
END
ln -s /etc/nginx/sites-available/${empresa_dominio}-backend /etc/nginx/sites-enabled
EOF

sleep 2

frontend_hostname=$(echo "${alter_frontend_url/https:\/\/}")

sudo su - root << EOF
cat > /etc/nginx/sites-available/${empresa_dominio}-frontend << 'END'
server {
  server_name $frontend_hostname;
  location / {
    proxy_pass http://127.0.0.1:${alter_frontend_port};
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;
  }
}
END
ln -s /etc/nginx/sites-available/${empresa_dominio}-frontend /etc/nginx/sites-enabled
EOF

 sleep 2

 sudo su - root <<EOF
  service nginx restart
EOF

  sleep 2

  backend_domain=$(echo "${backend_url/https:\/\/}")
  frontend_domain=$(echo "${frontend_url/https:\/\/}")

  sudo su - root <<EOF
  certbot -m $deploy_email \
          --nginx \
          --agree-tos \
          --non-interactive \
          --domains $backend_domain,$frontend_domain
EOF

  sleep 2

  print_banner
  printf "${WHITE} 💻 Wijziging van domeinen voor instantie/bedrijf ${empresa_dominio} is succesvol uitgevoerd...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2
}

#######################################
# Installeer Node.js
# Argumenten:
#   Geen
#######################################
system_node_install() {
  print_banner
  printf "${WHITE} 💻 Node.js installeren...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  apt-get install -y nodejs
  sleep 2
  npm install -g npm@latest
  sleep 2
  sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  sudo apt-get update -y && sudo apt-get -y install postgresql
  sleep 2
  sudo timedatectl set-timezone Europe/Amsterdam
EOF

  sleep 2
}

#######################################
# Installeer Docker
# Argumenten:
#   Geen
#######################################
system_docker_install() {
  print_banner
  printf "${WHITE} 💻 Docker installeren...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt install -y apt-transport-https \
                 ca-certificates curl \
                 software-properties-common

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

  apt install -y docker-ce
EOF

  sleep 2
}

#######################################
# Installeer Puppeteer-afhankelijkheden
# Argumenten:
#   Geen
#######################################
system_puppeteer_dependencies() {
  print_banner
  printf "${WHITE} 💻 Puppeteer-afhankelijkheden installeren...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt-get install -y libxshmfence-dev \
                      libgbm-dev \
                      wget \
                      unzip \
                      fontconfig \
                      locales \
                      gconf-service \
                      libasound2 \
                      libatk1.0-0 \
                      libc6 \
                      libcairo2 \
                      libcups2 \
                      libdbus-1-3 \
                      libexpat1 \
                      libfontconfig1 \
                      libgcc1 \
                      libgconf-2-4 \
                      libgdk-pixbuf2.0-0 \
                      libglib2.0-0 \
                      libgtk-3-0 \
                      libnspr4 \
                      libpango-1.0-0 \
                      libpangocairo-1.0-0 \
                      libstdc++6 \
                      libx11-6 \
                      libx11-xcb1 \
                      libxcb1 \
                      libxcomposite1 \
                      libxcursor1 \
                      libxdamage1 \
                      libxext6 \
                      libxfixes3 \
                      libxi6 \
                      libxrandr2 \
                      libxrender1 \
                      libxss1 \
                      libxtst6 \
                      ca-certificates \
                      fonts-liberation \
                      libappindicator1 \
                      libnss3 \
                      lsb-release \
                      xdg-utils
EOF

  sleep 2
}

#######################################
# Installeer PM2
# Argumenten:
#   Geen
#######################################
system_pm2_install() {
  print_banner
  printf "${WHITE} 💻 PM2 installeren...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  npm install -g pm2
EOF

  sleep 2
}

#######################################
# Installeer Snapd
# Argumenten:
#   Geen
#######################################
system_snapd_install() {
  print_banner
  printf "${WHITE} 💻 Snapd installeren...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt install -y snapd
  snap install core
  snap refresh core
EOF

  sleep 2
}

#######################################
# Installeer Certbot
# Argumenten:
#   Geen
#######################################
system_certbot_install() {
  print_banner
  printf "${WHITE} 💻 Certbot installeren...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt-get remove certbot
  snap install --classic certbot
  ln -s /snap/bin/certbot /usr/bin/certbot
EOF

  sleep 2
}

#######################################
# Installeer Nginx
# Argumenten:
#   Geen
#######################################
system_nginx_install() {
  print_banner
  printf "${WHITE} 💻 Nginx installeren...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  apt install -y nginx
  rm /etc/nginx/sites-enabled/default
EOF

  sleep 2
}

#######################################
# Herstart Nginx
# Argumenten:
#   Geen
#######################################
system_nginx_restart() {
  print_banner
  printf "${WHITE} 💻 Nginx herstarten...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  service nginx restart
EOF

  sleep 2
}

#######################################
# Configuratie voor Nginx.conf
# Argumenten:
#   Geen
#######################################
system_nginx_conf() {
  print_banner
  printf "${WHITE} 💻 Nginx configureren...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

sudo su - root << EOF

cat > /etc/nginx/conf.d/deploy.conf << 'END'
client_max_body_size 100M;
END

EOF

  sleep 2
}

#######################################
# Configuratie Certbot
# Argumenten:
#   Geen
#######################################
system_certbot_setup() {
  print_banner
  printf "${WHITE} 💻 Certbot configureren...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  backend_domain=$(echo "${backend_url/https:\/\/}")
  frontend_domain=$(echo "${frontend_url/https:\/\/}")

  sudo su - root <<EOF
  certbot -m $deploy_email \
          --nginx \
          --agree-tos \
          --non-interactive \
          --domains $backend_domain,$frontend_domain

EOF

  sleep 2
}
