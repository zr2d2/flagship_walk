require 'sinatra'
require 'httparty'

helpers do
  def get_obsticles(first, last)
    params = {
      query: {
        "lat1" => first[:lat],
        "lng1" => first[:lng],
        "lat2" => last[:lat],
        "lng2" => last[:lng]
      }
    }

    api_url = 'http://sidewalk.umiacs.umd.edu/v1/access/features'

    response = HTTParty.get api_url, params

    json = JSON.parse response.body, symbolize_names: true

    return json[:features]
  end
end

get '/' do
  erb :index
end

get '/directions' do

  key = ENV['GMAPS_KEY']

  from = params['from']

  to = params['to']

  params = {
    query: {
      origin: from,
      destination: to,
      mode: 'walking',
      alternatives: 'true',
      key: key,
      avoid: 'indoor'
    }
  }

  api_url = 'https://maps.googleapis.com/maps/api/directions/json'

  response = HTTParty.get(api_url, params)

  json = JSON.parse response.body, symbolize_names: true

  routes = Hash.new

  json[:routes].each_with_index do |route, i|
    features = Hash.new 0

    route[:legs].each do |leg|
      leg[:steps].each do |step|
        step_start = step[:start_location]
        step_end   = step[:end_location]

        obstacles = get_obsticles(step_start, step_end)

        obstacles.each do |obstacle|
          label = obstacle[:properties][:label_type]

          features[label] += 1
        end
      end
    end

    routes[i] = features["NoCurbRamp"] + features["Obstacle"] + features["SurfaceProblem"]
  end

  best_route_id = routes.to_a.sort{ |x, y| x.last <=> y.last }.first.first

  best_route_text = json[:routes][best_route_id][:summary]

  @text = "You're best to use #{best_route_text}"

  erb :directions
end