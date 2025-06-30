
> Disclaimer:
"This is not an official ROS2 distribution. This is a file that installs from the official ROS2 repositories. The owner of this project, platform, or service shall not be held liable for any loss, damage, or corruption of data, whether caused by system failures, user errors, or any other unforeseen circumstances. By using this service, the user acknowledges and agrees that they are solely responsible for backing up and protecting their data. The owner makes no representations or warranties regarding the security, accuracy, or completeness of any data stored or processed through the service."
![](./assets/Ros2-installer.png)
## Who is it for
- Beginners who are starting out ROS2 and are not completelty comfortable with terminal
- Experienced Dev who need a least-effort set-up
- Devs who are too lazy to copy paste the commands from Official Website  


## Installation options


|Sl.No|Options | Status |
|---|-----|---|
|1| [Bash-Script](#installation-procedure)| Stable|
|2| [Debian](./Deb-file)| In Development |
|3| [Snap](./Snap-file)| In Development |

## Installation Procedure

**Pro tip :  Read the next section before proceeding and at-least ask the chatgpt what the  [script](https://raw.githubusercontent.com/mohammedrashithkp/ros2-installer/stable/ros2-installer.sh) does before running a random script from internet.**

Copy the Following command and Paste in your terminal (ctrl + shift + v) 
 ```bash
    curl -sSL https://raw.githubusercontent.com/mohammedrashithkp/ros2-installer/stable/ros2-installer.sh | bash
 ```

## What Happens under the hood

Here the `UBUNTU_CODENAME` is used from `/etc/os-releases` to detect the ubuntu-codename such as jammy,noble etc as the ros packages are specific to each.After detecting ,it will show the names of the available ros2 distro (humble,jazzy etc) and prompts the user to enter the distro they wish to install.

It proceeds to install the dependencies and ros2-disro in the Desktop form, which contains all the necessary things to get started.The setting up of locale and ros2-distro-desktop takes some time so kindly be patient .

Now we proceed to workspace creation which works like virtual environments in Python .You can treat it as a folder with all the necessary files to run ros2 packages.By sourcing the workspace we are able to run ros2 nodes from anywhere in the system.The script will prompt the user for a name and the path where you want to set it up ,the default is ros2_ws and your desktop .

Later we create `workspace_folder/src` to store all the ros2 packages and initialise the workspace .Now you end up with a proper workspace with src ,build ,install folders .

And as a final step , you are prompted whether you need to add the commands for sourcing in the ~/.bashrc .Adding it will allow you to run the packages installed in the ros2 workspace from anywhere in your system .Denying it means that you have to run `source /path/to/workspace/install/setup.bash` before accessing ros2 packages to tell the system where to look for the files.

Now you can clone your desired ros2 projects into your src folder and run colcon build at workspace folder level or you can create new package by following the [official documentation](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Creating-Your-First-ROS2-Package.html)


**Kindly star the [repo](https://github.com/mohammedrashithkp/ros2-installer) if it helped you save time and have a nice day!!**
