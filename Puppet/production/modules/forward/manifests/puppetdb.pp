# Setup PuppetDB on master
#
# @param firewall
# Specify to configure the firewall.
#
# @param report
# Enable reports in PuppetDB.
#
# @param reportprocessor
# Enable reportprocessor in PuppetDB.
#
class forward::puppetdb (
  Boolean $firewall         = false,
  Boolean $report          = true,
  Boolean $reportprocessor  = true,
  ) {
  #Install PuppetDB on Master
  class { 'puppetdb':
    manage_firewall => $firewall,
  }

  #Configure PuppetDB on Master
  class { 'puppetdb::master::config':
    manage_report_processor => $report,
    enable_reports          => $reportprocessor,
  }
}
