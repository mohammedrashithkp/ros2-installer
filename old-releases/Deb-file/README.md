# ROS 2 Installer

This repository contains a custom installer package for setting up ROS 2 (Jazzy/Humble/Iron) on supported Ubuntu systems. The installer simplifies the installation of ROS 2 packages from the official repositories maintained by Open Robotics.

## Features

- Installs ROS 2 (Jazzy, Humble, or Iron) on Ubuntu 22.04 (Jammy) or 24.04 (Noble).
- Configures a ROS 2 workspace and sets up `colcon` for building packages.
- Adds the workspace setup to the `.bashrc` for easy sourcing.

## Prerequisites

- Ubuntu 22.04 (Jammy) : ROS2 Iron or Ros2 Humble 
- Ubuntu 24.04 (Noble) : ROS2 Jazzy
- A system with `curl`, `git`, and basic build tools installed.

## How to Use

1. **Clone the repository**:
   ```bash
   git clone https://github.com/mohammedrashithkp/ros2-installer.git &&  cd ros2-installer/Deb-file  ```

2. **Install Dependencies**:Run the pre-installation script to install the dependencies using: 
   ```bash
   sudo chmod +x preinst.sh &&
   ./preinst.sh ```

3. **Install the package**: After building, you can install the .deb package using:
    ```bash
    sudo dpkg -i ros2-installer.deb
    ```

## GitHub Actions

This repository includes a GitHub Actions workflow to automatically build and publish the `.deb` package on each push to the `main` branch.

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

