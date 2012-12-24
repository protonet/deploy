class DeployRecipes < Deploy::Base

  include ::Deploy::Methods::Rails
  include ::Deploy::Methods::Git
  include ::Deploy::Methods::Nginx
  include ::Deploy::Methods::Unicorn

  def self.test
  end

end