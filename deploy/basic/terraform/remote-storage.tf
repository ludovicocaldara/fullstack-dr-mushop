# Copyright (c) 2019-2021 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

resource "oci_objectstorage_bucket" "remote_mushop" {
  provider = oci.remote_region
  compartment_id = var.ociCompartmentOcid
  name           = "mushop-${var.resId}"
  namespace      = data.oci_objectstorage_namespace.remote_user_namespace.namespace
  freeform_tags  = local.common_tags
  kms_key_id     = null
  depends_on     = [oci_identity_policy.mushop_basic_policies]
}


### UNCOMMENT THOSE TWO WHEN ATP CREATED
resource "oci_objectstorage_object" "remote_mushop_wallet" {
  provider = oci.remote_region
  bucket    = oci_objectstorage_bucket.remote_mushop.name
  content   = oci_database_autonomous_database_wallet.autonomous_database_wallet.content
  namespace = data.oci_objectstorage_namespace.remote_user_namespace.namespace
  object    = "mushop_atp_wallet"
}

resource "oci_objectstorage_preauthrequest" "remote_mushop_wallet_preauth" {
  provider = oci.remote_region
  access_type  = "ObjectRead"
  bucket       = oci_objectstorage_bucket.remote_mushop.name
  name         = "mushop_wallet_preauth"
  namespace    = data.oci_objectstorage_namespace.remote_user_namespace.namespace
  time_expires = timeadd(timestamp(), "30m")
  object_name  = oci_objectstorage_object.remote_mushop_wallet.object
}

resource "oci_objectstorage_object" "remote_mushop_basic" {
  provider = oci.remote_region
  bucket    = oci_objectstorage_bucket.remote_mushop.name
  source    = "./scripts/mushop-basic.tar.xz"
  namespace = data.oci_objectstorage_namespace.remote_user_namespace.namespace
  object    = "mushop_basic"
}
resource "oci_objectstorage_preauthrequest" "remote_mushop_lite_preauth" {
  provider = oci.remote_region
  access_type  = "ObjectRead"
  bucket       = oci_objectstorage_bucket.remote_mushop.name
  name         = "mushop_lite_preauth"
  namespace    = data.oci_objectstorage_namespace.remote_user_namespace.namespace
  time_expires = timeadd(timestamp(), "30m")
  object_name  = oci_objectstorage_object.remote_mushop_basic.object
}

resource "oci_objectstorage_object" "remote_mushop_media_pars_list" {
  provider = oci.remote_region
  bucket    = oci_objectstorage_bucket.remote_mushop.name
  content   = local.remote_mushop_media_pars_list
  namespace = data.oci_objectstorage_namespace.remote_user_namespace.namespace
  object    = "mushop_media_pars_list.txt"
}
resource "oci_objectstorage_preauthrequest" "remote_mushop_media_pars_list_preauth" {
  provider = oci.remote_region
  access_type  = "ObjectRead"
  bucket       = oci_objectstorage_bucket.remote_mushop.name
  name         = "mushop_media_pars_list_preauth"
  namespace    = data.oci_objectstorage_namespace.remote_user_namespace.namespace
  time_expires = timeadd(timestamp(), "30m")
  object_name  = oci_objectstorage_object.remote_mushop_media_pars_list.object
}

# Static assets bucket
resource "oci_objectstorage_bucket" "remote_mushop_media" {
  provider = oci.remote_region
  compartment_id = (var.object_storage_mushop_media_compartment_ocid != "") ? var.object_storage_mushop_media_compartment_ocid : var.ociCompartmentOcid
  name           = "mushop-media-${var.resId}"
  namespace      = data.oci_objectstorage_namespace.remote_user_namespace.namespace
  freeform_tags  = local.common_tags
  access_type    = (var.object_storage_mushop_media_visibility == "Private") ? "NoPublicAccess" : "ObjectReadWithoutList"
  kms_key_id     = null
}

# Static product media
resource "oci_objectstorage_object" "remote_mushop_media" {
  provider = oci.remote_region
  for_each = fileset("./images", "**")

  bucket        = oci_objectstorage_bucket.remote_mushop_media.name
  namespace     = oci_objectstorage_bucket.remote_mushop_media.namespace
  object        = each.value
  source        = "./images/${each.value}"
  content_type  = "image/png"
  cache_control = "max-age=604800, public, no-transform"
}

# Static product media pars for Private (Load to catalogue service)
resource "oci_objectstorage_preauthrequest" "remote_mushop_media_pars_preauth" {
  provider = oci.remote_region
  for_each = oci_objectstorage_object.remote_mushop_media

  bucket       = oci_objectstorage_bucket.remote_mushop_media.name
  namespace    = oci_objectstorage_bucket.remote_mushop_media.namespace
  object_name  = each.value.object
  name         = "mushop_media_pars_par"
  access_type  = "ObjectRead"
  time_expires = timeadd(timestamp(), "30m")
}
locals {
  remote_mushop_media_pars = join(",", [for media in oci_objectstorage_preauthrequest.remote_mushop_media_pars_preauth :
  "https://objectstorage.${var.remote_region}.oraclecloud.com${media.access_uri}"])
}
