class GithubClientService

  def initialize
    @client = ::Octokit::Client.new(access_token: ENV['GITHUB_DOTME_ACCESS_TOKEN'])
  end

  def get_repo(repo_name)
    r = @client.repo(ENV['GITHUB_USERNAME'] + "/#{repo_name}")
    r.long_description = get_long_description(r.full_name)
    r.language_percentages = get_language_percentages(r.full_name)
    r
  end

  private

  def get_language_percentages(repo_name)
    langs = @client.languages(repo_name).to_h
    total_bytes = langs.values.sum
    langs.each do |key, val|
      langs[key] = (val.to_f/total_bytes * 100).round(0).to_s
    end
    langs
  end 

  def get_long_description(repo_name)
    @client.contents(repo_name, path: ENV['GITHUB_PROJECT_DESCRIPTION_PATH']).content.unpack('m*')[0]
  rescue Octokit::NotFound
    return
  end
end
