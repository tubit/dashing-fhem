# -*- encoding : utf-8 -*-\n\n

require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("http://fhem:8083/fhem?cmd=jsonlist%20CUL_HM&XHR=1")

heating = {
  'wz_Heizung1_Weather' => {
    :last     => 0,
    :current  => 0,
  },
  'wz_Heizung2_Weather' => {
    :last     => 0,
    :current  => 0,
  },
  'ki_Heizung1_Weather' => {
    :last     => 0,
    :current  => 0,
  },
  'sz_Heizung1_Weather' => {
    :last     => 0,
    :current  => 0,
  }
}


SCHEDULER.every '3s' do
  response = Net::HTTP.get_response(uri)

  results = JSON.parse(response.body, symbolize_names: true)[:Results]

  results.each do |result|
    case result[:name]
    when 'bad2_dachfenster' then
      puts "Badezimmerfenster: #{result[:state]}"
      if result[:state] == 'open'
        send_event('bad2_dachfenster', text: "Offen", status: 'warning')
      else
        send_event('bad2_dachfenster', text: "Geschlossen")
      end
    else 
      if heating.has_key?(result[:name])
        puts "#{result[:name]} is #{result[:state]} C"

        what = result[:name]
        heating[what][:last] = heating[what][:current]
        heating[what][:current] = result[:state]

        send_event(result[:name], current: heating[what][:current], last: heating[what][:last], suffix: "˚C")

        p heating
      end
    end
  end

end
