require_relative 'cipr/version'
require_relative 'cipr/github'
require_relative 'cipr/pull_request'

module Cipr
  class Server
    def self.go(repo, options={})
      wait_time = 1
      c = Cipr::Repo.new(repo, options)
      while true
        puts "Checking for Pull Requests..."
        if c.test > 0
          wait_time = 2
        else
          wait_time += 2 if wait_time < 30
        end
        sleep 60*wait_time
      end
    end
  end
end