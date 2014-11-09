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

  policy :sprinkle_server, roles: :app do
    requires :build_essential
    requires :ca_certificates
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