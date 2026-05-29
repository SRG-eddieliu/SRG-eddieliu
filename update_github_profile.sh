#!/usr/bin/env bash
set -euo pipefail

owner="SRG-eddieliu"

require_auth() {
  gh auth status >/dev/null
}

repo_exists() {
  gh repo view "$1" >/dev/null 2>&1
}

pin_repo() {
  local repo="$1"
  local repo_id
  repo_id="$(gh api graphql \
    -f owner="$owner" \
    -f name="$repo" \
    -f query='
      query($owner: String!, $name: String!) {
        repository(owner: $owner, name: $name) { id }
      }' \
    --jq '.data.repository.id')"

  gh api graphql \
    -f repoId="$repo_id" \
    -f query='
      mutation($repoId: ID!) {
        pinRepository(input: { repositoryId: $repoId }) {
          repository { nameWithOwner }
        }
      }' >/dev/null
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

  pin_repo "quantlab_step0_intro"
  pin_repo "OptionPricer"
  pin_repo "rnn-volatility-lab"

  echo "GitHub profile README, repository metadata, and available pins updated."
}

main "$@"
