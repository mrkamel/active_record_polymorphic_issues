
source 'https://rubygems.org'

gem 'rake'
gem 'bundler'
gem 'minitest'
gem 'activerecord'

platforms :jruby do
  gem 'activerecord-jdbcmysql-adapter'
  gem 'activerecord-jdbcsqlite3-adapter'
  gem 'activerecord-jdbcpostgresql-adapter'
end

platforms :ruby do
  gem 'sqlite3'
  gem 'mysql2'
  gem 'pg'
end

platforms :rbx do
  gem 'racc'
  gem 'rubysl', '~> 2.0'
  gem 'psych'
end

