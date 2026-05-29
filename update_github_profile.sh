#!/usr/bin/env bash
set -euo pipefail

owner="SRG-eddieliu"

require_auth() {
  gh auth status >/dev/null
}

repo_exists() {
  gh repo view "$1" >/dev/null 2>&1
}

main() {
  require_auth

  if ! repo_exists "$owner/$owner"; then
    gh repo create "$owner/$owner" --public --source . --remote origin --push
  else
    git remote remove origin 2>/dev/null || true
    git remote add origin "https://github.com/$owner/$owner.git"
    git push -u origin main
  fi

  gh repo edit "$owner/OptionPricer" \
    --description "C++20 derivatives pricing engine covering Black-Scholes, lattice methods, Monte Carlo, LSMC, and path-dependent options." \
    --add-topic cpp \
    --add-topic quant-finance \
    --add-topic options-pricing \
    --add-topic monte-carlo \
    --add-topic derivatives

  gh repo edit "$owner/quantlab_step0_intro" \
    --description "In-progress AI-assisted systematic alpha research platform for factors, signals, portfolio construction, backtesting, and research automation." \
    --add-topic systematic-investing \
    --add-topic quant-research \
    --add-topic portfolio-construction \
    --add-topic financial-ml \
    --add-topic agentic-ai

  gh repo edit "$owner/rnn-volatility-lab" \
    --description "In-progress volatility forecasting research lab." \
    --add-topic volatility-forecasting \
    --add-topic financial-machine-learning \
    --add-topic time-series

  gh api graphql \
    -f login="$owner" \
    -f query='
      query($login: String!) {
        user(login: $login) {
          pinnedItems(first: 6, types: REPOSITORY) {
            nodes { ... on Repository { nameWithOwner } }
          }
        }
      }' \
    --jq '.data.user.pinnedItems.nodes[].nameWithOwner'

  echo "GitHub profile README and repository metadata updated."
  echo "Note: GitHub does not expose a supported public API for changing profile repository pins. Adjust pins in the GitHub profile UI if needed."
}

main "$@"
