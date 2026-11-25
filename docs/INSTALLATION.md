# Installation and recovery status

This checkpoint is for source and build bring-up. A recovery ZIP and physical boot record are pending. Kernel and DT outputs are engineering artifacts.

For a future device session, record the model, current firmware build, recovery version, partition names, recovery device identifier and current ability to restore a model-matching backup. Copy the recovery backup and important data off the device. Use separate, validated recovery packages for `kltetmo` and `kltevzw`. A generic `klte` label in recovery needs independent confirmation before the installer assertions change. Bootloader unlock is outside the project.

The recovery package should write the variant's boot and system partitions only. Keep the device's recovery, modem firmware, bootloader, EFS and partition table intact. Verify the package manifest and updater script before installation. During the first device session, verify charge reporting and thermal protections before sustained testing. Stop the session on a thermal or charging fault.

If a test boot fails, return to the device's existing recovery, capture `/proc/last_kmsg` when available, and restore the backed-up boot and system images with that recovery. Preserve unrelated partitions and use the model's backup procedures for data. From a device that exposes ADB, use `scripts/collect-boot-logs.sh NEW_LOG_DIRECTORY` to collect the available read-only diagnostics. Radio and system logs can contain device and subscriber identifiers, so review them before sharing.

The T-Mobile product excludes native carrier and emergency calls and is unsuitable as a primary emergency-capable phone.
