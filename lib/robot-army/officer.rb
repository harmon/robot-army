class RobotArmy::Officer < RobotArmy::Soldier
  def run(command, data)
    case command
    when :eval
      debug "officer delegating eval command for user=#{data[:user].inspect}"
      RobotArmy::Connection.localhost(data[:user], data[:password]) do |local|
        local.post(:command => command, :data => data)
        
        loop do
          # we want to stay in this loop as long as we 
          # have proxy requests coming back from our child
          response = local.get
          case response[:status]
          when 'proxy'
            # forward proxy requests on to our parent
            messenger.post(response)
            # and send the response back to our child
            local.post(messenger.get)
          else
            return RobotArmy::Connection.handle_response(response)
          end
        end
      end
    when :exit
      super
    else
      super
    end
  end
end
