# P4R-ENV

This project contains the software environment **p4r-env** defined for the [Plan4Res project](https://www.plan4res.eu/).

Below you can find instructions on how to install and run the package on:
* [Windows](https://gitlab.com/cerl/plan4res/p4r-env#windows)
* [MacOS](https://gitlab.com/cerl/plan4res/p4r-env#macos)
* [Linux](https://gitlab.com/cerl/plan4res/p4r-env#linux)

<a name="interact"></a>
Once the **p4r-env** is installed and tested, a list of commands can be seen with the command: `bin/p4r -h`.
It is also possible to get auto-completion of the commands by sourcing the file `source scripts/p4r_completion.bash`.
You can run the `bin/p4r` dispatch script that opens a shell within the environment or directly run `bin/p4r <command>` to run a command.

**Add-ons**

To see a list of the supported add-ons, you can run the command: `bin/p4r add-on`, e.g.
```
> bin/p4r add-on
Updating image - if you want to avoid this set 'P4R_SINGULARITY_IMAGE_PRESERVE=1' in plan4res.conf
No add-on specified. The following add-on recipes are known or already installed:
scip    : not installed
udj     : not installed
stopt   : not installed
sms++   : not installed

Use 'add-on <add-on name>' to install an add-on.
Use 'add-on <add-on name> help' to see a list of specific options per each add-on.
```
The available directory `data` can be used to access data within the environment.
Installed files of the add-ons can be found under the `$ADDONS_INSTALLDIR` directory within the
P4R-ENV shell (open with `bin/p4r` command and then `cd $ADDONS_INSTALLDIR`).

**SMS++ Installation**

To install the [SMS++](https://gitlab.com/smspp/smspp-project) add-on, run the following commands:
* Install StOpt add-on via: ` bin/p4r add-on stopt`
* Download CPLEX installer and put into p4r-env directory. It has to be a Linux version (with extension `.bin`)
* Install SMS++ via ` bin/p4r add-on sms++ CPLEX=<cplex installer>.bin`. It will ask you the login and password to access the SMS++ gitlab repo. Check with SMS++ authors if you are not in the authorized list to access the repo (check if you can access to the [SMS++](https://gitlab.com/smspp/smspp-project) webpage).

Once the installation is done, you can test the SMS++ installation by running some examples:
* Open a shell within the container via `bin/p4r`
* Example 1:
  * `cd $ADDONS_INSTALLDIR/sms++/examples/ucblock/netCDF_files/1UC_Data/24/`
  * `thermalunit_solver S12ramp10_24.nc4`
```
Using a default Solver configuration
Solver: CPXMILPSolver
Elapsed time: 1.26998274e-01 s
Status = 10 (Success)
Upper bound = 2.59073640e+03
Lower bound = 2.59073640e+03
```
* Example 2
  * `cd $ADDONS_INSTALLDIR/sms++/examples/ucblock/netCDF_files/UC_Data/T-Ramp/`
  * `ucblock_solver 10_0_1_w.nc4`

Other available commands for the SMS++ add-on are:
```
> bin/p4r add-on sms++ help
Updating image - if you want to avoid this set 'P4R_SINGULARITY_IMAGE_PRESERVE=1' in plan4res.conf
Targets for sms++ add-on (first target as default):
     install : Install sms++ add-on. Need to specify CPLEX=<CPLEX installer file>. StOpt add-on must be installed first.
               Use SCIP=1 to link with it (must be installed first).
               Use BUILD=Release or Debug to choose build mode (default: Release).
      update : Update and re-install sms++ add-on. StOpt add-on must be installed first.
               Use SCIP=1 to link with it (must be installed first).
               Keep previous CPLEX installation (if any), otherwise required to specific CPLEX=<CPLEX installer file>.
     compile : Compile sms++ add-on (no installation). Need to specify CPLEX=<CPLEX installer file>. StOpt add-on must be installed first.
               Use SCIP=1 to link with it (must be installed first).
               Use BUILD=Release or Debug to choose build mode (default: Release).
      getdev : Pull the sms++ develop branch.
       clean : Clean the sms++ build directory.
      status : Print sms++ version
   uninstall : Remove sms++ build and installation directories
        help : This help
Variables for sms++ add-on:
    CPLEX=<CPLEX installer file> : Specify the CPLEX installer file.
    BUILD=<Release or Debug>     : Specify the build mode (Release or Debug). Default is Release.
    SCIP=<0|1>                   : Link with SCIP if set to 1. Default is not to link.
```

**Run with MPI**

The `p4r-env` can be executed via MPI, e.g.:
```
> P4R_CMD="mpirun -np 2" bin/p4r mpitest
Updating image - if you want to avoid this set 'P4R_SINGULARITY_IMAGE_PRESERVE=1' in plan4res.conf
2
```
Here, `P4R_CMD` is used to set the run command for MPI and `mpitest` is a small MPI test program that returns the number of ranks.
Note that it is not possible to open a shell with the MPI execution, i.e. `P4R_CMD="mpirun -np 2" bin/p4r` will ignore the MPI submission and open a shell within the container.

**NOTE:** Only for Linux, it is possible to specificy the MPI implementation to use (MPICH or OpenMPI) by setting the variable `P4R_MPI_IMP` in the file `config/plan4res.conf`
during the installation. This is needed to ensure compatibility with the MPI implementation on the host system.

**Access to MarketLab (MKL)**

Currently, no demo is available to access (MKL). Need to register your credentials in the fle `config/marketlab.conf`. You can use the [marketlab.conf.template](config/marketlab.conf.template) as template.

**Update the p4r-env environment**

* Clean the caches: `bin/p4r -c`
* For Windows and macOS users, destroy the Vagrant VM (if up): `vagrant destroy`
* Update the environment: `git pull` (make sure you run `git config submodule.recurse true` first)
* For Windows and macOS users, restart the Vagrant VM: `vagrant up`

**TROUBLESHOOTING**

If during the installation of an add-on you get an error to access the repository (e.g. `remote: The project you were looking for could not be found.`),
please check with the author of repository that you have access (you can check if you can access the webpage).
For any other add-on error, please make sure you run `uninstall` (or `update`) before any new re-installation.


## Windows

### Prerequisite

Installation requires Windows 7 Pro 64bit SP1 or higher and [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell?view=powershell-6) 3.0 or higher.
Furthermore, the CPU must support [hardware virtualization](https://www.virtualbox.org/manual/ch10.html#hwvirt).
On many systems, the hardware virtualization features first need to be enabled in the BIOS.

### Packages Installation (execute once)

* Install Git for Windows (use default settings) https://git-for-windows.github.io/
* Install VirtualBox and Extension Pack https://www.virtualbox.org/wiki/Downloads
* Install Vagrant https://www.vagrantup.com/downloads.html
* (Optional) Install Vagrant Manager http://vagrantmanager.com/downloads/

### P4R Environment Installation (execute once)

* Run the Git bash
* `cd` # Move to the local user home directory (e.g. /c/Users/\<your login\>), you can change directory to a more appropriate one
* If your network uses a **proxy** (e.g. at EDF), set the following variables in the shell:
```
export http_proxy = <proxy address>:<port>
export https_proxy = ${http_proxy}
```
where `<proxy address>:<port>` is your proxy. (Optional) Add these lines to the `.bashrc` file to be permanent. Then, run the command `vagrant plugin install vagrant-proxyconf`.
* `git clone --recursive https://gitlab.com/cerl/plan4res/p4r-env`
* `cd p4r-env`
* `git config submodule.recurse true`
* `vagrant up` # Start the Virtual Machine. First execution requires to download the image. See NOTE below for more details.
* `vagrant halt`

****

If during `vagrant up` you get the error `VT-x is not available (VERR_VMX_NO_VMX)` (Intel processors) or `AMD-V is disabled` (AMD processors), it means that CPU doesn't support [hardware virtualization](https://www.virtualbox.org/manual/ch10.html#hwvirt).
On many systems, the hardware virtualization features first need to be enabled in the BIOS.

You can check which Virtual Machine (VM) is running in background by using the [Vagrant Manager GUI](http://vagrantmanager.com/windows/) (if installed).
Therefore you can suspend, halt or destroy the VM. It is also possible to use the CLI, by means of the commands:

```
vagrant up # Start the VM
vagrant halt # Stop the VM
vagrant suspend # Suspend VM execution
vagrant resume # Resume VM execution
vagrant destroy # Delete the VM
```

### Execution (test)

Here we run a [singularity](https://www.sylabs.io/singularity/) image that is automatically [built on gitlab](https://gitlab.com/cerl/plan4res/p4r-exec-singularity).
The configuration file is [plan4res.def](https://gitlab.com/cerl/plan4res/p4r-exec-singularity/blob/master/plan4res.def).

* Open the Git bash
* `cd ~/p4r-env` # Move to the directory where the P4R environment is installed
* If your network uses a **proxy** (e.g. at EDF), set the following variables in the shell:
```
export http_proxy = <proxy address>:<port>
export https_proxy = ${http_proxy}
```
where `<proxy address>:<port>` is your proxy. (Optional) Add these lines to the `.bashrc` file to be permanent.
* `vagrant up`
* `bin/p4r -t` # Check that there are no errors
* `vagrant halt` # Eventually destroy the VM if you don't need it anymore

**Note: if you are requested for a password to connect to the vagrant machine, please use `vagrant`.**

Please check [here](#interact) on how to interact with the environment.

## MacOS

### Installation (execute once)

* Open the Terminal
* Download Brew (if not already installed)

`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

* Install VirtualBox and Vagrant
```
brew cask install virtualbox
brew cask install vagrant
brew cask install vagrant-manager
```
* `git clone --recursive https://gitlab.com/cerl/plan4res/p4r-env`
* `cd p4r-env`
* `git config submodule.recurse true`
* `vagrant up` # Start the Virtual Machine. First execution requires to download the image. See NOTE below for more details.
* `vagrant halt`

**NOTE**

You can check which Virtual Machine (VM) is running in background by using the [Vagrant Manager GUI](http://vagrantmanager.com/).
Therefore you can suspend, halt or destroy the VM. It is also possible to use the CLI, by means of the commands:

```
vagrant up # Start the VM
vagrant halt # Stop the VM
vagrant suspend # Suspend VM execution
vagrant resume # Resume VM execution
vagrant destroy # Delete the VM
```

### Execution (test)

Here we run a [singularity](https://www.sylabs.io/singularity/) image that is automatically [built on gitlab](https://gitlab.com/cerl/plan4res/p4r-exec-singularity).
The configuration file is [plan4res.def](https://gitlab.com/cerl/plan4res/p4r-exec-singularity/blob/master/plan4res.def).

* Open the Terminal
* `cd p4r-env`
* `vagrant up`
* `bin/p4r -t` # Check that there are no errors
* `vagrant halt` # Eventually destroy the VM if you don't need it anymore

**Note: if you are requested for a password to connect to the vagrant machine, please use `vagrant`.**

Please check [here](#interact) on how to interact with the environment.

## Linux

### Installation (execute once)

Please refer to this [readme](https://gitlab.com/cerl/plan4res/p4r-exec-singularity/blob/master/README.md) on how to install Singularity.

For a rootless Singularity installation, you can enable `P4R_CACHE_SANDBOX=1` in the [plan4res.conf](config/plan4res.conf).
It is possible to set which MPI implementation to use inside the container (MPICH or OpenMPI) by setting the variable `P4R_MPI_IMP` in the file `config/plan4res.conf`.
This is needed to ensure compatibility with the MPI implementation on the host system.

### Execution (test)

* Open the Terminal
* `git clone --recursive https://gitlab.com/cerl/plan4res/p4r-env`
* `cd p4r-env`
* `git config submodule.recurse true`
* `bin/p4r -t` # Check that there are no errors

Please check [here](#interact) on how to interact the environment.
