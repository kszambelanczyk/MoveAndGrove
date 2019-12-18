class ActivitiesController < ApplicationController
  layout "application_content"

  before_action :authenticate_user!

  before_action :set_activity, only: [:show, :edit, :update, :destroy]

  # GET /activities
  # GET /activities.json
  def index

    # default show activities starting two months ago
    from_date = Time.now - 2.months
    to_date = Time.now + 2.months

    if(params.has_key?(:start_date))
      from_date = Time.parse(params[:start_date]) - 3.months
      to_date = Time.parse(params[:start_date]) + 3.months
    end

    @activities = Activity.includes(:activity_type).where("user_id=? and start>=? and start<=?", current_user.id, from_date, to_date)

    total_duration = Activity.where("user_id=?", current_user.id).group(:user_id).sum(:duration)[1]
    
    @total_hours = 0
    @total_minutes = 0
    if !total_duration.nil?
      @total_hours = total_duration / 60
      @total_minutes = total_duration % 60
    end

    #total calories
    sql = <<-SQL
      SELECT
        activities.user_id,
        SUM(activities.duration*activity_types.calories_factor) as calories
      FROM activities
      JOIN activity_types ON
        activities.activity_type_id = activity_types.id
      WHERE activities.user_id=#{ActiveRecord::Base.connection.quote(current_user.id)}
      GROUP BY activities.user_id
    SQL
    first = Activity.find_by_sql(sql).first
    @total_calories = first.nil? ? 0 : first.calories

    # favorite activity calculated as activity type with longest duration
    favorite = ActivityType.select('activity_types.id, activity_types.name')
                  .left_joins(:activities)
                  .where("activities.user_id=?", current_user.id)
                  .group('activity_types.id')
                  .sum('activities.duration')

    sql = <<-SQL
      SELECT
        activity_types.id,
        activity_types.name,
        SUM(activities.duration) as duration
      FROM activity_types
      JOIN activities ON
        activities.activity_type_id = activity_types.id
      WHERE activities.user_id=#{ActiveRecord::Base.connection.quote(current_user.id)}
      GROUP BY activity_types.id
      ORDER BY duration DESC
    SQL
    first = ActivityType.find_by_sql(sql).first
    @favorite_activity_type = first.nil? ? "-" : first.name




    # duration per day for last 30 days
    if Rails.env.production?
      sql = <<-SQL
        SELECT
          date_trunc('day', start) "start_date",
          SUM(duration) as duration
        FROM activities
        WHERE user_id=#{ActiveRecord::Base.connection.quote(current_user.id)} 
          AND start<=#{ActiveRecord::Base.connection.quote(Time.now)}
          AND start>=#{ActiveRecord::Base.connection.quote(Time.now - 31.days)}
        GROUP BY 1
      SQL
    else
      sql = <<-SQL
        SELECT
          SUM(duration) as duration,
          date(start) as start_date
        FROM activities
        WHERE user_id=#{ActiveRecord::Base.connection.quote(current_user.id)}
          AND start<=#{ActiveRecord::Base.connection.quote(Time.now)}
          AND start>=#{ActiveRecord::Base.connection.quote(Time.now - 31.days)}
      GROUP BY date(start)
      SQL
    end
    data = Activity.find_by_sql(sql).index_by { |t| t.start_date }

    @minutes_data = {}
    (0..30).each { |i|
      i = 30 - i
      day = (Time.now - i.days).to_date
      count = 0
      if !data[day.strftime("%F")].nil?
        count = data[day.strftime("%F")][:duration]
      end
      @minutes_data[day.strftime("%b %d")] = count
    }

    # calories per day for last 30 days
    if Rails.env.production?
      sql = <<-SQL
        SELECT
          date_trunc('day', start) "start_date",
          SUM(duration) as duration
        FROM activities
        WHERE user_id=#{ActiveRecord::Base.connection.quote(current_user.id)}
          AND start<=#{ActiveRecord::Base.connection.quote(Time.now)}
          AND start>=#{ActiveRecord::Base.connection.quote(Time.now - 31.days)}
        GROUP BY 1
      SQL
    else
      sql = <<-SQL
        SELECT
          SUM(activities.duration*activity_types.calories_factor) as calories,
          date(start) as start_date
        FROM activities
        JOIN activity_types ON
          activities.activity_type_id = activity_types.id
        WHERE activities.user_id=#{ActiveRecord::Base.connection.quote(current_user.id)}
          AND start<=#{ActiveRecord::Base.connection.quote(Time.now)}
          AND start>=#{ActiveRecord::Base.connection.quote(Time.now - 31.days)}
        GROUP BY date(activities.start)
      SQL
    end

    data = Activity.find_by_sql(sql).index_by { |t| t.start_date }
    @calories_data = {}
    (0..30).each { |i|
      i = 30 - i
      day = (Time.now - i.days).to_date
      count = 0
      if !data[day.strftime("%F")].nil?
        count = data[day.strftime("%F")][:calories]
      end
      @calories_data[day.strftime("%b %d")] = count
    }

  end

  # GET /activities/1
  # GET /activities/1.json
  def show
  end

  # GET /activities/new
  def new
    @activity = Activity.new

    @activity.start = Time.now

  end

  # GET /activities/1/edit
  def edit
  end

  # POST /activities
  # POST /activities.json
  def create
    @activity = Activity.new(activity_params)
    @activity.user = current_user

    respond_to do |format|
      if @activity.save
        format.html { redirect_to activities_path, notice: 'Activity was successfully created.' }
        format.json { render :show, status: :created, location: @activity }
      else
        format.html { render :new }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /activities/1
  # PATCH/PUT /activities/1.json
  def update
    respond_to do |format|
      if @activity.update(activity_params)
        format.html { redirect_to activities_path, notice: 'Activity was successfully updated.' }
        format.json { render :show, status: :ok, location: @activity }
      else
        format.html { render :edit }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1
  # DELETE /activities/1.json
  def destroy
    @activity.destroy
    respond_to do |format|
      format.html { redirect_to activities_url, notice: 'Activity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_activity
      @activity = Activity.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def activity_params
      params.fetch(:activity, {}).permit(
        :name,
        :start,
        :duration,
        :activity_type_id
      )
    end
end
