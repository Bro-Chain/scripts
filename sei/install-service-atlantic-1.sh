#!/usr/bin/env bash
name=Sei
binary=seid
root=$HOME/.sei
gitDirectory=sei-chain
gitRepo=https://github.com/sei-protocol/sei-chain.git
chainId=atlantic-1
versions=(
  "genesis:1.0.6beta-val-count-fix"
  "1.0.7beta:1.0.7beta-postfix"
  "1.0.8beta:1.0.8beta-hotfix"
  "1.1.0beta:1.1.0beta"
  "1.2.0beta:1.2.0beta"
)
rpc=https://sei-testnet-state-sync.brocha.in:443
peer=0a792165c1f9ff9cea8ce9676dbe389e0a555e45@sei-testnet-state-sync.p2p.brocha.in:30533
genesisUrl=https://raw.githubusercontent.com/sei-protocol/testnet/main/sei-incentivized-testnet/genesis.json
addrbookUrl=https://raw.githubusercontent.com/sei-protocol/testnet/main/sei-incentivized-testnet/addrbook.json

source <(curl -Ls https://raw.githubusercontent.com/bro-chain/scripts/main/common/install-service.lib.sh)

runInstall