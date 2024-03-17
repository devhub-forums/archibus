class ::DiscordBot::Bot

    @@DiscordBot = nil

    def self.init
        @@DiscordBot = Discordrb::Commands::CommandBot.new token: SiteSetting.archibus_token, prefix: "??"

        admin_channel_id = SiteSetting.archibus_admin_channel_id
        @@DiscordBot.ready do |event|
            puts "Logged in as #{@@DiscordBot.profile.username} (ID: #{@@DiscordBot.profile.id})"
            @@DiscordBot.send_message(admin_channel_id, "I have awoken from my slumber and am ready to monitor the forums.")
        end

        @@DiscordBot
    end

    def self.run_bot
        bot = self.init

        unless bot.nil?
            ::DiscordBot.DiscourseEventsHandlers.hook_events
            bot.include!(::DiscordBot::DiscordEventsHandlers::TransmitAnnouncement)
            
        end
    end
end