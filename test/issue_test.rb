
begin
  require "minitest"

  class TestCase < MiniTest::Test; end 
rescue LoadError
  require "minitest/unit"

  class TestCase < MiniTest::Unit::TestCase; end 
end

require "minitest/autorun"
require "active_record"
require "logger"
require "yaml"

DATABASE = ENV["DATABASE"] || "sqlite"

ActiveRecord::Base.establish_connection YAML.load_file(File.expand_path("../database.yml", __FILE__))[DATABASE]

ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS accounts"
ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS shouts"
ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS text_shouts"
ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS picture_shouts"

ActiveRecord::Base.connection.create_table :accounts do |t|
end

ActiveRecord::Base.connection.create_table :shouts do |t|
  t.references :account
  t.string :content_type
  t.integer :content_id
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

class IssueTest < TestCase
  def test_issue
    account = Account.create!

    text_shout = TextShout.new(:text => "Hello")
    picture_shout = PictureShout.new(:url => "some url")

    account.shouts.create! :content => text_shout
    account.shouts.create! :content => picture_shout

    assert_includes Account.eager_load(:text_shouts, :picture_shouts).where("text_shouts.text like '%Hello%'"), account
    assert_includes Account.eager_load(:text_shouts, :picture_shouts).where("picture_shouts.url like '%some%'"), account
  end
end

