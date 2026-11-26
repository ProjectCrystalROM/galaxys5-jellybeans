#!/usr/bin/env python3
"""Idempotently add AT&T's LTE APN to the CyanogenMod world APN list."""
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
data = path.read_bytes()
entry = (b'  <apn carrier="AT&amp;T NXTGENPHONE" mcc="310" mnc="410" '
         b'apn="nxtgenphone" mmsc="http://mmsc.mobile.att.net" '
         b'mmsproxy="proxy.mobile.att.net" mmsport="80" '
         b'mvno_type="" mvno_match_data="" '
         b'type="default,mms,supl,hipri" protocol="IP" '
         b'roaming_protocol="IP" />\n')
if b'apn="nxtgenphone"' in data:
    raise SystemExit(0)
if data.count(b'</apns>') != 1:
    raise SystemExit(f"Expected one </apns> in {path}")
path.write_bytes(data.replace(b'</apns>', entry + b'</apns>', 1))
