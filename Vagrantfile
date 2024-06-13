# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "bento/debian-10"
  config.vm.box_version = "202010.24.0"
  config.vm.hostname = "plan4res-vm"
  # default to two CPUs
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 2
    # Customize the amount of memory on the VM:
    vb.memory = "2048"
  end

  # Set the proxy
  # Need to set the variables:
  # export http_proxy = <proxy address>:<port>
  # export https_proxy = ${http_proxy}
  # where <proxy address>:<port> is your proxy
  # Then, install the specific plugin:
  # > vagrant plugin install vagrant-proxyconf
  if Vagrant.has_plugin?("vagrant-proxyconf")
    puts "find proxyconf plugin!"
    if ENV["http_proxy"]
      puts "http_proxy: " + ENV["http_proxy"]
      config.proxy.http = ENV["http_proxy"]
    end
    if ENV["https_proxy"]
      puts "https_proxy: " + ENV["https_proxy"]
      config.proxy.https = ENV["https_proxy"]
    end
    config.proxy.no_proxy = "localhost,127.0.0.1"
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder "/", "/host"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    echo "Provisioning image. Progress can be traced in the VM's ~/.install.log by"
    echo "     vagrant ssh -c \"less .install.log\""
    echo "Update Linux image... This may take a while..."
    rm -rf ~/.install.log
    # Remove stdin requests with
    sudo ex +"%s@DPkg@//DPkg" -scwq /etc/apt/apt.conf.d/70debconf
    sudo dpkg-reconfigure debconf -f noninteractive -p critical
    #
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade 2>&1 >> ~/.install.log
    sudo apt-get --allow-releaseinfo-change update 2>&1 > ~/.install.log
    if test -f .p4r-provisioned ; then
      echo "Already provisioned"
    else
      set -e
      echo "Installing packages... This may take a while..."
      sudo apt-get install -y build-essential libssl-dev uuid-dev git squashfs-tools debconf-utils mpich 2>&1 >> ~/.install.log
      # ensure DASH is not the default shell (p4r-env needs bash)
      echo "dash dash/sh boolean false" |sudo debconf-set-selections
      #
      cd
      echo "Installing Go 1.13..."
      export VERSION=1.14.12 OS=linux ARCH=amd64
      wget -q https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz 2>&1 >> ~/.install.log
      tar -xzvf go$VERSION.$OS-$ARCH.tar.gz 2>&1 >> ~/.install.log
      rm go$VERSION.$OS-$ARCH.tar.gz
      export PATH=${PWD}/go/bin:${PATH}
      #
      echo "Downloading singularity..."
      git clone https://github.com/sylabs/singularity.git 2>&1 >> ~/.install.log
      cd singularity
      git checkout v3.8.4 2>&1 >> ~/.install.log
      #
      echo "Compiling singularity..."
      ./mconfig --prefix=${HOME}/.singularity_install -c "gcc" -x "g++" 2>&1 >> ~/.install.log
      make -C builddir 2>&1 >> ~/.install.log
      echo "Installing singularity..."
      sudo make -C builddir install 2>&1 >> ~/.install.log
      cd
      echo "export PATH=${HOME}/.singularity_install/bin:"'${PATH}' >> .bash_profile
      # Mount /vagrant directory on the image
      echo "export SINGULARITY_BIND=/vagrant,/host" >> .bash_profile
      # clean-up
      sudo rm -rf go singularity
      #
      # Enable user namespaces in Debian kernel (see https://superuser.com/questions/1094597/enable-user-namespaces-in-debian-kernel)
      sudo echo 'kernel.unprivileged_userns_clone=1' > ~/00-local-userns.conf
      sudo mv ~/00-local-userns.conf /etc/sysctl.d/00-local-userns.conf
      sudo service procps restart
      #
      # Link in host-side p4r directory structure
      rm -f ~/data
      rm -f ~/config
      rm -f ~/scripts
      rm -f ~/bin
      ln -s /vagrant/data ~/data
      ln -s /vagrant/config ~/config
      ln -s /vagrant/scripts ~/scripts
      ln -s /vagrant/bin ~/bin
      ln -s /vagrant p4r-env

      # Save Vagrantfile for checking
      cp /vagrant/Vagrantfile .Vagrantfile.cached

      touch .p4r-provisioned

      echo "Installation done!"
    fi
  SHELL
end
