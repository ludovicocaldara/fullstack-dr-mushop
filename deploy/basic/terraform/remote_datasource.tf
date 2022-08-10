# Copyright (c) 2019-2022 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

## Gets a list of Availability Domains
#data "oci_identity_availability_domains" "remote_ADs" {
#  compartment_id = var.tenancy_ocid
#}
#
## Gets ObjectStorage namespace
data "oci_objectstorage_namespace" "remote_user_namespace" {
  provider = oci.remote_region
  compartment_id = var.compartment_ocid
}
#
## Check for resource limits
### Check available compute shape
#data "oci_limits_services" "remote_compute_services" {
#  compartment_id = var.tenancy_ocid
#
#  filter {
#    name   = "name"
#    values = ["compute"]
#  }
#}
#data "oci_limits_limit_definitions" "remote_compute_limit_definitions" {
#  compartment_id = var.tenancy_ocid
#  service_name   = data.oci_limits_services.remote_compute_services.services.0.name
#
#  filter {
#    name   = "description"
#    values = [local.compute_shape_description]
#  }
#}
#data "oci_limits_resource_availability" "remote_compute_resource_availability" {
#  compartment_id      = var.tenancy_ocid
#  limit_name          = data.oci_limits_limit_definitions.remote_compute_limit_definitions.limit_definitions[0].name
#  service_name        = data.oci_limits_services.remote_compute_services.services.0.name
#  availability_domain = data.oci_identity_availability_domains.remote_ADs.availability_domains[count.index].name
#
#  count = length(data.oci_identity_availability_domains.remote_ADs.availability_domains)
#}
#resource "random_shuffle" "remote_compute_ad" {
#  input        = local.remote_compute_available_limit_ad_list
#  result_count = length(local.remote_compute_available_limit_ad_list)
#}
#locals {
#  remote_compute_multiplier_nodes_ocpus  = local.is_flexible_instance_shape ? (var.num_nodes * var.instance_ocpus) : var.num_nodes
#  remote_compute_available_limit_ad_list = [for limit in data.oci_limits_resource_availability.remote_compute_resource_availability : limit.availability_domain if(limit.available - local.remote_compute_multiplier_nodes_ocpus) >= 0]
#  remote_compute_available_limit_check = length(local.remote_compute_available_limit_ad_list) == 0 ? (
#  file("ERROR: No limits available for the chosen compute shape and number of nodes or OCPUs")) : 0
#}
#
## Available Services
data "oci_core_services" "remote_all_services" {
  provider = oci.remote_region
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}
