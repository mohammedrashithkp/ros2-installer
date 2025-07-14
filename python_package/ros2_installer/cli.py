#!/usr/bin/env python3

import os
import sys
import subprocess
import time
import argparse
from rich.console import Console
from rich.panel import Panel
from rich.progress import (
    Progress,
    SpinnerColumn,
    TextColumn,
    BarColumn,
    TimeElapsedColumn,
    MofNCompleteColumn,
)
from rich.prompt import Prompt, Confirm
import pwd
console = Console()

UBUNTU_ROS_SUPPORT = {
    "focal": ["foxy", "galactic"],
    "jammy": ["humble", "iron"],
    "noble": ["jazzy"],
}

def get_ubuntu_version():
    try:
        with open("/etc/os-release", "r") as f:
            lines = f.readlines()
        version = ""
        codename = ""
        for line in lines:
            if line.startswith("VERSION_ID="):
                version = line.strip().split("=")[1].strip('"')
            if line.startswith("VERSION_CODENAME="):
                codename = line.strip().split("=")[1]
        return version, codename
    except Exception:
        return "Unknown", "Unknown"

def run_command(command, abort_on_fail=False, env=None):
    try:
        subprocess.run(command, shell=True, check=True, env=env)
    except subprocess.CalledProcessError as e:
        console.print(f"[red]❌ Failed:[/red] `{command}` (exit code {e.returncode})")
        if abort_on_fail:
            console.print("[red]Aborting due to critical failure.[/red]")
            sys.exit(1)

def ensure_colcon_installed():
    if subprocess.run("which colcon", shell=True, stdout=subprocess.DEVNULL).returncode != 0:
        console.print("[yellow]colcon not found. Installing...[/yellow]")
        run_command("sudo apt-get -q=2 install -y python3-colcon-common-extensions", abort_on_fail=True)
    else:
        console.print("[green]colcon already installed.[/green]")

def main():
    

    parser = argparse.ArgumentParser(description="ROS 2 Installer Script")
    parser.add_argument("--version-codename", type=str, help="Ubuntu codename (e.g., jammy)")
    parser.add_argument("--ros-distro", type=str, help="ROS 2 distro to install (e.g., humble)")
    parser.add_argument("--make-workspace", choices=["yes", "no"], default="yes", help="Whether to create a workspace")
    parser.add_argument("--path-of-workspace", type=str, help="Path to create workspace")
    parser.add_argument("--headless", action="store_true", help="Run in headless mode (no prompts)")

    args = parser.parse_args()

    version, detected_codename = get_ubuntu_version()

    codename = args.version_codename or detected_codename
    supported_ros = UBUNTU_ROS_SUPPORT.get(codename, [])

    console.print(
        Panel.fit(
            f"[bold green]Ubuntu Version:[/bold green] {version}\n"
            f"[bold cyan]Codename:[/bold cyan] {codename}\n"
            f"[bold yellow]Supported ROS 2 Distros:[/bold yellow] {', '.join(supported_ros) if supported_ros else 'None detected'}",
            title="[bold magenta]OS Info[/bold magenta]",
            border_style="bright_blue"
        )
    )

    ros_choice = None
    if args.ros_distro:
        ros_choice = args.ros_distro
    elif supported_ros and args.headless:
        ros_choice = supported_ros[0]
    elif supported_ros:
        ros_choice = Prompt.ask(
            f"[bold green]Choose ROS 2 distro to install[/bold green]",
            choices=supported_ros,
            default=supported_ros[0]
        )
    else:
        if args.headless:
            console.print("[red]❌ No supported ROS 2 distro detected and no distro provided in headless mode.[/red]")
            sys.exit(1)
        ros_choice = Prompt.ask(
            "[bold green]No supported distro detected. Enter desired ROS 2 distro manually[/bold green]"
        )

    console.print(
        Panel.fit(
            f"[bold green]✅ You selected:[/bold green] [yellow]{ros_choice}[/yellow]",
            border_style="green"
        )
    )

    steps = [
        ("Setting up locales", [
            "sudo locale-gen en_US.UTF-8",
            "sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8",
            "export LANG=en_US.UTF-8"
        ]),
        ("Adding ROS 2 repository", ["sudo apt-get -q=2 update",
            "sudo apt-get -q=2 install -y curl gnupg ",
            "curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | sudo gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg",
            'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] '
            'http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" '
            '| tee /etc/apt/sources.list.d/ros2.list > /dev/null'
        ]),
        ("Updating package lists", [
            "sudo apt-get -q=2 update"
        ]),
        ("Installing ROS 2 packages", [
            f"sudo apt-get -q=2 install ros-{ros_choice}-desktop -y"
        ]),
        ("Making setup.bash executable", [
            f"chmod +x /opt/ros/{ros_choice}/setup.bash"
        ]),
    ]

    console.print(
        Panel.fit(
            "[cyan]Running installation steps... this may take a few minutes[/cyan]",
            title="[bold magenta]ROS 2 Installation Progress[/bold magenta]",
            border_style="green"
        )
    )

    with Progress(
        SpinnerColumn(),
        TextColumn("[bold blue]{task.fields[step]}"),
        BarColumn(bar_width=None),
        MofNCompleteColumn(),
        TimeElapsedColumn(),
    ) as progress:
        task = progress.add_task("Installing...", total=len(steps), step="Starting...")
        env = os.environ.copy()
        env["DEBIAN_FRONTEND"] = "noninteractive"
        for label, commands in steps:
            progress.update(task, step=label)
            for cmd in commands:
                run_command(cmd, abort_on_fail=True, env=env)
            progress.advance(task)
            time.sleep(0.2)

    ensure_colcon_installed()

    if args.make_workspace == "yes":
        default_workspace_name = "ros2_ws"
        src_folder = "src"
        user_home = os.path.expanduser("~")
        desktop_dir = os.path.join(user_home, "Desktop")

        workspace_name = default_workspace_name
        if not args.headless:
            workspace_name = Prompt.ask(
                "[bold green]Enter the workspace name[/bold green]",
                default=default_workspace_name
            )

        workspace_dir = args.path_of_workspace or desktop_dir
        workspace_path = os.path.join(workspace_dir, workspace_name)

        console.print(
            Panel.fit(
                f"[bold green]Workspace Name:[/bold green] {workspace_name}\n"
                f"[bold cyan]Workspace Path:[/bold cyan] {workspace_path}",
                title="[bold magenta]Workspace Configuration[/bold magenta]",
                border_style="bright_blue"
            )
        )

        if os.path.exists(workspace_path):
            console.print(f"[yellow]⚠️ Workspace already exists at {workspace_path}. Skipping creation.[/yellow]")
        else:
            console.print(f"[green]Creating workspace at {workspace_path}...[/green]")
            os.makedirs(os.path.join(workspace_path, src_folder), exist_ok=True)
            console.print("[green]Workspace and src folder created successfully.[/green]")

        os.chdir(workspace_path)
        console.print("[cyan]Initializing ROS 2 workspace with colcon build... (log saved to colcon_build.log)[/cyan]")
        with Progress(
            SpinnerColumn(),
            TextColumn("[bold blue]{task.fields[step]}"),
            TimeElapsedColumn(),
        ) as progress:
            t = progress.add_task("Initializing...", total=None, step="colcon build")
            try:
                subprocess.run(
                    ["colcon", "build", "--packages-select", "none"],
                    stdout=open("colcon_build.log", "w"),
                    stderr=subprocess.STDOUT,
                    check=True
                )
                progress.update(t, step="Done")
                time.sleep(0.5)
            except subprocess.CalledProcessError:
                progress.stop()
                console.print("[red]❌ colcon build failed. Check colcon_build.log for details.[/red]")
                sys.exit(1)

        if not args.headless and Confirm.ask("[bold green]Do you want to add the workspace setup to your ~/.bashrc?[/bold green]", default=False):
            bashrc_path = os.path.join(user_home, ".bashrc")
            with open(bashrc_path, "a") as f:
                f.write(f"\nsource {workspace_path}/install/setup.bash\n")
            console.print("[green]Added workspace setup to ~/.bashrc.[/green]\n[cyan]Run 'source ~/.bashrc' or restart your shell.[/cyan]")

        console.print(f"[bold green]✅ ROS 2 setup completed![/bold green]\n[cyan]Workspace path:[/cyan] {workspace_path}")
    else:
        console.print("[cyan]Skipping workspace creation as per arguments.[/cyan]")


if __name__ == "__main__":
    main()
