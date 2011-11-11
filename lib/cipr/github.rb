require 'httparty'
require 'git'

module Cipr
  class Repo
    include HTTParty
    base_uri 'https://api.github.com'

    def initialize(repo, options={})
      @repo_user, @repo = repo.split("/")
      @directory = options[:directory]
      @prep      = options[:prep]    || 'bundle && rake db:migrate'
      @command   = options[:command] || 'bundle exec rake spec'
      @auth      = {:username => options[:user] || @repo_user, :password => options[:password]}.reject {|k,v| v.nil?}
    end

    def pull_requests(state=:open)
      get("/repos/#@repo_user/#@repo/pulls", :query => {:state => state}).map {|p| PullRequest.new(self, p)}
    end

    def pull_request(id)
      PullRequest.new(self, get("/repos/#@repo_user/#@repo/pulls/#{id}"))
    end

    def comment(issue_id, body)
      post("/repos/#@repo_user/#@repo/issues/#{issue_id}/comments", :body => {'body' => body}.to_json)
    end

    def test
      tested = 0
      pull_requests.each do |pr|
        pr = pull_request(pr.number)
        next if pr.merged?

        ready = false
        if pr.mergeable?
          puts "Applying Pull Request ##{pr.number}"
          ready = (pr.apply =~ /(Already|CONFLICT)/).nil?
        else
          puts "Checking out Pull Request ##{pr.number}"
          pr.checkout
          ready = true
        end

        if ready
          puts "Testing Pull Request ##{pr.number}"
          output = execute
          unless output.nil? || output.strip.empty?
            pr.comment(output) 
            tested += 1
          end
        end
      end
      puts "Tested #{tested} pull requests this round..."
      tested
    end

    def git
      @g ||= @directory ? Git.open(@directory) : Git.clone("https://github.com/#@repo_user/#@repo.git", @repo)
    end

    def apply_pull_request(pr)
      pr = pull_request(pr.respond_to?(:number) ? pr.number : pr)
      git.branch(pr.merge_to).checkout
      git.pull("origin", pr.merge_to)
      git.branch("#{pr.username}-#{pr.merge_from}").checkout
      git.add_remote(pr.username, pr.pull_repo) unless git.remotes.map(&:to_s).include?(pr.username)
      git.pull(pr.username, "#{pr.username}/#{pr.merge_from}", "Merge pull request ##{pr.number} - #{pr.title.gsub(/"/, '\"')}")
    end

    def checkout_pull_request(pr)
      pr = pull_request(pr.respond_to?(:number) ? pr.number : pr)
      git.add_remote(pr.username, pr.pull_repo) unless git.remotes.map(&:to_s).include?(pr.username)
      git.branch("#{pr.username}/#{pr.merge_from}").checkout
    end

    def auth_string
      [@auth[:username], @auth[:password]].compact.join(":")
    end

    private

    def execute
      puts @prep
      `/bin/bash -l -c 'cd #{git.dir} && #{@prep}'`
      puts @command
      `/bin/bash -l -c 'cd #{git.dir} && #{@command} > /tmp/test_output.txt'`
      split_comment(File.open("/tmp/test_output.txt").read)
    end

    def split_comment(comment, line_length=200)
      comment.split("\n").map do |l|
        p = []
        while l.length > line_length
          p << l[0..(line_length-1)]
          l = l[line_length..-1]
        end
        p << l
        p.join("\n")
      end.join("\n")
    end


    def get(path, options={})
      options.merge!(:basic_auth => @auth)
      self.class.get(path, options)
    end

    def post(path, options={})
      options.merge!(:basic_auth => @auth)
      self.class.post(path, @auth.merge(options))
    end

    def put(path, options={})
      options.merge!(:basic_auth => @auth)
      self.class.put(path, @auth.merge(options))
    end
  end
end