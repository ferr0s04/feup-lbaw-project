# PixelMarket

## Group Members
  
Filipe Esteves (up202206515@up.pt)  
Gonçalo Ferros (up202207592@up.pt)  
Pedro Oliveira (up202206257@up.pt)  
Rodrigo de Sousa (up202207292@up.pt)

## Login Credentials
### 2.1. Administration Credentials

> Administration URL: http://lbaw2496.lbaw.fe.up.pt/admin-console

| Username | Password |
|----------|----------|
| bob@example.com | bobpass |

### 2.2. User Credentials

| Type | Username | Password |
|------|----------|----------|
| Buyer | alice@example.com | alicepass |
| Seller | johndoe@example.com | password123 |

## Installing the software dependencies

To prepare your computer for development, you need to install:

* [PHP](https://www.php.net/) version 8.3 or higher
* [Composer](https://getcomposer.org/) version 2.2 or higher

We recommend using an **Ubuntu** distribution (24.04 or newer) that ships with these versions.

Install the required software with:

```bash
sudo apt update
sudo apt install git composer php8.3 php8.3-mbstring php8.3-xml php8.3-pgsql php8.3-curl
```

On macOS, install using [Homebrew](https://brew.sh/):

```bash
brew install php@8.3 composer
```

If you use [Windows WSL](https://learn.microsoft.com/en-us/windows/wsl/install), ensure you are using Ubuntu 24.04 inside WSL. Previous versions do not provide the required packages. After setting up WSL, follow the Ubuntu instructions above.

## Installing local PHP dependencies

After setting up your repository, install all local dependencies required for development:

```bash
composer update
```

If the installation fails:

1. Check your Composer version (should be 2 or above): `composer --version`
2. If you see errors about missing PHP extensions, ensure they are enabled in your [php.ini file](https://www.php.net/manual/en/configuration.file.php) file


## Working with PostgreSQL

The _Docker Compose_ file provided sets up **PostgreSQL** and **pgAdmin4** as local Docker containers.

Start the containers from your project root:

```bash
docker compose up -d
```

Stop the containers when needed:

```bash
docker compose down
```

Open your browser and navigate to `http://localhost:4321` to access pgAdmin4.

Depending on your installation setup, you might need to use the IP address from the virtual machine providing docker instead of `localhost`.

On first use, add a local database connection with these settings:

```
hostname: postgres
username: postgres
password: pg!password
```

Use `postgres` as hostname (not `localhost`) because _Docker Compose_ creates an internal DNS entry for container communication.

---
-- LBAW, 2024
