
require "bundler/setup"
require "active_record"
require "logger"

puts ActiveRecord::VERSION::STRING

ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => "memory"

ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS accounts"
ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS shouts"
ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS text_shouts"
ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS picture_shouts"

ActiveRecord::Base.connection.create_table :accounts do |t|
end

ActiveRecord::Base.connection.create_table :shouts do |t|
  t.references :account
  t.string :content_type
  t.string :content_id
end

ActiveRecord::Base.connection.create_table :text_shouts do |t|
  t.text :text
end

ActiveRecord::Base.connection.create_table :picture_shouts do |t|
  t.text :url
end

class Shout < ActiveRecord::Base
  belongs_to :account
  belongs_to :content, :polymorphic => true
end

class TextShout < ActiveRecord::Base
  validates :text, :presence => true
end

class PictureShout < ActiveRecord::Base
  validates :url, :presence => true
end

class Account < ActiveRecord::Base
  has_many :shouts
  has_many :text_shouts, :through => :shouts, :source => :content, :source_type => TextShout
  has_many :picture_shouts, :through => :shouts, :source => :content, :source_type => PictureShout
end

account = Account.create!

text_shout = TextShout.new(:text => "Hello")
picture_shout = PictureShout.new(:url => "some url")

account.shouts.create!(:content => text_shout)
account.shouts.create!(:content => picture_shout)

old_logger = ActiveRecord::Base.logger

begin
  ActiveRecord::Base.logger = Logger.new(STDOUT)

  puts Account.eager_load(:text_shouts, :picture_shouts).where("picture_shouts.url like '%some%'").inspect
ensure
  ActiveRecord::Base.logger = old_logger
end


