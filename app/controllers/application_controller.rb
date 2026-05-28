class ApplicationController < ActionController::Base
  include ActionPolicy::Controller

  authorize :user, through: :current_user

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActionPolicy::Unauthorized do |_ex|
    redirect_to root_path, alert: "You don't have access to that."
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
