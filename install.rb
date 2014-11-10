deployment do
  package :build_essential do
    description 'Build Essential'
    apt 'build-essential' do
      pre :install, 'apt-get -y update', 'apt-get -y dist-upgrade'
    end
  end

  package :ca_certificates do
    description 'CA Certificates'
    apt 'ca-certificates'
  end

  package :digicert_root_ca do
    description 'Install digicert root ca cert for SSL comms with github via wget'
    runner 'wget -cq -O /usr/local/share/ca-certificates/DigiCertHighAssuranceEVRootCA.crt http://cacerts.digicert.com/DigiCertHighAssuranceEVRootCA.crt'
    runner 'update-ca-certificates'
    requires :ca_certificates
  end

  package :git do
    apt 'git'
    verify do
      has_executable 'git'
    end
  end

  package :ruby_install do
    description 'Ruby installer'
    source 'https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz' do
      custom_dir 'ruby-install-0.5.0'
      custom_install 'make install'
    end
    verify do
      has_executable 'ruby-install'
    end
    requires :digicert_root_ca
  end

  package :chruby do
    description 'Install Ruby Version Management tool'
    source 'https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz' do
      custom_dir 'chruby-0.3.8'
      custom_install 'make install'
    end
    push_text 'source /usr/local/share/chruby/chruby.sh', '~/.bashrc'
    push_text 'source /usr/local/share/chruby/auto.sh', '~/.bashrc'
    runner 'source ~/.bashrc'
    verify do
      has_file '/usr/local/share/chruby/chruby.sh'
    end
    requires :ruby_install
  end

  package :install_mri do
    description 'Install version of ruby'
    version = '2.1.3'
    runner "ruby-install ruby #{version}"
    push_text 'ruby-2.1.3', '~/.ruby-version'
    verify do
      has_file '/opt/rubies/ruby-2.1.3/bin/ruby'
    end
    requires :chruby
  end

  policy :sprinkle_server, roles: :app do
    requires :build_essential
    requires :ca_certificates
    requires :digicert_root_ca
    requires :ruby_install
    requires :chruby
    requires :install_mri
    requires :git
  end

  delivery :ssh do
    user 'root'
    password ARGV[1]
    role :app, ARGV[0]
  end

  source do
    prefix   '/usr/local'           # where all source packages will be configured to install
    archives '/usr/local/sources'   # where all source packages will be downloaded to
    builds   '/usr/local/build'     # where all source packages will be built
  end
end