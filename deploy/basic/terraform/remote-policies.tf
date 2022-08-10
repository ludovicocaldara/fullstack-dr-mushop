# Copyright (c) 2019, 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

# Create lifecycle policy to delete temp files
resource "oci_objectstorage_object_lifecycle_policy" "remote_mushop_deploy_assets_lifecycle_policy" {
  provider = oci.remote_region
  namespace = data.oci_objectstorage_namespace.remote_user_namespace.namespace
  bucket    = oci_objectstorage_bucket.remote_mushop.name

  rules {
    action      = "DELETE"
    is_enabled  = "true"
    name        = "mushop-delete-deploy-assets-rule"
    time_amount = "1"
    time_unit   = "DAYS"
  }
  ## REVERT BACK WHEN ATP ADDED
  # depends_on = [oci_identity_policy.mushop_basic_policies, oci_objectstorage_object.remote_mushop_wallet]
  depends_on = [oci_identity_policy.mushop_basic_policies]
}

## Create policies for MuShop based on the features
#resource "oci_identity_policy" "remote_mushop_basic_policies" {
#  name           = "mushop-basic-policies-${random_string.deploy_id.result}"
#  description    = "Policies created by terraform for MuShop Basic"
#  compartment_id = var.compartment_ocid
#  statements     = local.mushop_basic_policies_statement
#  freeform_tags  = local.common_tags
#
#  provider = oci.home_region
#}
