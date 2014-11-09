deployment do
  policy :sprinkle_server, roles: :app do
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