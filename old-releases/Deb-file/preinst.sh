#!/bin/bash
set -e

# Function to get the Ubuntu version codename
get_ubuntu_version() {
    VERSION_CODENAME=$(lsb_release -c | awk '{print $2}')
    echo $VERSION_CODENAME
}

# Check if the current OS version is supported
check_os_version() {
    VERSION=$(get_ubuntu_version)

    # Jazzy supports only Ubuntu 24.04 (Noble)
    if [[ "$VERSION" == "noble" ]]; then
        ROS_DISTRO="jazzy"
        echo "Supported OS: Ubuntu 24.04 (Noble). Proceeding with ROS 2 Jazzy setup."
    # Humble and Iron support only Ubuntu 22.04 (Jammy)
    elif [[ "$VERSION" == "jammy" ]]; then
        ROS_DISTRO="humble or iron"
        echo "Supported OS: Ubuntu 22.04 (Jammy). Proceeding with ROS 2 Humble or Iron setup."
    else
        echo "Unsupported OS version. This script supports only Ubuntu 22.04 (Jammy) or Ubuntu 24.04 (Noble)."
        exit 1
    fi
}

# Call the function to check the OS version
check_os_version

# Ensure system dependencies are met
echo "Ensuring system dependencies..."
apt-get update -y
apt-get install -y curl software-properties-common locales

# Set up locales
echo "Setting up locales..."
locale-gen en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# Add the ROS 2 repository depending on the version
echo "Adding ROS 2 repository..."
curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(get_ubuntu_version) main" > /etc/apt/sources.list.d/ros2.list

# Update package lists to include the new repository
echo "Updating package lists..."
apt-get update -y
