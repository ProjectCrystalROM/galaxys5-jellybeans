# Phone process crash after network registration

## Observed failure

The G900T registered on the AT&T LTE network (`mServiceState=0`, operator AT&T, RAT LTE; signal was reported) and `com.android.phone` repeatedly crashed while rebuilding its APN list.

The captured exception was:

```text
java.lang.NullPointerException
  at com.android.internal.telephony.dataconnection.DcTracker.mvnoMatches(DcTracker.java:1077)
  at com.android.internal.telephony.dataconnection.DcTracker.createApnList(DcTracker.java:1149)
  at com.android.internal.telephony.dataconnection.DcTracker.createAllApnList(DcTracker.java:2247)
  at com.android.internal.telephony.dataconnection.DcTracker.onRecordsLoaded(DcTracker.java:1558)
```

Line 1077 calls `mvno_type.equalsIgnoreCase("spn")` without guarding null. A read-only query of the live carrier DB found the `nxtgenphone` APN (row 1508) had both `mvno_type` and `mvno_match_data` set to SQL NULL. The current Android 4.3 provider schema had nullable MVNO columns, so a direct/custom APN insertion can expose this Jelly Bean framework bug.

## Live recovery and radio state

Updated row 1508 through TelephonyProvider to use empty strings for both MVNO fields and verified the row through a provider query. Radio logs show `getPreferredApnId() = 1508`, successful APN profile matching for `nxtgenphone`, `GetAttachApn` returning the existing profile, and no SQL prepare error. A subsequent factory-reset boot confirmed that the phone process stays available, incoming carrier billing SMS arrives, and packet data can reach the AT&T captive billing portal after manually selecting an APN. Automatic APN preselection did not occur. Because AT&T SIM/plan profiles may require different APNs, this result is documented as profile-dependent APN setup rather than a general data-radio failure.

## Source fix and validation

- Make `DcTracker` treat null/empty MVNO metadata as a non-MVNO APN and normalize null cursor values before comparing them.
- Bump TelephonyProvider schema to v11, default newly created MVNO fields to empty strings, and migrate existing null values.
- Emit explicit empty MVNO metadata in the Crystal AT&T APN entry.

The fixes are included in OTA `cm_kltetmo-ota-574dc9f24d.zip` (SHA-256 `03e988f0716b9d9771bcf044e5d3569b8bbd1a6391ebf32520eb34d13d182a8c`). The user reported the factory-reset validation after flashing this OTA. Further testing should record the precise AT&T SIM/plan and APN selected; a universal automatic default is not assumed.

The raw log buffers were not checked into the workspace because they include SIM/device identifiers. The captured exception and non-identifying state are recorded here.
