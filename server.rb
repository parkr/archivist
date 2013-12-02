require 'sinatra'
require 'json'
require File.expand_path("../lib/archivist.rb", __FILE__)

get '/' do
  "Oh, hai."
end

post '/' do
  push    = JSON.parse(params[:payload])
  tmp_dir = './tmp/project'

  a = Archivist.new(push)

  if a.merge_push?
    a.clone(tmp_dir)
    a.write_merge_to_history
    a.push
  else
    a.logger.info("Not a merge push. Aborting.")
  end
end
