#!/bin/bash

# Function to get the Ubuntu version codename
get_ubuntu_version() {
    # Get Ubuntu version codename
    VERSION_CODENAME=$(lsb_release -c | awk '{print $2}')
    echo $VERSION_CODENAME
}



# Add the ROS 2 repository depending on the version
if [[ "$ROS_DISTRO" == "jazzy" ]]; then
    # Adding ROS 2 Jazzy repository
    echo "Adding ROS 2 Jazzy repository..."
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
elif [[ "$ROS_DISTRO" == "humble or iron" ]]; then
    # Adding ROS 2 Humble/Iron repository
    echo "Adding ROS 2 Humble/Iron repository..."
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
fi

# Update the system after adding the ROS repository
echo "Updating package lists..."
sudo apt update

# Install the relevant ROS 2 packages
if [[ "$ROS_DISTRO" == "jazzy" ]]; then
    echo "Installing ROS 2 Jazzy packages..."
    sudo apt install ros-jazzy-desktop -y
elif [[ "$ROS_DISTRO" == "humble or iron" ]]; then
    echo "Installing ROS 2 Humble/Iron packages..."
    sudo apt install ros-humble-desktop -y
    # Alternatively, use `ros-iron-desktop` if you want Iron instead of Humble
fi

# Set up the ROS 2 environment
echo "Setting up ROS 2 environment..."
source /opt/ros/${ROS_DISTRO}/setup.bash

echo "ROS 2 installation complete! You can now try some examples."

