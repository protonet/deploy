class DeployRecipes < Deploy::Base

  include ::Deploy::Recipes::RailsMethods
  include ::Deploy::Recipes::GitMethods
  include ::Deploy::Recipes::NginxMethods
  include ::Deploy::Recipes::UnicornMethods


  def self.test
  end

end