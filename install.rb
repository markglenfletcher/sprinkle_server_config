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
    runner 'mkdir /usr/local/share/ca-certificates'
    runner 'wget -cq -O /usr/local/share/ca-certificates/DigiCertHighAssuranceEVRootCA.crt http://cacerts.digicert.com/DigiCertHighAssuranceEVRootCA.crt'
    runner 'update-ca-certificates'
    requires :ca_certificates
  end

  policy :sprinkle_server, roles: :app do
    requires :build_essential
    requires :ca_certificates
    requires :digicert_root_ca
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