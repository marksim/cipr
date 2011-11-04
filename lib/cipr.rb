require 'cipr/version'

module Cipr
  class Server
    def self.go(url, options={})
      while true
        # Check pull requests
        # if new pull requests
        # => Clone repo
        # => Apply patch
        # => rake spec > output.txt
        # => Add comment
      end
    end
  end
end