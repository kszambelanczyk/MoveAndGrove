module ActivitiesHelper

  def show_svg(path)
    File.open(Rails.public_path.to_s + path, "rb") do |file|
      raw file.read
    end
  end

end
