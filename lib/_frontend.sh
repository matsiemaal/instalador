#!/bin/bash
# 
# Functies voor het instellen van de app frontend

#######################################
# Installeert Node-pakketten
# Argumenten:
#   Geen
#######################################
frontend_node_dependencies() {
  print_banner
  printf "${WHITE} 💻 Frontend-afhankelijkheden installeren...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
  cd /home/deploy/${instancia_add}/frontend
  npm install
EOF

  sleep 2
}

#######################################
# Compileert frontend-code
# Argumenten:
#   Geen
#######################################
frontend_node_build() {
  print_banner
  printf "${WHITE} 💻 Frontend-code compileren...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
  cd /home/deploy/${instancia_add}/frontend
  npm run build
EOF

  sleep 2
}

#######################################
# Werkt frontend-code bij
# Argumenten:
#   Geen
#######################################
frontend_update() {
  print_banner
  printf "${WHITE} 💻 Frontend bijwerken...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
  cd /home/deploy/${empresa_atualizar}
  pm2 stop ${empresa_atualizar}-frontend
  git pull
  cd /home/deploy/${empresa_atualizar}/frontend
  npm install
  rm -rf build
  npm run build
  pm2 start ${empresa_atualizar}-frontend
  pm2 save
EOF

  sleep 2
}

#######################################
# Stelt omgevingsvariabelen in voor de frontend
# Argumenten:
#   Geen
#######################################
frontend_set_env() {
  print_banner
  printf "${WHITE} 💻 Omgevingsvariabelen instellen (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Zorg voor idempotentie
  backend_url=$(echo "${backend_url/https:\/\/}")
  backend_url=${backend_url%%/*}
  backend_url=https://$backend_url

sudo su - deploy << EOF
  cat <<[-]EOF > /home/deploy/${instancia_add}/frontend/.env
REACT_APP_BACKEND_URL=${backend_url}
REACT_APP_HOURS_CLOSE_TICKETS_AUTO=24
[-]EOF
EOF

  sleep 2

sudo su - deploy << EOF
  cat <<[-]EOF > /home/deploy/${instancia_add}/frontend/server.js
// Eenvoudige express-server om frontend productiebouw uit te voeren
const express = require("express");
const path = require("path");
const app = express();
app.use(express.static(path.join(__dirname, "build")));
app.get("/*", function (req, res) {
	res.sendFile(path.join(__dirname, "build", "index.html"));
});
app.listen(${frontend_port});

[-]EOF
EOF

  sleep 2
}

#######################################
# Start pm2 voor frontend
# Argumenten:
#   Geen
#######################################
frontend_start_pm2() {
  print_banner
  printf "${WHITE} 💻 pm2 starten (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - deploy <<EOF
  cd /home/deploy/${instancia_add}/frontend
  pm2 start server.js --name ${instancia_add}-frontend
  pm2 save
EOF

  sleep 2
  
  sudo su - root <<EOF
   pm2 startup
  sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u deploy --hp /home/deploy
EOF
  sleep 2
}

#######################################
# Stelt nginx in voor frontend
# Argumenten:
#   Geen
#######################################
frontend_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 nginx instellen (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  frontend_hostname=$(echo "${frontend_url/https:\/\/}")

sudo su - root << EOF

cat > /etc/nginx/sites-available/${instancia_add}-frontend << 'END'
server {
  server_name $frontend_hostname;

  location / {
    proxy_pass http://127.0.0.1:${frontend_port};
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

ln -s /etc/nginx/sites-available/${instancia_add}-frontend /etc/nginx/sites-enabled
EOF

  sleep 2
}
