
# Set version and architecture
VERSION = 1.0.0
ARCH = amd64
PKG_NAME = ros2-installer
DEB_DIR = debian
DEB_FILE = $(PKG_NAME)_$(VERSION)_$(ARCH).deb

# Specify the root directory for the package
ROOT_DIR = $(shell pwd)/Deb-file

# Prepare the package structure
DEB_STRUCTURE = $(ROOT_DIR)/$(DEB_DIR)

# Target to build the .deb package
build:
    @echo "Building the .deb package for ROS 2 Installer..."
    mkdir -p $(DEB_STRUCTURE)/DEBIAN
    mkdir -p $(DEB_STRUCTURE)/usr/local/bin
    mkdir -p $(DEB_STRUCTURE)/usr/share/doc/$(PKG_NAME)

    # Copy the control file
    cp DEBIAN/control $(DEB_STRUCTURE)/DEBIAN/

    # Copy the post-installation script
    cp DEBIAN/postinst $(DEB_STRUCTURE)/DEBIAN/

    # Copy the installer script to the bin folder
    cp scripts/install_ros2.sh $(DEB_STRUCTURE)/usr/local/bin/

    # Generate the package
    dpkg-deb --build $(DEB_STRUCTURE)

    @echo "Package built: $(DEB_FILE)"

# Target to clean the build directory
clean:
    @echo "Cleaning up build files..."
    rm -rf $(DEB_STRUCTURE)

# Install the package (optional)
install: build
    sudo dpkg -i $(DEB_FILE)
    sudo apt-get install -f  # To install dependencies if needed

# Publish the package (GitHub Actions should handle publishing to a release)
publish: build
    @echo "Package built. Ready to publish to GitHub or other platforms."
