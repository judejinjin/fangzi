class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :"N"ull_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale

  helper_method :current_user, :signed_in?, :owner?, :all_neighborhoods, :all_apt_types, :all_addresses

  @all_neighborhoods = nil
  @all_apt_types = nil

  def set_locale
    locale = params[:locale].to_s.strip.to_sym
    I18n.locale = I18n.available_locales.include?(locale) ?  locale : I18n.default_locale
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  def current_user
    return nil if session[:session_token].nil?

    @current_user ||= User.find_by_session_token(session[:session_token])
  end

  def signed_in?
    return false if !current_user

    true
  end

  def owner?(property)
    return false if !current_user

    return false if current_user.id != property.owner_id.to_i

    true
  end

  def login(user)
    @current_user = user
    session[:session_token] = user.session_token
  end

  def logout
    current_user.reset_session_token
    session[:session_token] = nil
  end

  def require_signed_in
    if !signed_in?
      flash[:errors] = ["Please sign in."]
      redirect_to new_session_url
    end
  end

  def require_signed_out
    if signed_in?
      flash[:errors] = ["You are already signed in."]
      redirect_to root_url
    end
  end

  def require_owner
    if current_user.id == params[:user_id]
      flash[:errors] = ["You do not the owner of this listing."]
      redirect_to root_url
    end
  end

  def all_neighborhoods
    @all_neighborhoods ||= Property.all.uniq.pluck(:neighborhood).map(&:strip).reject.sort.map do |entry|
      entry.split(" ").map(&:capitalize).join(" ")
    end

    @all_neighborhoods = @all_neighborhoods.uniq
  end

  def all_apt_types
    @all_apt_types ||= Property.all.uniq.pluck(:apt_type).map(&:strip).map(&:capitalize).reject.sort
    @all_apt_types = @all_apt_types.uniq

  end

  def all_addresses
    @all_addresses ||= Property.all.uniq.pluck(:address).map(&:strip).map(&:capitalize).reject.sort
    @all_addresses = @all_addresses.uniq
  end






  def all_subway_stations
    stations
  end


  def get_closest_subway_stations(lat, lng)
    #length of a degree of latitude in miles: ~69 miles
    #length of a degree of longitude in miles at 40.64 lat: ~52.56
    #1 mile for latitude = 1 / 69 = .0145 degrees = y
    #1 mile for longitude = 1 / 52.56 = .0190 degrees = x
    output_hash = Hash.new { |h, k| h[k] = [] }

    stations = [{station_name:"25th St",latitude:40.660397,longitude:-73.998091,route_1:"R",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"36th St",latitude:40.655144,longitude:-74.003549,route_1:"N",route_2:"R",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"45th St",latitude:40.648939,longitude:-74.010006,route_1:"R",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"53rd St",latitude:40.645069,longitude:-74.014034,route_1:"R",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"59th St",latitude:40.641362,longitude:-74.017881,route_1:"N",route_2:"R",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"77th St",latitude:40.629742,longitude:-74.02551,route_1:"R",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"86th St",latitude:40.622687,longitude:-74.028398,route_1:"R",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"95th St",latitude:40.616622,longitude:-74.030876,route_1:"R",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"9th St",latitude:40.670847,longitude:-73.988302,route_1:"F",route_2:"G",route_3:"R",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Bay Ridge Av",latitude:40.634967,longitude:-74.023377,route_1:"R",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"DeKalb Av",latitude:40.690635,longitude:-73.981824,route_1:"B",route_2:"Q",route_3:"R",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Pacific St",latitude:40.683666,longitude:-73.97881,route_1:"B",route_2:"Q",route_3:"D",route_4:"N",route_5:"R",route_6:"2",route_7:"3",route_8:"4",route_9:"5",route_10:"",route_11:""},
    {station_name:"Prospect Av",latitude:40.665414,longitude:-73.992872,route_1:"R",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Union St",latitude:40.677316,longitude:-73.98311,route_1:"R",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"30 Av-Grand Av",latitude:40.766779,longitude:-73.921479,route_1:"N",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"36 Av-Washington Av",latitude:40.756804,longitude:-73.929575,route_1:"N",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"39 Av-Beebe Av",latitude:40.752882,longitude:-73.932755,route_1:"N",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Astoria Blvd-Hoyt Av",latitude:40.770258,longitude:-73.917843,route_1:"N",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Broadway",latitude:40.76182,longitude:-73.925508,route_1:"N",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Ditmars Blvd",latitude:40.775036,longitude:-73.912034,route_1:"N",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"7th Av",latitude:40.67705,longitude:-73.972367,route_1:"B",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Av H",latitude:40.62927,longitude:-73.961639,route_1:"B",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Av J",latitude:40.625039,longitude:-73.960803,route_1:"B",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Av M",latitude:40.617618,longitude:-73.959399,route_1:"B",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Av U",latitude:40.5993,longitude:-73.955929,route_1:"B",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Beverly Rd",latitude:40.644031,longitude:-73.964492,route_1:"B",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Brighton Beach",latitude:40.577621,longitude:-73.961376,route_1:"B",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Church Av",latitude:40.650527,longitude:-73.962982,route_1:"B",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Cortelyou Rd",latitude:40.640927,longitude:-73.963891,route_1:"B",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Kings Highway",latitude:40.60867,longitude:-73.957734,route_1:"B",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Neck Rd",latitude:40.595246,longitude:-73.955161,route_1:"B",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Newkirk Av",latitude:40.635082,longitude:-73.962793,route_1:"B",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Ocean Parkway",latitude:40.576312,longitude:-73.968501,route_1:"Q",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Parkside Av",latitude:40.655292,longitude:-73.961495,route_1:"B",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Prospect Park",latitude:40.661614,longitude:-73.962246,route_1:"B",route_2:"Q",route_3:"F",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Sheepshead Bay",latitude:40.586896,longitude:-73.954155,route_1:"B",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Stillwell Av",latitude:40.577422,longitude:-73.981233,route_1:"D",route_2:"F",route_3:"N",route_4:"Q",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"West 8th St",latitude:40.576127,longitude:-73.975939,route_1:"F",route_2:"Q",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"23rd St - Broadway",latitude:40.741303,longitude:-73.989344,route_1:"N",route_2:"R",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"28th St - Broadway",latitude:40.745494,longitude:-73.988691,route_1:"N",route_2:"R",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"49th St",latitude:40.759901,longitude:-73.984139,route_1:"N",route_2:"Q",route_3:"R",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"57th St",latitude:40.764664,longitude:-73.980658,route_1:"N",route_2:"Q",route_3:"R",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"5th Av",latitude:40.764811,longitude:-73.973347,route_1:"N",route_2:"Q",route_3:"R",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"8th St",latitude:40.730328,longitude:-73.992629,route_1:"N",route_2:"R",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"City Hall",latitude:40.713282,longitude:-74.006978,route_1:"R",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Cortlandt St",latitude:40.710668,longitude:-74.011029,route_1:"R",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Court St",latitude:40.6941,longitude:-73.991777,route_1:"R",route_2:"2",route_3:"3",route_4:"4",route_5:"5",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Lawrence St",latitude:40.69218,longitude:-73.985942,route_1:"A",route_2:"C",route_3:"F",route_4:"R",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Lexington Av",latitude:40.76266,longitude:-73.967258,route_1:"N",route_2:"Q",route_3:"R",route_4:"4",route_5:"5",route_6:"6",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Prince St",latitude:40.724329,longitude:-73.997702,route_1:"N",route_2:"R",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Rector St",latitude:40.70722,longitude:-74.013342,route_1:"R",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Times Square-42nd St",latitude:40.754672,longitude:-73.986754,route_1:"A",route_2:"C",route_3:"E",route_4:"N",route_5:"Q",route_6:"R",route_7:"S",route_8:"1",route_9:"2",route_10:"3",route_11:"7"},
    {station_name:"Whitehall St",latitude:40.703087,longitude:-74.012994,route_1:"R",route_2:"1",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"104th St-102nd St",latitude:40.695178,longitude:-73.84433,route_1:"J",route_2:"Z",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"111th St",latitude:40.697418,longitude:-73.836345,route_1:"J",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"121st St",latitude:40.700492,longitude:-73.828294,route_1:"J",route_2:"Z",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Alabama Av",latitude:40.676992,longitude:-73.898654,route_1:"J",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Chauncey St",latitude:40.682893,longitude:-73.910456,route_1:"J",route_2:"Z",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Cleveland St",latitude:40.679947,longitude:-73.884639,route_1:"J",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Crescent St",latitude:40.683194,longitude:-73.873785,route_1:"J",route_2:"Z",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Cypress Hills",latitude:40.689941,longitude:-73.87255,route_1:"J",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Elderts Lane-75th St",latitude:40.691324,longitude:-73.867139,route_1:"J",route_2:"Z",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Flushing Av",latitude:40.70026,longitude:-73.941126,route_1:"J",route_2:"M",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Forest Parkway-85th St",latitude:40.692435,longitude:-73.86001,route_1:"J",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Gates Av",latitude:40.68963,longitude:-73.92227,route_1:"J",route_2:"Z",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Halsey St",latitude:40.68637,longitude:-73.916559,route_1:"J",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Hewes St",latitude:40.70687,longitude:-73.953431,route_1:"J",route_2:"M",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Kosciusko St",latitude:40.693342,longitude:-73.928814,route_1:"J",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Lorimer St",latitude:40.703869,longitude:-73.947408,route_1:"J",route_2:"M",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Marcy Av",latitude:40.708359,longitude:-73.957757,route_1:"J",route_2:"M",route_3:"Z",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Myrtle Av",latitude:40.697207,longitude:-73.935657,route_1:"J",route_2:"M",route_3:"Z",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Norwood Av",latitude:40.68141,longitude:-73.880039,route_1:"J",route_2:"Z",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Van Siclen Av",latitude:40.678024,longitude:-73.891688,route_1:"J",route_2:"Z",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Woodhaven Blvd",latitude:40.693879,longitude:-73.851576,route_1:"J",route_2:"Z",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"1st Av",latitude:40.730953,longitude:-73.981628,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"3rd Av",latitude:40.732849,longitude:-73.986122,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"6th Av",latitude:40.737335,longitude:-73.996786,route_1:"F",route_2:"L",route_3:"M",route_4:"1",route_5:"2",route_6:"3",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"8th Av",latitude:40.739777,longitude:-74.002578,route_1:"A",route_2:"C",route_3:"E",route_4:"L",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Atlantic Av",latitude:40.675345,longitude:-73.903097,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Bedford Av",latitude:40.717304,longitude:-73.956872,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Bushwick Av",latitude:40.682829,longitude:-73.905249,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Canarsie - Rockaway Parkway",latitude:40.646654,longitude:-73.90185,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"DeKalb Av",latitude:40.703811,longitude:-73.918425,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"East 105th St",latitude:40.650573,longitude:-73.899485,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Graham Av",latitude:40.714565,longitude:-73.944053,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Grand St",latitude:40.711926,longitude:-73.94067,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Halsey St",latitude:40.695602,longitude:-73.904084,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Jefferson St",latitude:40.706607,longitude:-73.922913,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Livonia Av",latitude:40.664038,longitude:-73.900571,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Lorimer St",latitude:40.714063,longitude:-73.950275,route_1:"G",route_2:"L",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Montrose Av",latitude:40.707739,longitude:-73.93985,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Morgan Av",latitude:40.706152,longitude:-73.933147,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Myrtle Av",latitude:40.699814,longitude:-73.911586,route_1:"L",route_2:"M",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"New Lots Av",latitude:40.658733,longitude:-73.899232,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Sutter Av",latitude:40.669367,longitude:-73.901975,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Wilson Av",latitude:40.688764,longitude:-73.904046,route_1:"L",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Botanic Gardens",latitude:40.670343,longitude:-73.959245,route_1:"S",route_2:"2",route_3:"3",route_4:"4",route_5:"5",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Franklin Av",latitude:40.680596,longitude:-73.955827,route_1:"A",route_2:"S",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Park Place",latitude:40.674772,longitude:-73.957624,route_1:"S",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Central Av",latitude:40.697857,longitude:-73.927397,route_1:"M",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Forest Av",latitude:40.704423,longitude:-73.903077,route_1:"M",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Fresh Pond Rd",latitude:40.706186,longitude:-73.895877,route_1:"M",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Knickerbocker Av",latitude:40.698664,longitude:-73.919711,route_1:"M",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Metropolitan Av",latitude:40.711396,longitude:-73.889601,route_1:"M",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Seneca Av",latitude:40.702762,longitude:-73.90774,route_1:"M",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Bowery",latitude:40.72028,longitude:-73.993915,route_1:"J",route_2:"Z",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Broad St",latitude:40.706476,longitude:-74.011056,route_1:"J",route_2:"Z",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Chambers St",latitude:40.713243,longitude:-74.003401,route_1:"J",route_2:"Z",route_3:"4",route_4:"5",route_5:"6",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Essex St",latitude:40.718315,longitude:-73.987437,route_1:"F",route_2:"J",route_3:"M",route_4:"Z",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"18th Av",latitude:40.620671,longitude:-73.990414,route_1:"N",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"20th Av",latitude:40.61741,longitude:-73.985026,route_1:"N",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"86th St",latitude:40.592721,longitude:-73.97823,route_1:"N",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"8th Av",latitude:40.635064,longitude:-74.011719,route_1:"N",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Av U",latitude:40.597473,longitude:-73.979137,route_1:"N",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Bay Parkway-22nd Av",latitude:40.611815,longitude:-73.981848,route_1:"N",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Fort Hamilton Parkway",latitude:40.631386,longitude:-74.005351,route_1:"N",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Kings Highway",latitude:40.603923,longitude:-73.980353,route_1:"N",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"New Utrecht Av",latitude:40.624842,longitude:-73.996353,route_1:"D",route_2:"N",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"18th Av",latitude:40.607954,longitude:-74.001736,route_1:"D",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"20th Av",latitude:40.604556,longitude:-73.998168,route_1:"D",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"25th Av",latitude:40.597704,longitude:-73.986829,route_1:"D",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"50th St",latitude:40.63626,longitude:-73.994791,route_1:"D",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"55th St",latitude:40.631435,longitude:-73.995476,route_1:"D",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"62nd St",latitude:40.626472,longitude:-73.996895,route_1:"D",route_2:"N",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"71st St",latitude:40.619589,longitude:-73.998864,route_1:"D",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"79th St",latitude:40.613501,longitude:-74.00061,route_1:"D",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"9th Av",latitude:40.646292,longitude:-73.994324,route_1:"D",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Bay 50th St",latitude:40.588841,longitude:-73.983765,route_1:"D",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Bay Parkway",latitude:40.601875,longitude:-73.993728,route_1:"D",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Fort Hamilton Parkway",latitude:40.640914,longitude:-73.994304,route_1:"D",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"21st St",latitude:40.754203,longitude:-73.942836,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Lexington Av",latitude:40.764627,longitude:-73.96611,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Roosevelt Island",latitude:40.759145,longitude:-73.95326,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"14th St",latitude:40.738228,longitude:-73.996209,route_1:"F",route_2:"L",route_3:"M",route_4:"1",route_5:"2",route_6:"3",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"23rd St - 6th Av",latitude:40.742878,longitude:-73.992821,route_1:"F",route_2:"M",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"2nd Av",latitude:40.723402,longitude:-73.989938,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"34th St - Herald Square",latitude:40.749719,longitude:-73.987823,route_1:"B",route_2:"D",route_3:"F",route_4:"M",route_5:"N",route_6:"Q",route_7:"R",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"42nd St",latitude:40.754222,longitude:-73.984569,route_1:"B",route_2:"D",route_3:"F",route_4:"M",route_5:"7",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"47-50th Sts Rockefeller Center",latitude:40.758663,longitude:-73.981329,route_1:"B",route_2:"D",route_3:"F",route_4:"M",route_5:"7",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"4th Av",latitude:40.670272,longitude:-73.989779,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"57th St",latitude:40.763972,longitude:-73.97745,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"7th Av",latitude:40.666271,longitude:-73.980305,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Bergen St",latitude:40.686145,longitude:-73.990862,route_1:"F",route_2:"G",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Broadway-Lafayette St",latitude:40.725297,longitude:-73.996204,route_1:"B",route_2:"D",route_3:"F",route_4:"M",route_5:"6",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Carroll St",latitude:40.680303,longitude:-73.995048,route_1:"F",route_2:"G",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Church Av",latitude:40.644041,longitude:-73.979678,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Delancey St",latitude:40.718611,longitude:-73.988114,route_1:"F",route_2:"J",route_3:"M",route_4:"Z",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"East Broadway",latitude:40.713715,longitude:-73.990173,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Fort Hamilton Parkway",latitude:40.650782,longitude:-73.975776,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Grand St",latitude:40.718267,longitude:-73.993753,route_1:"B",route_2:"D",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Prospect Park-15 St",latitude:40.660365,longitude:-73.979493,route_1:"S",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Smith-9th St",latitude:40.67358,longitude:-73.995959,route_1:"F",route_2:"G",route_3:"R",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"York St",latitude:40.699743,longitude:-73.986885,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"103rd St",latitude:40.796092,longitude:-73.961454,route_1:"B",route_2:"C",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"116th St",latitude:40.805085,longitude:-73.954882,route_1:"B",route_2:"C",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"125th St",latitude:40.811109,longitude:-73.952343,route_1:"A",route_2:"B",route_3:"C",route_4:"D",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"135th St",latitude:40.817894,longitude:-73.947649,route_1:"B",route_2:"C",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"145th St",latitude:40.824783,longitude:-73.944216,route_1:"A",route_2:"B",route_3:"C",route_4:"D",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"14th St - 8th Av",latitude:40.740893,longitude:-74.00169,route_1:"A",route_2:"C",route_3:"E",route_4:"L",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"155th St",latitude:40.830518,longitude:-73.941514,route_1:"C",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"163rd St - Amsterdam Av",latitude:40.836013,longitude:-73.939892,route_1:"C",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"175th St",latitude:40.847391,longitude:-73.939704,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"181st St",latitude:40.851695,longitude:-73.937969,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"190th St",latitude:40.859022,longitude:-73.93418,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"23rd St - 8th Av",latitude:40.745906,longitude:-73.998041,route_1:"C",route_2:"E",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"34th St - 8th Av",latitude:40.752287,longitude:-73.993391,route_1:"A",route_2:"C",route_3:"E",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"50th St - 8th Av",latitude:40.762456,longitude:-73.985984,route_1:"C",route_2:"E",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"72nd St",latitude:40.775594,longitude:-73.97641,route_1:"B",route_2:"C",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"81st St - Museum of Natural History",latitude:40.781433,longitude:-73.972143,route_1:"B",route_2:"C",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"86th St",latitude:40.785868,longitude:-73.968916,route_1:"B",route_2:"C",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"96th St",latitude:40.791646,longitude:-73.964699,route_1:"B",route_2:"C",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Canal St - Holland Tunnel",latitude:40.720824,longitude:-74.005229,route_1:"A",route_2:"C",route_3:"E",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Cathedral Parkway-110th St",latitude:40.800605,longitude:-73.958158,route_1:"B",route_2:"C",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Chambers St",latitude:40.714111,longitude:-74.008585,route_1:"A",route_2:"C",route_3:"E",route_4:"2",route_5:"3",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Dyckman St-200th St",latitude:40.865491,longitude:-73.927271,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"High St",latitude:40.699337,longitude:-73.990531,route_1:"A",route_2:"C",route_3:"J",route_4:"Z",route_5:"2",route_6:"3",route_7:"4",route_8:"5",route_9:"",route_10:"",route_11:""},
    {station_name:"Inwood - 207th St",latitude:40.868072,longitude:-73.919899,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Spring St",latitude:40.726227,longitude:-74.003739,route_1:"C",route_2:"E",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"West 4th St",latitude:40.732338,longitude:-74.000495,route_1:"A",route_2:"B",route_3:"C",route_4:"D",route_5:"E",route_6:"F",route_7:"M",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"World Trade Center",latitude:40.712582,longitude:-74.009781,route_1:"A",route_2:"C",route_3:"E",route_4:"2",route_5:"3",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Jamaica-Van Wyck",latitude:40.702566,longitude:-73.816859,route_1:"E",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Parsons Blvd-Archer Av - Jamaica Center",latitude:40.702147,longitude:-73.801109,route_1:"E",route_2:"J",route_3:"Z",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Sutphin Blvd-Archer Av - JFK",latitude:40.700486,longitude:-73.807969,route_1:"E",route_2:"J",route_3:"Z",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"155th St",latitude:40.830135,longitude:-73.938209,route_1:"B",route_2:"D",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"167th St",latitude:40.833769,longitude:-73.918432,route_1:"B",route_2:"D",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"170th St",latitude:40.839306,longitude:-73.9134,route_1:"B",route_2:"D",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"174-175th Sts",latitude:40.8459,longitude:-73.910136,route_1:"B",route_2:"D",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"182nd-183rd Sts",latitude:40.856093,longitude:-73.900741,route_1:"B",route_2:"D",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Bedford Park Blvd",latitude:40.873244,longitude:-73.887138,route_1:"B",route_2:"D",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Fordham Rd",latitude:40.861296,longitude:-73.897749,route_1:"B",route_2:"D",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Kingsbridge Rd",latitude:40.866978,longitude:-73.893509,route_1:"B",route_2:"D",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Norwood-205th St",latitude:40.874811,longitude:-73.878855,route_1:"D",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Tremont Av",latitude:40.85041,longitude:-73.905227,route_1:"B",route_2:"D",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Yankee Stadium-161st St",latitude:40.827905,longitude:-73.925651,route_1:"B",route_2:"D",route_3:"4",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"21st St",latitude:40.744065,longitude:-73.949724,route_1:"G",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Bedford-Nostrand Avs",latitude:40.689627,longitude:-73.953522,route_1:"G",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Broadway",latitude:40.706092,longitude:-73.950308,route_1:"G",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Classon Av",latitude:40.688873,longitude:-73.96007,route_1:"G",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Clinton-Washington Avs",latitude:40.688089,longitude:-73.966839,route_1:"G",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Flushing Av",latitude:40.700377,longitude:-73.950234,route_1:"G",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Fulton St",latitude:40.687119,longitude:-73.975375,route_1:"G",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Greenpoint Av",latitude:40.731352,longitude:-73.954449,route_1:"G",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Long Island City-Court Square",latitude:40.746554,longitude:-73.943832,route_1:"G",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Metropolitan Av",latitude:40.712792,longitude:-73.951418,route_1:"G",route_2:"L",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Myrtle-Willoughby Avs",latitude:40.694568,longitude:-73.949046,route_1:"G",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Nassau Av",latitude:40.724635,longitude:-73.951277,route_1:"G",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"18th Av",latitude:40.629755,longitude:-73.976971,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Av I",latitude:40.625322,longitude:-73.976127,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Av N",latitude:40.61514,longitude:-73.974197,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Av P",latitude:40.608944,longitude:-73.973022,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Av U",latitude:40.596063,longitude:-73.973357,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Av X",latitude:40.58962,longitude:-73.97425,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Bay Parkway-22nd Av",latitude:40.620769,longitude:-73.975264,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Ditmas Av",latitude:40.636119,longitude:-73.978172,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Kings Highway",latitude:40.603217,longitude:-73.972361,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Neptune Av-Van Siclen",latitude:40.581011,longitude:-73.974574,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Broadway Junction-East New York",latitude:40.678334,longitude:-73.905316,route_1:"A",route_2:"C",route_3:"J",route_4:"L",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Clinton & Washington Avs",latitude:40.683263,longitude:-73.965838,route_1:"C",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Euclid Av",latitude:40.675377,longitude:-73.872106,route_1:"A",route_2:"C",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Franklin Av",latitude:40.68138,longitude:-73.956848,route_1:"A",route_2:"C",route_3:"S",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Hoyt & Schermerhorn",latitude:40.688484,longitude:-73.985001,route_1:"A",route_2:"C",route_3:"G",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Jay St - Borough Hall",latitude:40.692338,longitude:-73.987342,route_1:"A",route_2:"C",route_3:"F",route_4:"R",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Kingston-Throop",latitude:40.679921,longitude:-73.940858,route_1:"A",route_2:"C",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Lafayette Av",latitude:40.686113,longitude:-73.973946,route_1:"C",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Liberty Av",latitude:40.674542,longitude:-73.896548,route_1:"A",route_2:"C",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Nostrand Av",latitude:40.680438,longitude:-73.950426,route_1:"A",route_2:"C",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Ralph Av",latitude:40.678822,longitude:-73.920786,route_1:"A",route_2:"C",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Rockaway Av",latitude:40.67834,longitude:-73.911946,route_1:"A",route_2:"C",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Shepherd Av",latitude:40.67413,longitude:-73.88075,route_1:"A",route_2:"C",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Utica Av",latitude:40.679364,longitude:-73.930729,route_1:"A",route_2:"C",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Van Siclen Av",latitude:40.67271,longitude:-73.890358,route_1:"A",route_2:"C",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"104th St-Oxford Av",latitude:40.681711,longitude:-73.837683,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"111th St-Greenwood Av",latitude:40.684331,longitude:-73.832163,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"80th St-Hudson St",latitude:40.679371,longitude:-73.858992,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"88th St-Boyd Av",latitude:40.679843,longitude:-73.85147,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Grant Av",latitude:40.677044,longitude:-73.86505,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Lefferts Blvd",latitude:40.685951,longitude:-73.825798,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Rockaway Blvd",latitude:40.680429,longitude:-73.843853,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"169th St",latitude:40.71047,longitude:-73.793604,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"23rd St-Ely Av",latitude:40.747846,longitude:-73.946,route_1:"E",route_2:"G",route_3:"M",route_4:"7",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"36th St",latitude:40.752039,longitude:-73.928781,route_1:"M",route_2:"R",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"46th St",latitude:40.756312,longitude:-73.913333,route_1:"M",route_2:"R",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"5th Av-53rd St",latitude:40.760167,longitude:-73.975224,route_1:"E",route_2:"M",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"63rd Drive-Rego Park",latitude:40.729846,longitude:-73.861604,route_1:"M",route_2:"R",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"65th St",latitude:40.749669,longitude:-73.898453,route_1:"M",route_2:"R",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"67th Av",latitude:40.726523,longitude:-73.852719,route_1:"M",route_2:"R",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"75th Av",latitude:40.718331,longitude:-73.837324,route_1:"E",route_2:"F",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"7th Av",latitude:40.762862,longitude:-73.981637,route_1:"B",route_2:"D",route_3:"E",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Briarwood-Van Wyck Blvd",latitude:40.709179,longitude:-73.820574,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Elmhurst Av",latitude:40.742454,longitude:-73.882017,route_1:"M",route_2:"R",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Forest Hills-71st Av",latitude:40.721691,longitude:-73.844521,route_1:"E",route_2:"F",route_3:"M",route_4:"R",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Grand Av-Newtown",latitude:40.737015,longitude:-73.877223,route_1:"M",route_2:"R",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Jackson Heights-Roosevelt Ave",latitude:40.746644,longitude:-73.891338,route_1:"E",route_2:"F",route_3:"M",route_4:"R",route_5:"7",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Jamaica-179th St",latitude:40.712646,longitude:-73.783817,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Kew Gardens-Union Turnpike",latitude:40.714441,longitude:-73.831008,route_1:"E",route_2:"F",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Lexington Av-53rd St",latitude:40.757552,longitude:-73.969055,route_1:"E",route_2:"M",route_3:"6",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Northern Blvd",latitude:40.752885,longitude:-73.906006,route_1:"M",route_2:"R",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Parsons Blvd",latitude:40.707564,longitude:-73.803326,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Queens Plaza",latitude:40.748973,longitude:-73.937243,route_1:"E",route_2:"M",route_3:"R",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Steinway St",latitude:40.756879,longitude:-73.92074,route_1:"M",route_2:"R",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Sutphin Blvd",latitude:40.70546,longitude:-73.810708,route_1:"F",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Woodhaven Blvd",latitude:40.733106,longitude:-73.869229,route_1:"M",route_2:"R",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Aqueduct-North Conduit Av",latitude:40.668234,longitude:-73.834058,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Aqueduct Racetrack",latitude:40.672131,longitude:-73.835812,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Beach 105th St",latitude:40.583209,longitude:-73.827559,route_1:"H",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Beach 25th St",latitude:40.600066,longitude:-73.761353,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Beach 36th St",latitude:40.595398,longitude:-73.768175,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Beach 44th St",latitude:40.592943,longitude:-73.776013,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Beach 60th St",latitude:40.592374,longitude:-73.788522,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Beach 67th St",latitude:40.590927,longitude:-73.796924,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Beach 90th St",latitude:40.588034,longitude:-73.813641,route_1:"H",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Beach 98th St",latitude:40.585307,longitude:-73.820558,route_1:"H",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Broad Channel",latitude:40.608382,longitude:-73.815925,route_1:"A",route_2:"H",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Far Rockaway-Mott Av",latitude:40.603995,longitude:-73.755405,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Howard Beach",latitude:40.660476,longitude:-73.830301,route_1:"A",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Rockaway Park-Beach 116th",latitude:40.580903,longitude:-73.835592,route_1:"H",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"103rd St",latitude:40.799446,longitude:-73.968379,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"116th St-Columbia University",latitude:40.807722,longitude:-73.96411,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"125th St",latitude:40.815581,longitude:-73.958372,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"137th St-City College",latitude:40.822008,longitude:-73.953676,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"145th St",latitude:40.826551,longitude:-73.95036,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"157th St",latitude:40.834041,longitude:-73.94489,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"168th St",latitude:40.840556,longitude:-73.940133,route_1:"A",route_2:"C",route_3:"1",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"181st St",latitude:40.849505,longitude:-73.933596,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"18th St",latitude:40.74104,longitude:-73.997871,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"191st St",latitude:40.855225,longitude:-73.929412,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"207th St",latitude:40.864614,longitude:-73.918819,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"215th St",latitude:40.869444,longitude:-73.915279,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"231st St",latitude:40.878856,longitude:-73.904834,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"238th St",latitude:40.884667,longitude:-73.90087,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"23rd St - 7th Av",latitude:40.744081,longitude:-73.995657,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"28th St - 7th Av",latitude:40.747215,longitude:-73.993365,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"34th St - 7th Av",latitude:40.750373,longitude:-73.991057,route_1:"1",route_2:"2",route_3:"3",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"50th St",latitude:40.761728,longitude:-73.983849,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"59th St-Columbus Circle",latitude:40.768247,longitude:-73.981929,route_1:"A",route_2:"B",route_3:"C",route_4:"D",route_5:"1",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"66th St-Lincoln Center",latitude:40.77344,longitude:-73.982209,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"72nd St",latitude:40.778453,longitude:-73.98197,route_1:"1",route_2:"2",route_3:"3",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"79th St",latitude:40.783934,longitude:-73.979917,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"86th St",latitude:40.788644,longitude:-73.976218,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"96th St",latitude:40.793919,longitude:-73.972323,route_1:"1",route_2:"2",route_3:"3",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Canal St",latitude:40.722854,longitude:-74.006277,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Cathedral Parkway-110th St",latitude:40.803967,longitude:-73.966847,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Chambers St",latitude:40.715478,longitude:-74.009266,route_1:"1",route_2:"2",route_3:"3",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Christopher St",latitude:40.733422,longitude:-74.002906,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Dyckman St",latitude:40.860531,longitude:-73.925536,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Franklin St",latitude:40.719318,longitude:-74.006886,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Houston St",latitude:40.728251,longitude:-74.005367,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Marble Hill-225th St",latitude:40.874561,longitude:-73.909831,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Rector St",latitude:40.707513,longitude:-74.013783,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"South Ferry",latitude:40.702068,longitude:-74.013664,route_1:"R",route_2:"1",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Van Cortlandt Park-242nd St",latitude:40.889248,longitude:-73.898583,route_1:"1",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Clark St",latitude:40.697466,longitude:-73.993086,route_1:"2",route_2:"3",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Park Place",latitude:40.713051,longitude:-74.008811,route_1:"A",route_2:"C",route_3:"E",route_4:"1",route_5:"2",route_6:"3",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Wall St",latitude:40.706821,longitude:-74.0091,route_1:"2",route_2:"3",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Baychester Av",latitude:40.878663,longitude:-73.838591,route_1:"5",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Eastchester-Dyre Av",latitude:40.8883,longitude:-73.830834,route_1:"5",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Gun Hill Rd",latitude:40.869526,longitude:-73.846384,route_1:"5",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Morris Park",latitude:40.854364,longitude:-73.860495,route_1:"5",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Pelham Parkway",latitude:40.858985,longitude:-73.855359,route_1:"5",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Atlantic Av-Barclays Ctr",latitude:40.684359,longitude:-73.977666,route_1:"B",route_2:"D",route_3:"N",route_4:"Q",route_5:"R",route_6:"2",route_7:"3",route_8:"4",route_9:"5",route_10:"",route_11:""},
    {station_name:"Bergen St",latitude:40.680829,longitude:-73.975098,route_1:"2",route_2:"3",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Eastern Parkway-Brooklyn Museum",latitude:40.671987,longitude:-73.964375,route_1:"2",route_2:"3",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Franklin Av",latitude:40.670682,longitude:-73.958131,route_1:"S",route_2:"2",route_3:"3",route_4:"4",route_5:"5",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Grand Army Plaza",latitude:40.675235,longitude:-73.971046,route_1:"2",route_2:"3",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Hoyt St",latitude:40.690545,longitude:-73.985065,route_1:"2",route_2:"3",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Kingston Av",latitude:40.669399,longitude:-73.942161,route_1:"3",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Nevins St",latitude:40.688246,longitude:-73.980492,route_1:"2",route_2:"3",route_3:"4",route_4:"5",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Nostrand Av",latitude:40.669847,longitude:-73.950466,route_1:"3",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Utica Av",latitude:40.668897,longitude:-73.932942,route_1:"3",route_2:"4",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"103rd St",latitude:40.749865,longitude:-73.8627,route_1:"7",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"111th St",latitude:40.75173,longitude:-73.855334,route_1:"7",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"45 Rd-Court House Sq",latitude:40.747023,longitude:-73.945264,route_1:"E",route_2:"G",route_3:"M",route_4:"7",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"82nd St-Jackson Heights",latitude:40.747659,longitude:-73.883697,route_1:"7",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"90th St Elmhurst",latitude:40.748408,longitude:-73.876613,route_1:"7",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Bliss St-46th St",latitude:40.743132,longitude:-73.918435,route_1:"7",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Broadway-74th St",latitude:40.746848,longitude:-73.891394,route_1:"E",route_2:"F",route_3:"M",route_4:"R",route_5:"7",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Fisk Av-69th St",latitude:40.746325,longitude:-73.896403,route_1:"7",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Flushing-Main St",latitude:40.7596,longitude:-73.83003,route_1:"7",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Hunters Point",latitude:40.742216,longitude:-73.948916,route_1:"7",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Junction Blvd",latitude:40.749145,longitude:-73.869527,route_1:"7",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Lincoln Av-52nd St",latitude:40.744149,longitude:-73.912549,route_1:"7",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Lowery St-40th St",latitude:40.743781,longitude:-73.924016,route_1:"7",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Mets - Willets Point",latitude:40.754622,longitude:-73.845625,route_1:"7",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Queensboro Plaza",latitude:40.750582,longitude:-73.940202,route_1:"N",route_2:"Q",route_3:"7",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Rawson St-33rd St",latitude:40.744587,longitude:-73.930997,route_1:"7",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Vernon Blvd-Jackson Av",latitude:40.742626,longitude:-73.953581,route_1:"7",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Woodside Av-61st St",latitude:40.74563,longitude:-73.902984,route_1:"7",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"138th St",latitude:40.813224,longitude:-73.929849,route_1:"4",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"149th St-Grand Concourse",latitude:40.818375,longitude:-73.927351,route_1:"2",route_2:"4",route_3:"5",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"167th St",latitude:40.835537,longitude:-73.9214,route_1:"4",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"170th St",latitude:40.840075,longitude:-73.917791,route_1:"4",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"176th St",latitude:40.84848,longitude:-73.911794,route_1:"4",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"183rd St",latitude:40.858407,longitude:-73.903879,route_1:"4",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Bedford Park Blvd-Lehman College",latitude:40.873412,longitude:-73.890064,route_1:"4",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Burnside Av",latitude:40.853453,longitude:-73.907684,route_1:"4",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Fordham Rd",latitude:40.862803,longitude:-73.901034,route_1:"4",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Kingsbridge Rd",latitude:40.86776,longitude:-73.897174,route_1:"4",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Mosholu Parkway",latitude:40.87975,longitude:-73.884655,route_1:"4",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Mt Eden Av",latitude:40.844434,longitude:-73.914685,route_1:"4",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Woodlawn",latitude:40.886037,longitude:-73.878751,route_1:"4",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Yankee Stadium-161st St",latitude:40.827994,longitude:-73.925831,route_1:"B ",route_2:"D",route_3:"4",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"110th St-Central Park North",latitude:40.799075,longitude:-73.951822,route_1:"2",route_2:"3",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"116th St",latitude:40.802098,longitude:-73.949625,route_1:"2",route_2:"3",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"125th St",latitude:40.807754,longitude:-73.945495,route_1:"2",route_2:"3",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"135th St",latitude:40.814229,longitude:-73.94077,route_1:"2",route_2:"3",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"145th St",latitude:40.820421,longitude:-73.936245,route_1:"3",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Harlem-148th St",latitude:40.82388,longitude:-73.93647,route_1:"3",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"103rd St",latitude:40.7906,longitude:-73.947478,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"110th St",latitude:40.79502,longitude:-73.94425,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"116th St",latitude:40.798629,longitude:-73.941617,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"125th St",latitude:40.804138,longitude:-73.937594,route_1:"4",route_2:"5",route_3:"6",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"14th St-Union Square",latitude:40.734673,longitude:-73.989951,route_1:"L",route_2:"N",route_3:"Q",route_4:"R",route_5:"4",route_6:"5",route_7:"6",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"23rd St",latitude:40.739864,longitude:-73.986599,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"28th St",latitude:40.74307,longitude:-73.984264,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"33rd St",latitude:40.746081,longitude:-73.982076,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"51st St",latitude:40.757107,longitude:-73.97192,route_1:"E",route_2:"M",route_3:"6",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"59th St",latitude:40.762526,longitude:-73.967967,route_1:"N",route_2:"Q",route_3:"R",route_4:"4",route_5:"5",route_6:"6",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"68th St-Hunter College",latitude:40.768141,longitude:-73.96387,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"77th St",latitude:40.77362,longitude:-73.959874,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"86th St",latitude:40.779492,longitude:-73.955589,route_1:"4",route_2:"5",route_3:"6",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"96th St",latitude:40.785672,longitude:-73.95107,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Astor Place",latitude:40.730054,longitude:-73.99107,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Bleecker St",latitude:40.725915,longitude:-73.994659,route_1:"B",route_2:"D",route_3:"F",route_4:"M",route_5:"6",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Borough Hall",latitude:40.692404,longitude:-73.990151,route_1:"R",route_2:"2",route_3:"3",route_4:"4",route_5:"5",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Bowling Green",latitude:40.704817,longitude:-74.014065,route_1:"4",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Brooklyn Bridge-City Hall",latitude:40.713065,longitude:-74.004131,route_1:"J",route_2:"Z",route_3:"4",route_4:"5",route_5:"6",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Canal St",latitude:40.718803,longitude:-74.000193,route_1:"J",route_2:"N",route_3:"Q",route_4:"R",route_5:"Z",route_6:"6",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Fulton St",latitude:40.710368,longitude:-74.009509,route_1:"A",route_2:"C",route_3:"J",route_4:"Z",route_5:"2",route_6:"3",route_7:"4",route_8:"5",route_9:"",route_10:"",route_11:""},
    {station_name:"Grand Central-42nd St",latitude:40.751776,longitude:-73.976848,route_1:"S",route_2:"4",route_3:"5",route_4:"6",route_5:"7",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Spring St",latitude:40.722301,longitude:-73.997141,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Wall St",latitude:40.707557,longitude:-74.011862,route_1:"4",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Junius St",latitude:40.663515,longitude:-73.902447,route_1:"3",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"New Lots Av",latitude:40.666235,longitude:-73.884079,route_1:"3",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Pennsylvania Av",latitude:40.664635,longitude:-73.894895,route_1:"3",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Rockaway Av",latitude:40.662549,longitude:-73.908946,route_1:"3",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Saratoga Av",latitude:40.661453,longitude:-73.916327,route_1:"3",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Sutter Av",latitude:40.664717,longitude:-73.92261,route_1:"3",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Van Siclen Av",latitude:40.665449,longitude:-73.889395,route_1:"3",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Beverly Rd",latitude:40.645098,longitude:-73.948959,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Church Av",latitude:40.650843,longitude:-73.949575,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Flatbush Av-Brooklyn College",latitude:40.632836,longitude:-73.947642,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Newkirk Av",latitude:40.639967,longitude:-73.948411,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"President St",latitude:40.667883,longitude:-73.950683,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Sterling St",latitude:40.662742,longitude:-73.95085,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Winthrop St",latitude:40.656652,longitude:-73.9502,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"138th St-3rd Ave",latitude:40.810476,longitude:-73.926138,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Brook Av",latitude:40.807566,longitude:-73.91924,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Buhre Av",latitude:40.84681,longitude:-73.832569,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Castle Hill Av",latitude:40.834255,longitude:-73.851222,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Cypress Av",latitude:40.805368,longitude:-73.914042,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"East 143rd St-St Mary's St",latitude:40.808719,longitude:-73.907657,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"East 149th St",latitude:40.812118,longitude:-73.904098,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Elder Av",latitude:40.828584,longitude:-73.879159,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Hunts Point Av",latitude:40.820948,longitude:-73.890549,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Longwood Av",latitude:40.816104,longitude:-73.896435,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Middletown Rd",latitude:40.843863,longitude:-73.836322,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Morrison Av-Soundview Av",latitude:40.829521,longitude:-73.874516,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Parkchester-East 177th St",latitude:40.833226,longitude:-73.860816,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Pelham Bay Park",latitude:40.852462,longitude:-73.828121,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"St Lawrence Av",latitude:40.831509,longitude:-73.867618,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Westchester Square-East Tremont Av",latitude:40.839892,longitude:-73.842952,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Whitlock Av",latitude:40.826525,longitude:-73.886283,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Zerega Av",latitude:40.836488,longitude:-73.847036,route_1:"6",route_2:"",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"149th St-3rd Av",latitude:40.816109,longitude:-73.917757,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"174th St",latitude:40.837288,longitude:-73.887734,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"219th St",latitude:40.883895,longitude:-73.862633,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"225th St",latitude:40.888022,longitude:-73.860341,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"233rd St",latitude:40.893193,longitude:-73.857473,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"238th St-Nereid Av",latitude:40.898379,longitude:-73.854376,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Allerton Av",latitude:40.865462,longitude:-73.867352,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Bronx Park East",latitude:40.848828,longitude:-73.868457,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Burke Av",latitude:40.871356,longitude:-73.867164,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"East 180th St",latitude:40.841894,longitude:-73.873488,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"East Tremont Av-West Farms Sq",latitude:40.840295,longitude:-73.880049,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Freeman St",latitude:40.829993,longitude:-73.891865,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Gun Hill Rd",latitude:40.87785,longitude:-73.866256,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Intervale Av",latitude:40.822181,longitude:-73.896736,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Jackson Av",latitude:40.81649,longitude:-73.907807,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Pelham Parkway",latitude:40.857192,longitude:-73.867615,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Prospect Av",latitude:40.819585,longitude:-73.90177,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Simpson St",latitude:40.824073,longitude:-73.893064,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""},
    {station_name:"Wakefield-241st St",latitude:40.903125,longitude:-73.85062,route_1:"2",route_2:"5",route_3:"",route_4:"",route_5:"",route_6:"",route_7:"",route_8:"",route_9:"",route_10:"",route_11:""}]

    stations.each do |station|
      adjusted_y = (station[:latitude] - lat) * 69
      adjusted_x = (station[:longitude] - lng) * 52.6
      distance = Math.sqrt(adjusted_y**2 + adjusted_x**2)
      if distance < 0.5
        (1..11).each do |num|
          if station["route_".concat(num.to_s).to_sym].empty?
            break
          else
            output_hash[station[:station_name]] << [station["route_".concat(num.to_s).to_sym], distance]
          end
        end
      end
    end

    return output_hash
  end




end
