#!/bin/sh

export VAULT_ADDR=http://127.0.0.1:8200

echo "⏳ Waiting for Vault to be available..."
until curl -s $VAULT_ADDR/v1/sys/health > /dev/null; do
  sleep 1
done

# Check if Vault is already initialized
IS_INITIALIZED=$(curl -s $VAULT_ADDR/v1/sys/init | jq -r .initialized)

if [ "$IS_INITIALIZED" = "false" ]; then
  echo "📦 Vault is not yet initialized. Initializing..."

  vault operator init -key-shares=1 -key-threshold=1 > /vault/file/keys.txt
  vault operator unseal "$(grep 'Unseal Key 1:' /vault/file/keys.txt | awk '{print $NF}')"
  export VAULT_TOKEN=$(grep 'Initial Root Token:' /vault/file/keys.txt | awk '{print $NF}')

  echo "🔐 Authentication and policies..."

  # Enable userpass if it is not enabled
  if ! vault auth list | grep -q "userpass/"; then
    vault auth enable userpass
  fi

  # Enable KV if it is not enabled
  if ! vault secrets list | grep -q "^secret/"; then
    vault secrets enable -path=secret -version=2 kv
  else
    echo "🔁 KV was already enabled."
  fi

  # Create policy if it does not exist
  if ! vault policy list | grep -q "^my-policy$"; then
    vault policy write my-policy /vault/config/config-policy.hcl
  fi

  # Create user if it does not exist
  if ! vault read -field=policies auth/userpass/users/testuser > /dev/null 2>&1; then
    vault write auth/userpass/users/testuser \
      password=changeme \
      policies=default,my-policy
    echo "✅ User testuser created."
  else
    echo "👤 User testuser already exists."
  fi

  echo "🎉 Vault initialized and ready."

else
  echo "✅ Vault was already initialized. Skipping setup."
  vault operator unseal "$(grep 'Unseal Key 1:' /vault/file/keys.txt | awk '{print $NF}')"
  export VAULT_TOKEN=$(grep 'Initial Root Token:' /vault/file/keys.txt | awk '{print $NF}')
fi