resource "oci_core_volume_group" "mushuop_volume_group" {
    #Required
    availability_domain = oci_core_instance.app_instance[count.index].availability_domain
    compartment_id = var.compartment_ocid
    source_details {
        #Required
        type = "volumeIds"
        volume_ids = [oci_core_instance.app_instance[count.index].boot_volume_id]
    }

    display_name = "mushup-volume-group-${count.index}"

    volume_group_replicas {
        #Required
        availability_domain = data.oci_identity_availability_domains.remote_ADs.availability_domains[0].name

        #Optional
        display_name = "mushup-volume-group-replica-${count.index}"
    }

  count = var.num_nodes

}
