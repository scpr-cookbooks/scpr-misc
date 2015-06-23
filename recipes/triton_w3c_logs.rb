dir     = "/scpr/triton_export"
ftp_dir = "/data/ftp/triton"

user = "triton_export"

# Make sure Node is installed
include_recipe "nodejs"

# Install the log exporter utility
nodejs_npm "sm-log-exporter" do
  action :install
  version "0.1.1"
end

# -- create a user -- #

user user do
  action  :create
  system  true
  home    dir
end

# -- create our directory -- #

directory dir do
  action    :create
  owner     user
  mode      0755
  recursive true
end

# -- install our encoding script -- #

template "#{dir}/export_day_log.rb" do
  action  :create
  variables({
    dir:      dir,
    ftp_dir:  ftp_dir,
  })
  mode    0755
  owner   user
end

# -- install a crontab -- #

cron "export-triton-log-day" do
  action  :create
  hour    "3"
  minute  "0"
  user    user
  command "#{dir}/export_day_log.rb > #{dir}/exporter.log 2>&1"
end
