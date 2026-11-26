# G900T network scan and manual selection capture

Captured from the attached device before recovery reboot on 2026-11-26.

- `radio.log`: complete radio buffer, including modem scan and RIL selection flow.
- `main-system.log`: complete main and system buffers.
- `telephony-registry.txt`: framework service/data state at capture time.
- `getprop.txt`: device properties at capture time.
- `dmesg.txt`: kernel ring buffer at capture time.

## Observations

- `QUERY_AVAILABLE_NETWORKS` completed and returned AT&T (`310410`, CURRENT), Verizon (`311480`, AVAILABLE), and T-Mobile (`310260`, AVAILABLE); one additional PLMN (`313100`) was marked FORBIDDEN. This demonstrates that the modem can scan and identify nearby networks.
- The user initiated manual selection of `310410`. The CM11-derived RIL logged `SET_NETWORK_SELECTION_MANUAL 310410`, sent QMI `SET_SYSTEM_SELECTION_PREFERENCE`, and the modem acknowledged the preference with result 0. The captured post-selection system information still reports GSM and UMTS registration state 2 and LTE state 12; the framework says out of service, with data disconnected. Thus the selection command was accepted, but successful network registration is not shown by this capture.
- At the same time, the S5 RIL repeatedly gets preferred APN database ID 1508 and fails `db prepare`, followed by `Failed to load attach apn`. Static inspection of the target `libsec-ril.so` identifies the query: it selects `_id,apn,type,protocol,user,password,authtype,carrier_enabled,max_conn,max_conn_t,wait_time` from `carriers`. CM10.2's provider schema has no `max_conn`, `max_conn_t`, or `wait_time`; replaying the same select against the live database failed with `no such column: max_conn`. Row 1508 exists, so this is a schema mismatch, not a missing APN entry. The temporary database copy used for the check was removed; only this schema/query result is retained.
- The same capture includes Samsung RIL's rejection of `RIL_REQUEST_SET_INITIAL_ATTACH_APN` as an invalid command block. The S5 blob has its own attach-APN refresh path, so standard CM11 request 111 should not be sent to it without a Samsung-specific mapping.
- The failure detail / reject cause is not clear in this capture. Preserve these logs as the pre-reboot reference before changing APN selection or restarting radio services.

## Relevant radio log locations

- Network scan request/result: around lines 12070 and 12418–12427 in `radio.log`.
- Manual selection of 310410: around lines 12690 onward; search for `SET_NETWORK_SELECTION_MANUAL 310410` and `QMI_NAS_SET_SYSTEM_SELECTION_PREFERENCE`.
- Ongoing registration state and attach-APN lookup failures: recurring `lte reg [12]` and `Failed to load attach apn` entries near the end of `radio.log`.
