class DeployConfig

  def self.test
    dep_config.set :username, 'test'
    dep_config.set :remote,   'example.com'
  end

  def self.edge
  end

  def self.staging
  end

  def self.internal
  end

  def self.production
  end

end