# Copyright (c) 2019-2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# creates an ATP database
## ATP Instance
resource "oci_database_autonomous_database" "remote_mushop_autonomous_database" {
  provider = oci.remote_region

  #admin_password           = random_string.autonomous_database_admin_password.result

  compartment_id           = var.ociCompartmentOcid
  db_name                  = "${var.autonomous_database_name}${var.resId}"
  source =  "CROSS_REGION_DATAGUARD"
  source_id = oci_database_autonomous_database.mushop_autonomous_database.id
  display_name             = "${var.autonomous_database_name}-${var.resId}"
  freeform_tags            = local.common_tags
  is_free_tier             = local.autonomous_database_is_free_tier
  license_model            = var.autonomous_database_license_model
  nsg_ids                  = (var.autonomous_database_visibility == "Private") ? [oci_core_network_security_group.remote_atp_nsg[0].id] : []
  subnet_id                = (var.autonomous_database_visibility == "Private") ? oci_core_subnet.remote_mushop_main_subnet.id : ""
}

