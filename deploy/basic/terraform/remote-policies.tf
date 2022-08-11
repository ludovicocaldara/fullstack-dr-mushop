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
  depends_on = [oci_identity_policy.mushop_basic_policies, oci_objectstorage_object.remote_mushop_wallet]
}
