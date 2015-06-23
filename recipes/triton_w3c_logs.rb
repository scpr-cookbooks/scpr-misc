dir     = "/scpr/triton_export"
ftp_dir = "/data/ftp/triton"

user = "pureftpd"

# Make sure Node is installed
include_recipe "nodejs"

# Install the log exporter utility
nodejs_npm "sm-log-exporter" do
  action :install
  version "0.1.1"
end


# -- install our encoding script -- #

script_path = "/usr/local/bin/scpr_export_day_log.rb"
template script_path do
  action  :create
  source  "export_day_log.rb.erb"
  variables({
    ftp_dir:  ftp_dir,
  })
  mode    0755
  owner   user
end

# -- install a crontab -- #

log_file = "/var/log/scpr_export_day_log.log"

cron "export-triton-log-day" do
  action  :create
  hour    "3"
  minute  "0"
  user    user
  command "#{script_path} > #{log_file} 2>&1"
end

# -- touch the log file it will write -- #

file log_file do
  action  :create_if_missing
  user    user
  mode    0644
end