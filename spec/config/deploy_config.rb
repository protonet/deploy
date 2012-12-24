class DeployConfig

  def self.common
    dep_config.set :username, 'test'
    dep_config.set :env,      'test'
    dep_config.set :remote,   'example.com'
  end

  def self.test

  end

end