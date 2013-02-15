class DeployTasks < Deploy::Base

  include ::Deploy::Tasks::Rails
  include ::Deploy::Tasks::Git
  include ::Deploy::Tasks::Nginx
  include ::Deploy::Tasks::Unicorn

  def self.test
  end

end