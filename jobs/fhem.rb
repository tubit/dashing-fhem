require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("http://fhem:8083/fhem?cmd=jsonlist%20CUL_HM&XHR=1")

points = Hash.new()
last_x = Hash.new()
points[:kinderzimmer] = []
(1..10).each do |i|
  points[:kinderzimmer] << { x: i, y: 0 }
end
last_x[:kinderzimmer] = points[:kinderzimmer].last[:x]


SCHEDULER.every '3s' do
  response = Net::HTTP.get_response(uri)

  results = JSON.parse(response.body, symbolize_names: true)[:Results]

  results.each do |result|
    case result[:name]
    when 'bad2_dachfenster' then
      puts "Badezimmerfenster: #{result[:state]}"
      if result[:state] == 'open'
        send_event('bad2_dachfenster', text: "Offen")
      else
        send_event('bad2_dachfenster', text: "Geschlossen")
      end
    when 'ki_Heizung1_Weather' then
      points[:kinderzimmer].shift
      last_x[:kinderzimmer] += 1
      points[:kinderzimmer] << { x: last_x[:kinderzimmer], y: result[:state] }

      puts "Kinderzimmer ist #{result[:state]} C"
      send_event('ki_heizung1', points: points[:kinderzimmer])

    end
  end

end
