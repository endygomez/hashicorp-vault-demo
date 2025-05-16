# Introduction to HashiCorp Vault

This guide provides a step-by-step introduction to using HashiCorp Vault for secure secret storage and management. Follow the instructions below to set up and interact with Vault.

## Prerequisites

- Docker
- Docker Compose

## Setup

1.  **Start the Vault container:**

    Use Docker Compose to start the Vault container in detached mode:

    ```bash
    docker compose up -d
    ```

2.  **Access the Vault container:**

    To access the Vault container's shell, use the following command:

    ```bash
    docker exec -it vault-dev sh
    ```

## Authentication

### Login with Token

To log in with a token, use the following command:

```bash
vault auth login [token]
```
- Token is automatically generated in ./vault-data/keys.txt

### Validate Authentication Methods

To list all enabled authentication methods, use:

```bash
vault auth list
```

## Policy Configuration

- Policy configuration is defined in `./config/config-policy.hcl` with the name "my-policy".
- For detailed information about policies, refer to the official documentation: [Vault Policies](https://developer.hashicorp.com/vault/docs/concepts/policies)

## Usage

### Testing Login

To test the userpass authentication method, use the following command:

```bash
vault login -method=userpass username=testuser password=changeme
```

After successful login, you can interact with Vault. For example, to store a key-value pair:

```bash
vault kv put secret/myapp/config foo=bar
```

To retrieve the stored value:

```bash
vault kv get secret/myapp/config
```

## Data Persistence

Vault data is persisted in the `./vault-data/` folder. This ensures that your data is retained even if the container is restarted.