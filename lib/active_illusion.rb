require 'active_record'
require 'active_support/all'

module ActiveRecord
  # requires the squeel gem
  #
  # https://github.com/ernie/squeel
  # 
  # Inherit from this class to create tableless
  # models that are backed by a query.
  #
  # For example
  #
  # class Award < ActiveRecord::Base
  #   has_many :award_type_view
  # end
  #
  # class AwardTypeView < Illusion
  #   column :award_type, :string
  #   column :award_id, :integer
  #
  #   belongs_to :award
  #
  #   view
  #     select{[awards.type.as(award_type), awards.id.as(award_id)]}.from("awards")
  #   end
  # end
  #
  # The cool thing is, is that the relations work on both directions
  #
  # a = AwardTypeView.first
  #
  #   SELECT "award_type_views".* FROM 
  #   (SELECT "awards"."type" AS award_type, "awards"."id" AS award_id FROM awards ) 
  #   award_type_views LIMIT 1
  #
  # a.award
  #
  #   SELECT "awards".* FROM "awards" WHERE "awards"."id" = 1 LIMIT 1
  #
  # b = Award.first
  #
  #   SELECT "awards".* FROM "awards" LIMIT 1
  #
  # b.award_type_views
  #
  #   SELECT "award_type_views".* FROM 
  #   (SELECT "awards"."type" AS award_type, "awards"."id" AS award_id FROM awards ) 
  #   award_type_views 
  #   WHERE "award_type_views"."award_id" = 1

  # end
  class Illusion < ActiveRecord::Base
    def self.columns() 
      @columns ||= [] 
    end  

    def self.columns_hash()
      @columns_hash ||= {}
    end

    def self.find_all
      raise "please override"
    end

    class << self
      def default_scope_with_wrap
      end
    end

    def self.view
      meta = class << self;self;end
      m = yield
      table = self.to_s.underscore.pluralize
      meta.send :define_method, :default_scope do
        q = m.arel.as table
        select{}.from(q)
      end
    end

    def self.column(name, sql_type = :string, default = nil, null = true)  
      column = ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)  

      columns << column
      columns_hash[name.to_s] = column   
    end  

    self.abstract_class = true

    def self.table_name
      to_s.underscore.pluralize
    end

    def readonly?
      true
    end

  end
end
