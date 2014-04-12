# -*- encoding : utf-8 -*-\n\n

require 'net/http'
require 'uri'
require 'json'

debug = false

uri = URI.parse("http://fhem:8083/fhem?cmd=jsonlist%20CUL_HM&XHR=1")

heating = {
  'wz_Thermostat_Weather' => {
    :last     => 0,
    :current  => 0,
    :desired  => 0,
    :valve    => 0,
    :humidity => 0,
  },
  'wz_Heizung1_Clima' => {
    :last     => 0,
    :current  => 0,
    :desired  => 0,
    :valve    => 0,
  },
  'wz_Heizung2_Clima' => {
    :last     => 0,
    :current  => 0,
    :desired  => 0,
    :valve    => 0,
  },
  'ki_Heizung1_Clima' => {
    :last     => 0,
    :current  => 0,
    :desired  => 0,
    :valve    => 0,
  },
  'sz_Heizung1_Clima' => {
    :last     => 0,
    :current  => 0,
    :desired  => 0,
    :valve    => 0,
  }
}

windows = ['wz_Balkontuer', 'ku_Balkontuer','bad2_dachfenster' ]

SCHEDULER.every '15s' do
  response = Net::HTTP.get_response(uri)

  results = JSON.parse(response.body, symbolize_names: true)[:Results]

  results.each do |result|
    if heating.has_key?(result[:name])
      puts "#{result[:name]} is #{result[:state]}" if debug

      what = result[:name]
      states = Hash[result[:state].split(/ /).each_slice(2).to_a]

      heating[what][:last] = heating[what][:current]
      heating[what][:current] = states['T:']
      heating[what][:valve] = states['valve:'] || false
      heating[what][:desired] = states['desired:'] || false
      heating[what][:last_humidity] = heating[what][:humidity].to_i - 10 if heating[what][:humidity]
      heating[what][:humidity] = states['H:'] || false

      send_event(result[:name], current: heating[what][:current], last: heating[what][:last], suffix: '˚C')
      send_event("#{result[:name]}_valve", value: heating[what][:valve]) if heating[what][:valve]
      send_event("#{result[:name]}_humidity", current: heating[what][:humidity], last: heating[what][:last_humidity], suffix: '%') if heating[what][:humidity]

      p heating if debug
    elsif windows.include?(result[:name])
      puts "#{result[:name]} is: #{result[:state]}" if debug
      if result[:state] == 'open'
        send_event(result[:name], text: 'Offen', status: 'warning')
      elsif result[:state] == 'tilted'
        send_event(result[:name], text: 'Gekippt', status: 'danger')
      else
        send_event(result[:name], text: 'Geschlossen', status: 'ok')
      end
    end
  end

end
