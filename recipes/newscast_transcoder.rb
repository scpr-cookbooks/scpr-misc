dir = "/scpr/newscast"

# -- create a user -- #

user "newscast" do
  action  :create
  system  true
  home    dir
end

# -- create our directory -- #

directory dir do
  action    :create
  owner     "newscast"
  mode      0755
  recursive true
end

# -- mount the media dir -- #

include_recipe "nfs"
scpr_tools_media_mount "#{dir}/media" do
  action      :create
  remote_path "/volume1/media"
end

# -- install our encoding script -- #

template "#{dir}/transcode.rb" do
  action  :create
  variables({
    dir:  dir,
    wav:  "#{dir}/media/audio/newscast/18931111_kpccnewscast.wav",
  })
  mode    0755
  owner   "newscast"
end

# -- install a crontab -- #

cron "newscast-transcode" do
  action  :create
  minute  "*/15"
  user    "newscast"
  command "#{dir}/transcode.rb > #{dir}/transcoder.log 2>&1"
end
