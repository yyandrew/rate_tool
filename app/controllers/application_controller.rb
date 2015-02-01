require "geoip"
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  #before_filter :set_locale
  helper :all
  helper_method :current_user_session, :current_user

  def set_locale
    data_file_path = "#{Rails.root}/GeoIP.dat"
    unless Rails.env.development?
      data_file_path = "#{Rails.root}/public/system/GeoIP.dat"
    end
    remote_ip = request.remote_ip
    if session[remote_ip].nil?
      result = GeoIP.new(data_file_path).country(remote_ip)
      if !result.nil? && ["China", "Hong Kong", "Taiwan", "Macau"].index(result.to_hash[:country_name]).nil?
	session[remote_ip] = "en"
      else
	session[remote_ip] = "zh-CN"
      end
    end
    I18n.locale = session[remote_ip]
  end

  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end

    def require_user
      unless current_user
	flash[:notice] = t("shared.must_login")
	redirect_to new_user_session_url
	return false
      end
    end
    def require_no_user
      if current_user
	flash[:notice] = t("shared.must_login")
	redirect_to :settings
	return false
      end
    end
end
