require 'rubygems'
require 'active_illusion'
require 'squeel'

TIMES = (ENV['N'] || 10000).to_i

require 'rubygems'
require "active_record"

conn = { :adapter => 'sqlite3', :database => ':memory:' }
ActiveRecord::Base.establish_connection(conn)

class User < ActiveRecord::Base
    connection.create_table :users, :force => true do |t|
        t.string :name, :email
        t.timestamps
    end

    has_many :exhibits
end

class Exhibit < ActiveRecord::Base
    connection.create_table :exhibits, :force => true do |t|
        t.belongs_to :user
        t.string :name
        t.text :notes
        t.timestamps
    end

    belongs_to :user

    def look; attributes end
    def feel; look; user.name end

    def self.look(exhibits) exhibits.each { |e| e.look } end
    def self.feel(exhibits) exhibits.each { |e| e.feel } end
end

module ActiveRecord
    class Faker
        LOREM = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse non aliquet diam. Curabitur vel urna metus, quis malesuada elit. Integer consequat tincidunt felis. Etiam non erat dolor. Vivamus imperdiet nibh sit amet diam eleifend id posuere diam malesuada. Mauris at accumsan sem. Donec id lorem neque. Fusce erat lorem, ornare eu congue vitae, malesuada quis neque. Maecenas vel urna a velit pretium fermentum. Donec tortor enim, tempor venenatis egestas a, tempor sed ipsum. Ut arcu justo, faucibus non imperdiet ac, interdum at diam. Pellentesque ipsum enim, venenatis ut iaculis vitae, varius vitae sem. Sed rutrum quam ac elit euismod bibendum. Donec ultricies ultricies magna, at lacinia libero mollis aliquam. Sed ac arcu in tortor elementum tincidunt vel interdum sem. Curabitur eget erat arcu. Praesent eget eros leo. Nam magna enim, sollicitudin vehicula scelerisque in, vulputate ut libero. Praesent varius tincidunt commodo".split
        def self.name
            LOREM.grep(/^\w*$/).sort_by { rand }.first(2).join ' '
        end

        def self.email
            LOREM.grep(/^\w*$/).sort_by { rand }.first(2).join('@') + ".com"
        end
    end
end

class Test0 < ActiveRecord::Illusion
  column :name
  column :exhibition
  #belongs_to :user, :foreign_key => :name

  view do
    select{ users.name }.from("users")
  end
end

# pre-compute the insert statements and fake data compilation,
# so the benchmarks below show the actual runtime for the execute
# method, minus the setup steps

# Using the same paragraph for all exhibits because it is very slow
# to generate unique paragraphs for all exhibits.
notes = ActiveRecord::Faker::LOREM.join ' '
today = Date.today


describe ActiveRecord::Illusion do
    before :each do

        User.destroy_all

        Exhibit.destroy_all

        puts 'Inserting 100 users and exhibits...'
        100.times do
            user = User.create(
                :created_at => today,
                :name       => ActiveRecord::Faker.name,
                :email      => ActiveRecord::Faker.email
            )

            Exhibit.create(
                :created_at => today,
                :name       => ActiveRecord::Faker.name,
                :user       => user,
                :notes      => notes
            )
        end

    end

    it "should have 100 users" do
        User.count.should == 100
    end

    it "should have 100 exhibits" do
        Exhibit.count.should == 100
    end

    describe Test0 do
        it "should retrieve 100 rows" do
            puts Test0.where{}.to_sql
            Test0.count.should == 100
        end
    end
end
