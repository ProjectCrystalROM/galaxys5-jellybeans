# A2DP silence investigation (2026-11-26)

## Physical result

The user reports that the A2DP sink connects, but no audio is audible. Earlier scan/pair behavior was successful.

## Captured evidence

- `logcat.log` shows the sink entering A2DP Playing and Android opening the A2DP output.
- `audio-policy.txt` shows output routed to the sink (`0x80`, address `90:DA:07:61:63:F5`).
- `audio-flinger.txt` shows active music tracks on A2DP output handle 85, but that thread has `total writes: 0` and is blocked in `write`.
- The log reaches `audio_a2dp_hw: start_audio_datapath: state 5` and then has no further A2DP HAL progress.

## Source-level interpretation

In CM10.2 `external/bluetooth/bluedroid/audio_a2dp_hw/audio_a2dp_hw.c`, `start_audio_datapath()` first sends `A2DP_CTRL_CMD_START` using `a2dp_command()`. That function synchronously waits for a one-byte acknowledgement from the Bluetooth stack. Only after a successful acknowledgement does it connect to `A2DP_DATA_PATH` (`.a2dp_data`). Since the capture contains no `.a2dp_data` connection log, the current evidence points to a START control handshake that is not completing, before PCM is transferred to the A2DP media socket.

The suspected A2DP control/media-task path is distinct from PAN's BNEP data path. Both still depend on the shared Bluetooth stack and controller. No service restart or device mutation was performed as part of this capture.

## Next useful capture

Capture Bluetooth process logcat and a thread backtrace while a START request is stalled; inspect Bluedroid's `btif_recv_ctrl_data()` and media-task event handling for receipt of the START byte and its acknowledgement path. Then re-test A2DP after any targeted fix. PAN packet forwarding should be investigated separately.
