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
  a.clone(tmp_dir)
  a.write_merge_to_history
  a.push
end
