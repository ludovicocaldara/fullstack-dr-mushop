# Copyright (c) 2019-2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_load_balancer_load_balancer" "remote_mushop_lb" {
  provider = oci.remote_region
  compartment_id = (var.lb_compartment_ocid != "") ? var.lb_compartment_ocid : var.compartment_ocid
  display_name   = "mushop-${random_string.deploy_id.result}"
  shape          = local.lb_shape
  subnet_ids     = [oci_core_subnet.remote_mushop_lb_subnet.id]
  is_private     = "false"
  freeform_tags  = local.common_tags

  dynamic "shape_details" {
    for_each = local.lb_shape == "flexible" ? [1] : []
    content {
      minimum_bandwidth_in_mbps = local.lb_shape_details_minimum_bandwidth_in_mbps
      maximum_bandwidth_in_mbps = local.lb_shape_details_maximum_bandwidth_in_mbps
    }
  }
}

resource "oci_load_balancer_backend_set" "remote_mushop_bes" {
  provider = oci.remote_region
  name             = "mushop-${random_string.deploy_id.result}"
  load_balancer_id = oci_load_balancer_load_balancer.remote_mushop_lb.id
  policy           = "IP_HASH"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/api/health"
    return_code         = 200
    interval_ms         = 5000
    timeout_in_millis   = 2000
    retries             = 10
  }
}

resource "oci_load_balancer_listener" "remote_mushop_listener_80" {
  provider = oci.remote_region
  load_balancer_id         = oci_load_balancer_load_balancer.remote_mushop_lb.id
  default_backend_set_name = oci_load_balancer_backend_set.remote_mushop_bes.name
  name                     = "mushop-${random_string.deploy_id.result}-80"
  port                     = 80
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "30"
  }
}

resource "oci_load_balancer_listener" "remote_mushop_listener_443" {
  provider = oci.remote_region
  load_balancer_id         = oci_load_balancer_load_balancer.remote_mushop_lb.id
  default_backend_set_name = oci_load_balancer_backend_set.remote_mushop_bes.name
  name                     = "mushop-${random_string.deploy_id.result}-443"
  port                     = 443
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = "30"
  }
}
