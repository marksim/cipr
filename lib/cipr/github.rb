require 'httparty'
require 'git'

module Cipr
  class Repo
    include HTTParty
    base_uri 'https://api.github.com'

    def initialize(repo, options={})
      @repo_user, @repo = repo.split("/")
      @directory = options[:directory]
      @command   = options[:command] || 'rake spec'
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
        next unless pr.mergeable? && !pr.merged?
        pr = pull_request(pr.number)
        if pr.apply ~= /Updating/
          output = run_specs
          pr.comment(output)
          tested += 1
        end
      end
      tested
    end

    def git
      @g ||= @directory ? Git.open(@directory) : Git.clone("https://github.com/#@repo_user/#@repo.git", @repo)
    end

    def apply_pull_request(pr)
      pr = pull_request(pr.respond_to?(:number) ? pr.number : pr)
      git.branch(pr.merge_to).checkout
      git.branch("#{pr.username}-#{pr.merge_from}").checkout
      git.add_remote(pr.username, pr.pull_repo) unless git.remotes.map(&:to_s).include?(pr.username)
      git.pull(pr.username, "#{pr.username}/#{pr.merge_from}", "Merge pull request ##{pr.number} - #{pr.title}")
    end

    def auth_string
      [@auth[:username], @auth[:password]].compact.join(":")
    end

    private

    def run_specs
      git.chdir do
        execute
      end
    end

    def execute
      `#@command > /tmp/test_output.txt`
      File.open("/tmp/test_output.txt").gets
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