# This recipe requires `rbenv_root` is defined.

include_recipe 'rbenv::dependency'

scheme     = node[:rbenv][:scheme]
rbenv_root = node[:rbenv][:rbenv_root]

git rbenv_root do
  repository "#{scheme}://github.com/rbenv/rbenv.git"
  revision node[:rbenv][:revision] if node[:rbenv][:revision]
  user node[:rbenv][:user] if node[:rbenv][:user]
end

directory File.join(rbenv_root, 'plugins') do
  user node[:rbenv][:user] if node[:rbenv][:user]
end
if node[:rbenv][:cache]
  directory File.join(rbenv_root, 'cache') do
    user node[:rbenv][:user] if node[:rbenv][:user]
  end
end

define :rbenv_plugin do
  name = params[:name]

  if node[name] && (node[name][:install] || node[name][:revision])
    git "#{rbenv_root}/plugins/#{name}" do
      repository "#{scheme}://github.com/rbenv/#{name}.git"
      revision node[name][:revision] if node[name][:revision]
      user node[:rbenv][:user] if node[:rbenv][:user]
    end
  end
end

if node[:'rbenv-default-gems'] && node[:'rbenv-default-gems'][:'default-gems']
  node[:'rbenv-default-gems'][:install] = true
  file "#{rbenv_root}/default-gems" do
    content node[:'rbenv-default-gems'][:'default-gems'].join("\n") + "\n"
    mode    '664'
    user node[:rbenv][:user] if node[:rbenv][:user]
  end
end

rbenv_plugin 'ruby-build'
rbenv_plugin 'rbenv-default-gems'

rbenv_init = <<-EOS
  export RBENV_ROOT=#{rbenv_root}
  export PATH="#{rbenv_root}/bin:${PATH}"
  eval "$(rbenv init --no-rehash -)"
EOS

node[:rbenv][:versions].each do |version|
  execute "rbenv install #{version}" do
    command "#{rbenv_init} rbenv install #{version}"
    not_if  "#{rbenv_init} rbenv versions | grep #{version}"
    user node[:rbenv][:user] if node[:rbenv][:user]
  end
end

if node[:rbenv][:global]
  node[:rbenv][:global].tap do |version|
    execute "rbenv global #{version}" do
      command "#{rbenv_init} rbenv global #{version}"
      not_if  "#{rbenv_init} rbenv version | grep #{version}"
      user node[:rbenv][:user] if node[:rbenv][:user]
    end
  end
end
