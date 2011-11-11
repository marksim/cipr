require_relative 'cipr/version'
require_relative 'cipr/github'
require_relative 'cipr/pull_request'

module Cipr
  class Server
    def self.go(repo, options={})
      wait_time = 1
      c = Cipr::Repo.new(repo, options)

      begin
        sleep 1
        while true
          puts "Checking for Pull Requests..."
          restart_on_interrupt = true
          if c.test > 0
            wait_time = 2
          else
            wait_time += 2 if wait_time < 30
          end
          
          sleep 60*wait_time
        end
      rescue Interrupt => i
        if restart_on_interrupt
          restart_on_interrupt = false
          puts "Hit ^C again to quit"
          retry 
        end
      end
    end
  end
end