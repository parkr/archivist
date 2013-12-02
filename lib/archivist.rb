require 'git'
require 'logger'
require 'octokit'

class Archivist

  LOG_LEVELS = {
    'debug' => Logger::DEBUG,
    'info'  => Logger::INFO,
    'warn'  => Logger::WARN,
    'error' => Logger::ERROR,
    'fatal' => Logger::FATAL
  }

  attr_reader :payload, :git

  def initialize(push_info)
    @payload = push_info
    logger.debug("New Archivist instantiated with the following payload: #{payload}")
    fail_if_not_merge_commit
  end

  def clone(dir)
    FileUtils.rm_rf   dir
    FileUtils.mkdir_p dir
    logger.info "Cloning #{payload["repository"]["url"]} into #{dir} ..."
    @git = Git.clone(clone_url, dir)
  end

  def write_merge_to_history
    set_configs
    message, pr_num = extract_merge_info
    write_to_history_file(section, message, pr_num)
    git.commit_all("Update history to reflect merge of ##{pr_num}.")
  rescue Git::GitExecuteError => e
    logger.error e.message
  end

  def push
    git.push
  end

  def username
    ENV.fetch('GH_USER', '')
  end

  def password
    ENV.fetch('GH_TOKEN', '')
  end

  def merge_push?
    !latest_commit["message"].match(/Merge pull request #\d+/).nil?
  end

  private

  def latest_commit
    payload["commits"].first
  end

  def fail_if_not_merge_commit
    unless merge_push?
      logger.fatal "This is not a merge commit. Aborting."
      abort
    end
  end

  def clone_url
    url = "#{payload["repository"]["url"]}.git"
    url["https://"] = "https://#{username}:#{password}@"
    url
  end

  def set_configs
    git.config('user.name',  'Archivist')
    git.config('user.email', 'archivist@parkermoo.re')
  end

  def extract_merge_info
    pr_num = latest_commit["message"].match(/Merge pull request #(\d+)/)[1]
    logger.debug("#extract_merge_info")
    [
      pr_title(pr_num),
      pr_num
    ]
  end

  def pr_title(pr_num)
    JSON.parse(pr_info(pr_num))["title"]
  end

  def pr_info(pr_num)
    repo = Octokit::Repository.from_url(payload["repository"]["url"])
    client = Octokit::Client.new
    client.pull_request(repo, pr_num)
  end

  def history_filename
    ENV.fetch('ARCHIVIST_HISTFILE', 'History.markdown')
  end

  def write_to_history_file(section, message, pr_num)
    Dir.chdir(git.working_directory) do
      raise NotImplementedError
      history = File.read(history_filename)
      # 1. Find section
      history[/## HEAD\n\n(.*)### #{section}/]
      # 2. Append newlines plus item to end of section line
      # 3. Write to History file
      File.open(history_filename, 'w'){ |f| f.write(history) }
    end
  end

  def logger
    @logger ||= Logger.new(STDOUT)
    @logger.level = log_level
    @logger
  end

  def log_level
    level = ENV.fetch('LOG_LEVEL', 'info')
    LOG_LEVELS[level] || LOG_LEVELS['info']
  end
end
