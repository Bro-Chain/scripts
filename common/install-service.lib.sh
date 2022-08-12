function runInstall {
  echo "What du you want to name your node? (Moniker)"
  read moniker

  echo "- Trying sudo, you may need to enter your password..."
  sudo echo "- Confirmed that sudo is working!"
  sudo apt update
  sudo apt install -y curl git jq lz4 build-essential
  sudo rm -rf /usr/local/go
  sudo curl -Ls https://go.dev/dl/go1.19.linux-amd64.tar.gz | tar -C /usr/local -xz
  tee -a $HOME/.profile >/dev/null <<EOF
export PATH=\$PATH:/usr/local/go/bin
EOF

  echo "- Downloading and compiling sei..."

  cd "$HOME"
  rm -rf ${gitDirectory}
  git clone ${gitRepo}
  cd ${gitDirectory}

  for version in "${versions[@]}"; do
    gitVersion=${version%%:*}
    chainVersion=${version##*:}

    # Compile version ${gitVersion}
    if [[ $chainVersion == "genesis" ]]; then
      versionDirectory="genesis"
    else
      versionDirectory=$(upgrades/${chainVersion})
    fi

    git checkout ${gitVersion}
    make build -B
    mkdir -p ${root}/cosmovisor/${versionDirectory}/bin
    mv build/${binary} ${root}/cosmovisor/${versionDirectory}/bin/
  done

  echo "- Download and install cosmovisor..."

  curl -Ls https://github.com/cosmos/cosmos-sdk/releases/download/cosmovisor%2Fv1.2.0/cosmovisor-v1.2.0-linux-amd64.tar.gz | tar xz
  chmod 755 cosmovisor
  sudo mv cosmovisor /usr/bin/cosmovisor

  echo "- Installing service..."

  sudo tee /etc/systemd/system/${binary}.service >/dev/null <<EOF
[Unit]
Description=${name} Node Service
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/bin/cosmovisor run start
Restart=on-failure
RestartSec=10
LimitNOFILE=8192
Environment="DAEMON_HOME=${root}"
Environment="DAEMON_NAME=${binary}"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF
  sudo systemctl daemon-reload
  sudo systemctl enable ${binary}

  echo "- Installing ${name} node..."

  MONIKER="${moniker}"
  cosmovisor init
  sudo ln -s ${root}/cosmovisor/current/bin/${binary} /usr/local/bin/${binary}
  ${binary} config chain-id ${chainId}
  ${binary} init $MONIKER --chain-id ${chainId}

  echo "- Configuring node..."

  curl -Ls ${genesisUrl} >${root}/config/genesis.json
  curl -Ls ${addrbookUrl} >${root}/config/addrbook.json
  tee ${root}/data/priv_validator_state.json >/dev/null <<EOF
{
  "height": "0",
  "round": 0,
  "step": 0
}
EOF
  sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0001${denom}\"/" ${root}/config/app.toml
  sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" ${root}/config/app.toml
  sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"5\"/" ${root}/config/app.toml
  sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"0\"/" ${root}/config/app.toml
  sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"1000\"/" ${root}/config/app.toml

  if [[ -n $peer && -n $rpc ]]; then
    echo "- Configuring state sync..."

    STATE_SYNC_RPC=${rpc}
    STATE_SYNC_PEER=${peer}
    LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
    SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
    SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

    sed -i.bak -e "s|^enable *=.*|enable = true|" ${root}/config/config.toml
    sed -i.bak -e "s|^rpc_servers *=.*|rpc_servers = \\"$STATE_SYNC_RPC,$STATE_SYNC_RPC\\"|" \\
    ${root}/config/config.toml
    sed -i.bak -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \\
    ${root}/config/config.toml
    sed -i.bak -e "s|^trust_hash *=.*|trust_hash = \\"$SYNC_BLOCK_HASH\\"|" \\
    ${root}/config/config.toml
    sed -i.bak -e "s|^persistent_peers *=.*|persistent_peers = \\"$STATE_SYNC_PEER\\"|" \\
    ${root}/config/config.toml
  fi

  sudo systemctl restart ${binary}
  sudo journalctl -u ${binary} -f --no-hostname -o cat
}
