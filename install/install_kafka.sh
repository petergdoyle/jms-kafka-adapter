 #!/bin/sh
 . ../common.sh

java -version > /dev/null 2>&1
if [ $? -eq 127 ]; then
  display_error "Jdk8 is not installed. Install Jdk8"
  exit 1
fi

kafka_base_location=$local_kafka_dir
if [ ! -d $kafka_base_location ]; then
  mkdir -pv $kafka_base_location
fi
kafka_installation_dir="$kafka_base_location/kafka_$scala_version-$kafka_version"
downloadable="kafka_$scala_version-$kafka_version.tgz"
kafka_home=$kafka_base_location/default

if [ ! -d $kafka_installation_dir ]; then
  # install and link
  if [ -L $kafka_home ]; then
    rm -fv $kafka_home
  fi

  kafka_link_file=$kafka_config_dir/$kafka_version/link
  if [ ! -f $kafka_link_file ]; then
    display_error "Cannot find a link file in location $kafka_config_dir/$kafka_version/link. Add a link file that contains the downloadable kafka url specific to $downloadable. Cannot continue"
    exit 1
  fi
  download_url=`cat $kafka_link_file`
  display_info "Verifying url $download_url..."

  if ! `validate_url $download_url`; then
    display_error "Bad url specified as $download_url. Server returned $response_code. Check link. Cannot continue"
    exit 1
  fi

  display_info "Downloading kafka to $kafka_base_location..."
  curl -O $download_url \
  && tar -xvf $downloadable -C $kafka_base_location \
  && rm -f $downloadable

  ln -vs $kafka_installation_dir $kafka_home

  export KAFKA_HOME=$kafka_home
  if ! grep -q KAFKA_HOME ~/.bash_profile; then
    cat >>~/.bash_profile <<-EOF
export KAFKA_HOME=$KAFKA_HOME
export PATH=\$PATH:\$KAFKA_HOME/bin
EOF
  fi
  if [ ! -d $kafka_installation_dir/config/orig ]; then
    display_info "making copy of the original config files..."
    mkdir -pv $kafka_installation_dir/config/orig
    cp -fv $kafka_installation_dir/config/* $kafka_installation_dir/config/orig
  fi

fi

  display_info "Kafka $kafka_version is now installed at $kafka_installation_dir and symlinked at $kafka_base_location/default"

  display_info "Kafka $kafka_version configuration files are located at $kafka_runtime_config_dir"

  display_info "Kafka $kafka_version console logs are located at $kafka_runtime_console_logs_dir"

  display_info "Kafka $kafka_version has been installed. Please source your ~/.bash_profile.sh."
