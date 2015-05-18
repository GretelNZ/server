class StoriesController < ApplicationController

  def index
    stories = Story.where(completed: false).order(updated_at: :desc).limit(10)
    render json: stories.to_json(
      :methods => [:contributions_length, :last_contribution],
      :only => [:id, :contribution_limit, :title],
      :include => [:location => { :only => [:lat, :lng] }]
    ), status: 200
  end

  def completed
    stories = Story.where(completed: true)
    render json: stories.to_json(
      :methods => [:first_contribution],
      :only => [:id, :title],
      :include => [:location => { :only => [:lat, :lng] }]
    ), status: 200

  end

  def nearby
    lat = params[:search][:lat]
    lng = params[:search][:lng]
    coordinates = [lat, lng]
    range = params[:search].fetch(:range, 5)
    @nearby_stories = Story.joins(:location).within(range, :origin => coordinates)
    render json: @nearby_stories.to_json(
      :methods => [:contribution_length],
      :only => [:id, :title, :contribution_limit, :completed],
      :include => [:location => { :only => [:lat, :lng] }]
    ), status: 200
  end

  def in_range
    story = Story.find(params[:story_id])
    lat = params[:search][:lat]
    lng = params[:search][:lng]
    coordinates = [lat, lng]
    range = params[:search].fetch(:range, 0.5)
    @nearby_stories = Story.joins(:location).within(range, :origin => coordinates)
    render status: 200, json: {
      in_range: @nearby_stories.include?(story)
    }
  end

  def create
    new_story = Story.new(title: story_params[:title], contribution_limit: story_params[:contribution_limit])
    new_location = Location.new(lat: story_params[:lat], lng: story_params[:lng])
    if new_story.save
      new_story.location = new_location
      render status: 200, json: {
        story: new_story,
      }
    else
      render status: 400, json: {
        message: "Your request was not successful."
      }
    end
  end


  def show
    story = Story.find(params[:id])
    all_contributions = story.contributions
    last_contribution = story.contributions.last
    if story.completed
      render json: story.to_json(
        :methods => [:all_contributions, :contributions_length],
        :only => [:id, :title, :completed, :contribution_limit],
        :include => [:location => { :only => [:lat, :lng] }]
      )
    else
      render json: story.to_json(
        :methods => [:last_contribution, :contributions_length],
        :only => [:id, :title, :completed, :contribution_limit],
        :include => [:location => { :only => [:lat, :lng] }]
      )
    end
  end

  private

  def story_params
    params.require(:story).permit(:title, :contribution_limit, :lat, :lng)
  end
end
