package org.projectcrystal.basicsms;

import android.app.Notification;
import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.telephony.SmsMessage;
import android.util.Log;
import java.util.LinkedHashMap;
import java.util.Map;

public final class IncomingSmsReceiver extends BroadcastReceiver {
    private static final String SMS_RECEIVED = "android.provider.Telephony.SMS_RECEIVED";
    private static final String TAG = "BasicSMSReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        if (!SMS_RECEIVED.equals(intent.getAction())) {
            return;
        }
        Bundle extras = intent.getExtras();
        Object pdus = extras == null ? null : extras.get("pdus");
        if (!(pdus instanceof Object[])) {
            return;
        }

        Map<String, StringBuilder> messages = new LinkedHashMap<String, StringBuilder>();
        for (Object pdu : (Object[]) pdus) {
            if (!(pdu instanceof byte[])) {
                continue;
            }
            SmsMessage message;
            try {
                // API 18 selects the decoder from the active phone type.
                message = SmsMessage.createFromPdu((byte[]) pdu);
            } catch (RuntimeException exception) {
                Log.w(TAG, "Invalid SMS PDU");
                continue;
            }
            if (message == null || message.getDisplayMessageBody() == null) {
                continue;
            }
            String sender = message.getDisplayOriginatingAddress();
            StringBuilder body = messages.get(sender);
            if (body == null) {
                body = new StringBuilder();
                messages.put(sender, body);
            }
            body.append(message.getDisplayMessageBody());
        }

        NotificationManager notifications =
                (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        for (Map.Entry<String, StringBuilder> entry : messages.entrySet()) {
            String sender = entry.getKey();
            String title = sender == null ? context.getString(R.string.unknown_sender) : sender;
            String body = entry.getValue().toString();
            Notification notification = new Notification.Builder(context)
                    .setSmallIcon(android.R.drawable.stat_notify_chat)
                    .setContentTitle(title)
                    .setContentText(body)
                    .setStyle(new Notification.BigTextStyle().bigText(body))
                    .setDefaults(Notification.DEFAULT_SOUND)
                    .build();
            notifications.notify(sender, 1, notification);
        }
    }
}
