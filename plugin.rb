# name: archibus
# about: Simple discord bot to send notifications to our server.
# authors: TheRealToxicDev
# version: 0.0.1
# url: 

libdir = File.join(File.dirname(__FILE__), 'vendor/discordrb/lib')
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

gem 'event_emitter', '0.2.6'
gem 'websocket', '1.2.9'
gem 'websocket-client-simple', '0.3.0'
gem 'opus-ruby', '1.0.1', { require: false }
gem 'netrc', '0.11.0'
gem 'mime-types-data', '3.2019.1009'
gem 'mime-types', '3.3.1'
gem 'domain_name', '0.5.20180417'
gem 'http-cookie', '1.0.3'
gem 'http-accept', '1.7.0', { require: false }
gem 'rest-client', '2.1.0.rc1'

gem 'discordrb', '3.5.0'
gem 'discordrb-webhooks', '3.5.0', { require: false }

enabled_site_setting :archibus_enabled

after_initialize do
    %w[
        ../lib/engine.rb
        ../lib/bot.rb
        ../lib/bot_commands.rb
        ../lib/discourse_events_handlers.rb
        ../lib/discord_events_handlers.rb
    ].each do |path|
        load File.expand_path(path, __FILE__)
    end
    
    def start_thread(db)
        if Discourse.running_in_rack?
            bot_thread = Thread.new do
                begin
                    RailsMultisite::ConnectionManagement.establish_connection(db: db)
                    ::DiscordBot::Bot.run_bot
                    STDERR.puts '----------------------------------------------------'
                    STDERR.puts 'Discord bot has spawned succesfully, awaiting events'
                    STDERR.puts '----------------------------------------------------'
                    STDERR.puts '(-------      If not check logs          ----------)'
                rescue Exception => ex
                    Rails.logger.error("Archibus bot failed to start: #{ex}")
                end
            end
        end
    end

    db_threads = []
    RailsMultisite::ConnectionManagement.each_connection do
        next unless SiteSetting.archibus_enabled && ! SiteSetting.archibus_token.empty?
        db = RailsMultisite::ConnectionManagement.current_db
        db_threads[db] = start_thread(db)
    end

    DiscourseEvent.on(:site_setting_changed) do |name|
        if ['archibus_enabled', 'archibus_token'].include? (name)
            db = RailsMultisite::ConnectionManagement.current_db
            if db_threads.has_key?(db)
                db_threads[db].kill
            end
            db_threads[db] = start_thread(db)
        end
    end
end