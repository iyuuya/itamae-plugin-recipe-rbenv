package "libffi-devel"
package "openssl-devel"
package "readline-devel"

require "itamae/plugin/recipe/rbenv"

git rbenv_root do
  repository "git://github.com/sstephenson/rbenv.git"
end

git "#{rbenv_root}/plugins/ruby-build" do
  repository "git://github.com/sstephenson/ruby-build.git"
  if node[:'ruby-build'] && node[:'ruby-build'][:revision]
    revision node[:'ruby-build'][:revision]
  end
end

node[:rbenv][:versions].each do |version|
  execute "rbenv install #{version}" do
    command "#{rbenv_init} rbenv install #{version}"
    not_if  "#{rbenv_init} rbenv versions | grep #{version}"
  end
end

node[:rbenv][:global].tap do |version|
  execute "rbenv global #{version}" do
    command "#{rbenv_init} rbenv global #{version}"
    not_if  "#{rbenv_init} rbenv version | grep #{version}"
  end
end