# ros2-installer


A CLI tool to install ROS 2 distributions easily from the official repositories.

## Disclaimer

This tool installs ROS 2 from the official repositories but is **not an official ROS release**. Use at your own risk.

> The owner of this project, platform, or service shall not be held liable for any loss, damage, or corruption of data, whether caused by system failures, user errors, or any other unforeseen circumstances. By using this service, you acknowledge and agree that you are solely responsible for backing up and protecting your data.

---

## Features

- Interactive ROS 2 distro selection (e.g., humble, iron)
- Automatic locale setup
- Workspace creation
- Optionally appends sourcing commands to `.bashrc`
- Headless mode (non-interactive) with all options specified via CLI arguments
- Works on Ubuntu 22.04+

---

## Installation

```bash
pip install ros2-installer
```

---

## Usage

### Interactive Mode

Just run:

```bash
ros2-installer
```

You will be prompted step by step to:

- Choose the ROS 2 distro (humble or iron)
- Confirm installation
- Specify workspace name and location
- Choose whether to auto-source in `.bashrc`

---

### Headless Mode

If you want to run everything non-interactively (e.g., in CI pipelines or Docker), you can pass all required arguments:

```bash
ros2-installer \
  --distro humble \
  --workspace ~/ros2_ws \
  --yes \
  --auto-source
```

**Arguments:**

| Argument            | Description                                                  |
|---------------------|--------------------------------------------------------------|
| `--distro`          | ROS 2 distro to install (`humble`, `iron`)                   |
| `--workspace`       | Path to create the workspace                                 |
| `--yes`             | Automatically confirm all prompts                            |
| `--auto-source`     | Automatically append sourcing commands to `.bashrc`          |

Example:

```bash
ros2-installer --distro humble --workspace ~/ros2_ws --yes --auto-source
```

---
## Bug-Report
- Raise an issue in the [github repository](https://github.com/mohammedrashithkp/ros2-installer)
## License

[MIT](./LICENSE)

