#!/usr/bin/env ruby
# Encoding: utf-8
#
# Copyright:: Copyright 2016, Google Inc. All Rights Reserved.
#
# License:: Licensed under the Apache License, Version 2.0 (the "License");
#           you may not use this file except in compliance with the License.
#           You may obtain a copy of the License at
#
#           http://www.apache.org/licenses/LICENSE-2.0
#
#           Unless required by applicable law or agreed to in writing, software
#           distributed under the License is distributed on an "AS IS" BASIS,
#           WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#           implied.
#           See the License for the specific language governing permissions and
#           limitations under the License.
#
# This example inserts an offline conversion attributed to a mobile device ID.

require_relative '../dfareporting_utils'
require 'date'

def insert_offline_mobile_conversion(profile_id, mobile_device_id,
    floodlight_activity_id)
  # Authenticate and initialize API service.
  service = DfareportingUtils.get_service()

  # Look up the Floodlight configuration ID based on activity ID.
  floodlight_activity = service.get_floodlight_activity(profile_id,
      floodlight_activity_id)
  floodlight_config_id = floodlight_activity.floodlight_configuration_id

  current_time_in_micros = DateTime.now.strftime('%Q').to_i * 1000

  # Construct the conversion.
  conversion = DfareportingUtils::API_NAMESPACE::Conversion.new({
    :floodlight_activity_id => floodlight_activity_id,
    :floodlight_configuration_id => floodlight_config_id,
    :ordinal => current_time_in_micros,
    :mobile_device_id => mobile_device_id,
    :timestamp_micros => current_time_in_micros
  })

  # Construct the batch insert request.
  batch_insert_request =
      DfareportingUtils::API_NAMESPACE::ConversionsBatchInsertRequest.new({
        :conversions => [conversion]
      })

  # Insert the conversion.
  result = service.batchinsert_conversion(profile_id, batch_insert_request)

  unless result.has_failures
    puts 'Successfully inserted conversion for mobile device ID %s.' %
        mobile_device_id
  else
    puts 'Error(s) inserting conversion for mobile device ID %s.' %
        mobile_device_id

    status = result.status[0]
    status.errors.each do |error|
      puts "\t[%s]: %s" % [error.code, error.message]
    end
  end
end

if __FILE__ == $0
  # Retrieve command line arguments.
  args = DfareportingUtils.get_arguments(ARGV, :profile_id, :mobile_device_id,
      :floodlight_activity_id)

  insert_offline_mobile_conversion(args[:profile_id], args[:mobile_device_id],
      args[:floodlight_activity_id])
end
