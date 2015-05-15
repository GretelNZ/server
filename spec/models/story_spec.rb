require 'rails_helper'

RSpec.describe Story, type: :model do

	before(:each) do
		akl = FactoryGirl.create(:auckland)
		@welly = FactoryGirl.create(:wellington)
		nelly = FactoryGirl.create(:nelson)
		@akl_story = Story.create(location: akl)
		@welly_story = Story.create(location: @welly)
		@nelly_story = Story.create(location: nelly)
	end

	it "Stories can be created and sorted by location" do
		expect(Location.farthest(origin: @welly_story.location).first).to eq(@akl_story.location)
  	end

	it "Stories can searched by nearby" do
		expect(Location.within(10, origin: @welly_story.location).first).to eq(@nelly_story.location)
  	end  	

  	after(:each) do
  		Story.destroy_all
  		Location.destroy_all
  	end 


end
