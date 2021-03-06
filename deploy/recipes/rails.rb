# override for https://github.com/aws/opsworks-cookbooks/blob/release-chef-11.10/deploy/recipes/rails.rb
#
include_recipe 'deploy'

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'rails'
    Chef::Log.debug("Skipping deploy::rails application #{application} as it is not a Rails app")
    next
  end

  case deploy[:database][:type]
  when "mysql"
    include_recipe "mysql::client_install"
  when "postgresql"
    include_recipe "opsworks_postgresql::client_install"
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_rails do
    deploy_data deploy
    app application
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  execute 'Get Short Git Version Hash Into REVISION ' do
    user deploy[:user]
    group deploy[:group]
    cwd ::File.join(deploy[:deploy_to], "current")
    command "git rev-parse --short HEAD > REVISION"
  end
end
