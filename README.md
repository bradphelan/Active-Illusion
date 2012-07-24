Inherit from this class to create tableless models that are backed by a query. Behaves
a little like a classic SQL view.

For example

    class Award < ActiveRecord::Base
     has_many :award_type_view
    end

    class AwardTypeView < ActiveRecord::Illusion
     column :award_type, :string
     column :award_id, :integer

     belongs_to :award

     view do
       Award.select{
           [awards.type.as(award_type), awards.id.as(award_id)]
       }
     end

    end

The cool thing is, is that the relations work on both directions

a = AwardTypeView.first

      SELECT "award_type_views".* FROM 
      (SELECT "awards"."type" AS award_type, "awards"."id" AS award_id FROM awards ) 
      award_type_views LIMIT 1

a.award

       SELECT "awards".* FROM "awards" WHERE "awards"."id" = 1 LIMIT 1

b = Award.first

       SELECT "awards".* FROM "awards" LIMIT 1

b.award_type_views

       SELECT "award_type_views".* FROM 
       (SELECT "awards"."type" AS award_type, "awards"."id" AS award_id FROM awards ) 
       award_type_views 
       WHERE "award_type_views"."award_id" = 1

Currently this gem depends on the SQUEEL SQL gem

For a more detailed example see: http://stackoverflow.com/questions/6900508/how-to-create-read-only-models-in-rails-with-no-backing-table
