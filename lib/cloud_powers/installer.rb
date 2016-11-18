require 'json'

module Smash
  module CloudPowers
    module Installer

      def load_installer_config(filename) 
        data = File.read(filename)
        json = JSON.parse(data) 
        json
      end

      def start_config(filename, config = '.config.json')
        json = load_installer_config (config)
        puts "Starting Cerebrum configuration, please press enter if you want to leave a config empty."
        json.each do |x|
          puts x['QUESTION']
          x['VALUE'] = gets.chomp
          if x['VALUE'].empty?
            x['VALUE'] = x['DEFAULT']
          end
        end
        save(filename, json)
        puts to_s(json)
      end

      #Helpfull to string
      def to_s(json)
        output = ""
        json.each {|key,value| output += " #{key}=#{value} \n" }
        output
      end

      #Save the properties back to file
      def save(filename, json)
        File.open(filename, "w+") do |f|
          json.each do |x|
            if x['NEW_LINE']
              f.puts ""
            end
            unless x['COMMENT'].empty?
              f.puts "# #{x['COMMENT']}"
            end
            f.puts "#{x['VAR_NAME']}=#{x['VALUE']}"
          end
        end
      end

    end
  end
end
