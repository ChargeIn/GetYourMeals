package com.example.get_your_meals

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.time.format.FormatStyle


class MainActivity: FlutterActivity() {
    private val CHANNEL = "get_your_meals.com/fsalarm"
    private lateinit var alarmManager: AlarmManager

    @RequiresApi(Build.VERSION_CODES.O)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

            val meal = call.argument<String>("meal")

            if(call.method == "setAlarm") {
                val resultStr = meal?.let { setAlarm(meal) }
                if( resultStr == "Done.") {
                    result.success("Done.")
                } else {
                    result.error("Error", "IDK", null);
                }
            } else if(call.method == "cancelAlarm") {
                val resultStr = meal?.let { cancelAlarm(meal) }
                if( resultStr == "Done.") {
                    result.success("Done.")
                } else {
                    result.error("Error", "IDK", null);
                }
            } else {
                result.notImplemented()
            }
        }
    }


    @RequiresApi(Build.VERSION_CODES.O)
    private fun setAlarm(meal: String): String {
        val mealInfo = meal.split(";")[0].split(",")

        val notificationManager = this.getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "get_your_meal"
        val channelName: CharSequence = "My Channel"
        val importance = NotificationManager.IMPORTANCE_DEFAULT
        val notificationChannel = NotificationChannel(channelId, channelName, importance)
        notificationChannel.enableLights(true)
        notificationChannel.lightColor = Color.RED
        notificationChannel.enableVibration(true)
        notificationChannel.vibrationPattern = longArrayOf(1000, 2000)
        notificationManager.createNotificationChannel(notificationChannel)


        val fullScreenIntent = Intent()
        val fullScreenPendingIntent = PendingIntent.getActivity(this, 0,
                fullScreenIntent, PendingIntent.FLAG_UPDATE_CURRENT)

        val notificationBuilder =
                NotificationCompat.Builder(this, channelId)
                        .setSmallIcon(R.drawable.notification_icon)
                        .setContentTitle(
                                LocalDateTime.now().format(DateTimeFormatter.ofLocalizedTime(FormatStyle.SHORT))
                                 + " Get Your: " + mealInfo[0])
                        .setContentText(mealInfo[2])
                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                        .setCategory(NotificationCompat.CATEGORY_CALL)
                        .setFullScreenIntent(fullScreenPendingIntent, true)

        val incomingCallNotification = notificationBuilder.build()


        notificationManager.notify(mealInfo[0].hashCode(), incomingCallNotification)

        return "Done."
    }


    private fun cancelAlarm(meal: String): String {

        return "Done."
    }

}
