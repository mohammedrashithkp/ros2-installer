#!/bin/bash

set -e

# Enable colors
RED='\e[31m'
GREEN='\e[32m'
BLUE='\e[34m'
YELLOW='\e[33m'
CYAN='\e[36m'
BOLD='\e[1m'
RESET='\e[0m'

# Function to display styled output like 'nala'
display_in_container() {
    local title=$1
    shift
    local command="$@"

    echo -e "${CYAN}${BOLD}============================${RESET}"
    echo -e "${BLUE}${BOLD}$title${RESET}"
    echo -e "${CYAN}${BOLD}============================${RESET}"

    $command 2>&1 | while read -r line; do
        echo -e "${YELLOW}▶ ${RESET}$line"
    done

    echo -e "${CYAN}${BOLD}============================${RESET}\n"
}

# Function to get the Ubuntu version codename

get_ubuntu_version() {
    VERSION_CODENAME=$(cat /etc/os-release | grep UBUNTU_CODENAME | cut -d= -f2)
    echo $VERSION_CODENAME
}


# Check if the current OS version is supported
check_os_version() {
    VERSION=$(get_ubuntu_version)

    if [[ "$VERSION" == "noble" ]]; then
        ROS_DISTRO="jazzy"
        echo "Supported OS: Ubuntu 24.04 (Noble). Proceeding with ROS 2 Jazzy setup."
    elif [[ "$VERSION" == "jammy" ]]; then
        read -p "Enter ROS2 Distro to be installed (humble/iron): " ROS_DISTRO
        echo "Supported OS: Ubuntu 22.04 (Jammy). Proceeding with ROS 2 $ROS_DISTRO setup."
    else
	read -p  "Unsupported OS version. This script supports only Ubuntu 22.04 (Jammy) or Ubuntu 24.04 (Noble).Do you still wish to install anyway(y/n): " override
        if [[ "$override" == "y" ]];then
		read -p "Which version do you wish to install (jazzy/humble/iron): " ROS_DISTRO
	else
		exit 1
	fi
    fi
}

# Call the function to check the OS version
check_os_version

# Ensure system dependencies are met
display_in_container "Updating System" sudo apt-get -q=2 update -y
display_in_container "Installing Dependencies" sudo apt-get -q=2 install -y curl software-properties-common locales 

# Set up locales
echo "Setting up locales..."
sudo locale-gen en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# Add the ROS 2 repository
display_in_container "Adding ROS 2 Repository" curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Update package lists
display_in_container "Updating Package Lists After Adding Repository" apt update

# Install the relevant ROS 2 packages
display_in_container "Installing ROS 2 Packages" sudo apt-get -q=2 install ros-${ROS_DISTRO}-desktop -y

# Set up the ROS 2 environment
echo "Setting up ROS 2 environment..."
sudo chmod +x /opt/ros/${ROS_DISTRO}/setup.bash
source /opt/ros/${ROS_DISTRO}/setup.bash

echo "ROS 2 installation complete!"

# Function to install colcon
install_colcon() {
    display_in_container "Installing colcon and Dependencies" sudo apt-get -q=2 update && sudo apt-get -q=2 install -y python3-colcon-common-extensions 
}

# Check if colcon is installed
if ! command -v colcon &> /dev/null; then
    echo "colcon is not installed. Proceeding with installation."
    install_colcon
else
    echo "colcon is already installed. Skipping installation."
fi

# Define default workspace and source folder names
workspace_name="ros2_ws"
src_folder="src"

# Allow customization of the workspace path
read -p "Enter the workspace name (default: $workspace_name): " custom_workspace_name
workspace_name="${custom_workspace_name:-$workspace_name}"

# Get the Desktop Directory
desktop_dir="/home/${SUDO_USER}/Desktop"
read -p "Enter the workspace path (default: $desktop_dir): " custom_workspace_dir
current_dir="${custom_workspace_dir:-$desktop_dir}"

# Full path to the workspace
workspace_path="$current_dir/$workspace_name"

# Check if the workspace already exists
if [ -d "$workspace_path" ]; then
    echo "Workspace $workspace_name already exists at $workspace_path. Skipping creation."
else
    # Create the workspace and the src folder
    echo "Creating workspace $workspace_name at $workspace_path."
    mkdir -p "$workspace_path/$src_folder"
    if [ $? -eq 0 ]; then
        echo "Workspace and src folder created successfully."
    else
        echo "Failed to create the workspace. Please check your permissions."
        exit 1
    fi
fi

# Navigate to the workspace
cd "$workspace_path" || exit

# Initialize the workspace
display_in_container "Initializing ROS 2 Workspace" colcon build --packages-select none &> colcon_build.log  

# Optionally add workspace setup to .bashrc
read -p "Do you want to add the workspace setup to your ~/.bashrc? [y/N]: " add_to_bashrc
if [[ "$add_to_bashrc" =~ ^[Yy]$ ]]; then
    echo "source $workspace_path/install/setup.bash" >> ~/.bashrc
    echo "Workspace setup added to ~/.bashrc. Please run 'source ~/.bashrc' or restart your shell."
fi

# Final message
echo "ROS 2 workspace setup completed. Workspace path: $workspace_path"
