# P4R-EXEC-SINGULARITY

This project contains a Singularity container containing the software 
environment defined for the Plan4Res project.

## How to install Singularity 

Two possible installations are provided:

* with superuser priviligies (suggested)
* without superuser priviligies.

Nevertheless, some system dependencies must be first installed on the system:

* Development Tools
* git
* openssl-devel (libssl-dev on Debian/Ubuntu, openssl-devel on CentOS/RHEL)
* libuuid-devel (uuid-dev on Debian/Ubuntu, libuuid-devel on CentOS/RHEL)
* squashfs-tools (only needed when installing without superuser priviligies)

Furthermore, only when installing without superuser priviligies,
the kernel must support [user_namespace](http://man7.org/linux/man-pages/man7/user_namespaces.7.html) and have it enabled at boot-time.
A possible way to check if the support is enabled on Debian/Ubuntu systems is 
if the file `/proc/sys/kernel/unprivileged_userns_clone` exists and it is equal to `1` 
(see [here](https://superuser.com/questions/1094597/enable-user-namespaces-in-debian-kernel) for more details).

### Prerequisite: install GO (skip if it is already installed)

* Move to the directory where you want install singularity
* `export VERSION=1.14.12 OS=linux ARCH=amd64`
* `curl -C - -sSO https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz`
* `tar -xzvf go$VERSION.$OS-$ARCH.tar.gz`
* `rm go$VERSION.$OS-$ARCH.tar.gz` # cleanup
* `export PATH=${PWD}/go/bin:${PATH}`

### Install Singularity with superuser priviligies (suggested)

* Move to a directory where you want to install Singularity
* `export SINGULARITY=${PWD}`
* `git clone https://github.com/sylabs/singularity.git`
* `cd singularity`
* `git checkout v3.8.4`
* `./mconfig --prefix=${SINGULARITY}/singularity_install -c "gcc" -x "g++"`
* `make -C builddir`
* `sudo make -C builddir install`
* `export PATH=${SINGULARITY}/singularity_install/bin:${PATH}` # Add PATH to .bashrc to be permanent

### Install Singularity without superuser priviligies (suggested)

* Move to a directory where you want to install Singularity
* `export SINGULARITY=${PWD}`
* `git clone https://github.com/sylabs/singularity.git`
* `cd singularity`
* `git checkout v3.8.4`
* `./mconfig --without-suid --prefix=${SINGULARITY}/singularity_install -c "gcc" -x "g++"`
* `make -C builddir`
* `make -C builddir install`
* `export PATH=${SINGULARITY}/singularity_install/bin:${PATH}` # Add PATH to .bashrc to be permanent

### Test Singularity installation with P4R image

Two versions of the image are available, based on MPICH and OpenMPI implementations, respectively.
Choose the version that matches your MPI implementation by setting the variable `export MPI_DIST=MPICH` or `export MPI_DIST=OpenMPI`.
In the following, we will use `MPICH`.

* `export MPI_DIST=MPICH`
* `wget https://gitlab.com/api/v4/projects/cerl%2Fplan4res%2Fp4r-exec-singularity/jobs/artifacts/master/raw/singularity/plan4res_${MPI_DIST}.sif?job=build_${MPI_DIST} -O plan4res_${MPI_DIST}.sif`
* `singularity test plan4res_${MPI_DIST}.sif` # Check that there are no errors
* `rm -f plan4res_${MPI_DIST}.sif` # cleanup

Check that you don't get any error and that the execution is clean.

## How to use Swift-t with an external MPI installation

**Note that the MPI installation has to have MPICH ABI v3.x to be compatible with the swift-t installation within the singularity image.**

To run a Swift-t workflow with an external MPI installation, first we have to compile the swift script with stc and then run in parallel with turbine, e.g.:

* `export MPI_DIST=MPICH`
* `export SINGULARITYENV_LD_LIBRARY_PATH=${LD_LIBRARY_PATH}` # Add to .bashrc to be permanent
* `git clone https://gitlab.com/cerl/plan4res/p4r-exec-singularity.git`
* `cd p4r-exec-singularity`
* `wget https://gitlab.com/api/v4/projects/cerl%2Fplan4res%2Fp4r-exec-singularity/jobs/artifacts/master/raw/singularity/plan4res_${MPI_DIST}.sif?job=build_${MPI_DIST} -O plan4res_${MPI_DIST}.sif`
* `singularity run ./plan4res_${MPI_DIST}.sif "stc tests/test1.swift"` # compile swift-t script
* `mpiexec -np 4 singularity run ./plan4res_${MPI_DIST}.sif "turbine tests/test1.tic"` # execute swift-t workload
* `rm -f plan4res_${MPI_DIST}.sif` # cleanup

**Note that it is possible to [bind paths and mounts](https://www.sylabs.io/guides/3.5/user-guide/bind_paths_and_mounts.html) on the Singularity container to get access to some directories.**
In particular, the path where singularity is installed and the current path where is executed must be accessible from within the container.
Use `-B` command-line option for that. For example, suppose we want to access `/data` of the host from the container, we have to:

* `singularity run -B /data ./plan4res_${MPI_DIST}.sif "ls /data"` # Run 'ls /data' inside the container

Mounting points can be permanently included into image during its building. Please fill an issue with your request (or make a Merge Request).

## Installation and test on Cray systems

Here we assume to install singularity and run it from the home directory. Please refer to the [previous section](README.md#how-to-use-swift-t-with-an-external-mpi-installation) 
if you want to install and run in different directories, which are not mounted within the container.

### Installation

First of all, run the following commands:

* `module swap PrgEnv-cray PrgEnv-gnu`
* `module swap cray-mpich cray-mpich-abi`

Then, the installation is the same reported in the section on [how to install without superuser priviligies](README.md#how-to-install-singularity).
You can make permanent mounting of directories by adding them to the file `<singularity installation directory>/etc/singularity/singularity.conf`, for example

```
bind path = /lus
bind path = /cray
```

### How to use Swift-t with the Cray MPI installation and SLURM

* `module swap PrgEnv-cray PrgEnv-gnu`
* `module swap cray-mpich cray-mpich-abi`
* `export SINGULARITYENV_LD_LIBRARY_PATH=${CRAY_LD_LIBRARY_PATH}` # Add to .bashrc to be permanent
* `export MPI_DIST=MPICH`
* `git clone https://gitlab.com/cerl/plan4res/p4r-exec-singularity.git`
* `cd p4r-exec-singularity`
* `wget https://gitlab.com/api/v4/projects/cerl%2Fplan4res%2Fp4r-exec-singularity/jobs/artifacts/master/raw/singularity/plan4res_${MPI_DIST}.sif?job=build_${MPI_DIST} -O plan4res_${MPI_DIST}.sif`
* `singularity run ./plan4res_${MPI_DIST}.sif "stc tests/test1.swift"` # compile swift-t script
* `srun --ntasks=4 --ntasks-per-node=1 --cpus-per-task=1 --nodes=4 singularity run -B /home -B /etc:/etc:ro -B /var:/var:ro -B /opt:/opt:ro ./plan4res_${MPI_DIST}.sif "turbine tests/test1.tic"` # execute swift-t workload, note the directories binding
* `rm -rf plan4res_${MPI_DIST}.sif` # cleanup
