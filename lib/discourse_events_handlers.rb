module ::DiscordBot::DiscourseEventsHandlers
    def self.hook_events
        DiscourseEvent.on(:post_created) do |post|
            if post.id > 0 && post.topic.archetype != "private_message" && !::DiscordBot::Bot.archibus.nil? then
                post_listening_categories = SiteSetting.archibus_post_announcement_categories.split('|')
                topic_listening_categories = SiteSetting.archibus_topic_announcement_categories.split('|')
                posted_category = post.topic.category.id
                posted_category_name = Category.find_by(id: posted_category).name

                if post_listening_categories.include?(posted_category.to_s) then
                    message = "Woah! A new post has been created in the category [#{posted_category_name}](#{post.url}) by [#{post.user.username}](#{post.user.url})."
                    ::DiscordBot::Bot.archibus.send_message(SiteSetting.archibus_announcement_channel_id, message)
                else
                    if topic_listening_categories.include?(posted_category.to_s) then
                        message = "Woah! A new topic has been created in the category [#{posted_category_name}](#{post.url}) by [#{post.user.username}](#{post.user.url})."
                        ::DiscordBot::Bot.archibus.send_message(SiteSetting.archibus_announcement_channel_id, message)
                    end
                end
            end
        end
    end
end