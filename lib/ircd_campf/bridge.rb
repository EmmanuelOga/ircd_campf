module IRCDCampf
  class Bridge < Struct.new(:ircd, :domain, :token)

    def initialize(ircd, url, token)
      super
      ircd.logger.debug("Initializing connection to: #{ url }")
      @fire_conn = Firering::Connection.new(url) do |c|
        c.token = token
        c.max_retries = 10_000
        c.retry_delay = 5
      end
    end

    def start
      ircd.logger.debug("Authenticating...")
      @fire_conn.authenticate do |fire_user|

        ircd.logger.debug("Retrieving rooms...")
        @fire_conn.rooms do |fire_rooms|

          ircd.logger.debug("Creating room...")
          fire_rooms.each do |fire_room|

            Room.new(ircd, @fire_conn, fire_user, fire_room).start unless fire_room.locked?
          end
        end
      end
    end

    class Room < Struct.new(:ircd, :fire_conn, :fire_user, :fire_room)

      def initialize(*args)
        super

        room_name = "##{fire_room.name.gsub(/ /, "_")}"
        topic = "#{fire_room.name}: #{fire_room.topic.blank? ? "No Topic" : fire_room.topic}"

        ircd.logger.debug("New room: #{room_name}. Topic: #{ topic }")

        @chan = ircd.channels[room_name]
        @chan.release_if_empty = false
        @chan.change_topic(topic)

        @irc_client = ircd_client_from_user(fire_user, :ircd_client)
      end

      CLIENTS = Hash.new

      def ircd_client_from_user(cuser, procedence_token = :external_campfire_user)
        return CLIENTS[cuser.id] if CLIENTS[cuser.id] # TODO Change nick if appropriate

        client = IRCDSlim::Client.new(nil, cuser.id, "80", "", cuser.name, "#{fire_conn.subdomain}.campfirenow.com")

        client.data[:ircd_campf_procedence_token] = procedence_token

        nick = cuser.name.gsub(/[^A-Za-z0-9\-_]/, "")
        nick = cuser.id if nick.blank? || ircd.clients.unavailable_nickname?(nick, client)

        client.nick = nick

        @chan.subscribe(client)

        CLIENTS[cuser.id] = client
      end

      def start
        pull_from_fire_conn; push_to_fire_conn
      end

      def pull_from_fire_conn
        fire_room.stream do |message|
          if message.user_id != fire_user.id

            case
            when message.text? || message.paste?
              irc_speak(message)

            # TODO handle different events
            when message.system?
            when message.sound?
            when message.advertisement?
            when message.allow_guests?
            when message.disallow_guests?
            when message.idle?
            when message.kick?
            when message.leave?
            when message.timestamp?
            when message.topic_change?
            when message.unidle?
            when message.unlock?
            when message.upload?
            end

          end
        end
      rescue => e
        ircd.logger.debug("Error while pulling messages from #{fire_conn.subdomain}.")
      end

      def push_to_fire_conn
        @chan.watch(:only => [:priv_msg, :notice]) do |ircd_message|

          ircd.logger.debug("Detected input from: #{ircd_message.client.nick}. Authorized user is: #{@irc_client.nick}")
          if ircd_message.client.data[:ircd_campf_procedence_token] != :external_campfire_user # do not re-post messages from external users.

            ircd_message.body.each_line do |text|
              ircd.logger.debug("Posting new message to campfire...")
              fire_room.text(text) do |message| # TODO handle other kind of messages (e.g. trombone)
                ircd.logger.debug("Posted message #{message.id}.")
              end
            end

          end
        end
      end

      def irc_speak(fire_message)
        if fire_message.from_user?
          ircd.logger.debug("Received new message from campfire...")

          fire_message.user do |fire_message_user|
            fire_message.body.split(/\r?\n/).each do |line|
              @chan.priv_msg(ircd_client_from_user(fire_message_user), line)
            end
          end
        else
          # Do nothing.
        end
      end
    end

  end
end
