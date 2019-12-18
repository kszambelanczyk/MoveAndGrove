class AboutContactController < ApplicationController
  layout "application_content"


  def about
    @title = "About"
    @background_class = "about-background"

  end

  def contact
    @title = "Contact"
    @background_class = "contact-background"
  end
end
