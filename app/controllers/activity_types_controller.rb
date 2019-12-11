class ActivityTypesController < ApplicationController
  before_action :set_activity_type, only: [:show, :edit, :update, :destroy]

  def index
      @activity_types = ActivityType.all
      
  end

  def show 
  end

  def new 
      @activity_type = ActivityType.new
  end

  def edit
  end


  def create
    @activity_type = ActivityType.new(activity_type_params)
    respond_to do |format|
      if @activity_type.save
        format.html { redirect_to activity_types_url, notice: 'Activity Type was successfully created.' }
        format.json { render :show, status: :created, location: @activity_type }
      else
        format.html { render :new }
        format.json { render json: @activity_type.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @activity_type.update(activity_type_params)
        format.html { redirect_to activity_types_url, notice: 'Activity Type was successfully updated.' }
        format.json { render :show, status: :ok, location: @activity_type }
      else
        format.html { render :edit }
        format.json { render json: @activity_type.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @activity_type.destroy
    respond_to do |format|
      format.html { redirect_to activity_types_url, notice: 'Activity Type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_activity_type
    @activity_type = ActivityType.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def activity_type_params
    params.fetch(:activity_type, {}).permit(
      :name,
      :image
    )
  end

end
