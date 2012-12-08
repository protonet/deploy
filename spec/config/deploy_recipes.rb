class DeployRecipes < Deploy::Base

  include ::Deploy::Recipes::CommonMethods
  include ::Deploy::Recipes::RailsCommonMethods

  def self.test
  end

end