<picture>
  <source media="(prefers-color-scheme: dark)" srcset=".github/mark-dark.svg">
  <img alt="Dojo logo" align="right" width="120" src=".github/mark-light.svg">
</picture>

<a href="https://twitter.com/dojostarknet">
<img src="https://img.shields.io/twitter/follow/dojostarknet?style=social"/>
</a>
<a href="https://github.com/dojoengine/dojo">
<img src="https://img.shields.io/github/stars/dojoengine/dojo?style=social"/>
</a>

[![discord](https://img.shields.io/badge/join-dojo-green?logo=discord&logoColor=white)](https://discord.gg/PwDa2mKhR4)
[![Telegram Chat][tg-badge]][tg-url]

[tg-badge]: https://img.shields.io/endpoint?color=neon&logo=telegram&label=chat&style=flat-square&url=https%3A%2F%2Ftg.sumanjay.workers.dev%2Fdojoengine
[tg-url]: https://t.me/dojoengine


# Dojo Starter: Official Guide

The official Dojo Starter guide, the quickest and most streamlined way to get your Dojo Autonomous World up and running. This guide will assist you with the initial setup, from cloning the repository to deploying your world.

The Dojo Starter contains the minimum required code to bootstrap your Dojo Autonomous World. This starter package is included in the `dojoup` binary. For more detailed instructions, please refer to the official Dojo Book [here](https://book.dojoengine.org/getting-started/installation.html).

## Prerequisites

- Rust - install [here](https://www.rust-lang.org/tools/install)
- Cairo language server - install [here](https://book.dojoengine.org/development/setup.html#3-setup-cairo-vscode-extension)

## Step-by-Step Guide

Follow the steps below to setup and run your first Autonomous World.

### Step 1: Clone the Repository

Start by cloning the repository to your local machine. Open your terminal and type the following command:

```bash
git clone https://github.com/dojoengine/dojo-starter.git
```

This command will create a local copy of the Dojo Starter repository.

### Step 2: Install `dojoup`

The next step is to install `dojoup`. This cli tool is a critical component when building with dojo. It manages dependencies and helps in building your project. Run the following command in your terminal:

```bash
curl -L https://install.dojoengine.org | bash
```

The command downloads the `dojoup` installation script and executes it.

### Step 3: Build the Example World

With `dojoup` installed, you can now build your example world using the following command:

```bash
sozo build .
```

This command compiles your project and prepares it for execution.

### Step 4: Start Katana RPC

[Katana RPC](https://book.dojoengine.org/framework/katana/overview.html) is the communication layer for your Dojo World. It allows different components of your world to communicate with each other. To start Katana RPC, use the following command:

```bash
katana
```

### Step 5: Migrate (Deploy) the World

Finally, deploy your world using the `sozo migrate` command. This command, deploys your world to Katana!

```bash
sozo migrate
```

Congratulations! You've successfully setup and deployed your first Dojo Autonomous World.


### Next steps:

Make sure to read the [Offical Dojo Book](https://book.dojoengine.org/index.html) for detailed instructions including theory and best practices.

---

## Contribution

Your contributions are always welcome and appreciated. Following are the things you can do to contribute to this project:

1. **Report a Bug**
    - If you think you have encountered a bug, and we should know about it, feel free to report it [here](https://github.com/dojoengine/dojo-starter/issues) and we will take care of it.

2. **Request a Feature**
    - You can also request for a feature [here](https://github.com/dojoengine/dojo-starter/issues), and if it's viable, it will be picked for development.

3. **Create a Pull Request**
    - It can't get better then this, your pull request will be appreciated by the community.

For any other questions, feel free to reach out to us [here](https://dojoengine.org/contact).

Happy coding!