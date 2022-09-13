package com.kjq.fast_router_example.example

import android.app.Activity
import android.app.Application
import android.os.Bundle
import android.util.Log

class AppCo : Application() {

//    private lateinit var flutterEngine: FlutterEngine

    override fun onCreate() {
        super.onCreate()
//        flutterEngine = FlutterEngine(this)
//        flutterEngine.navigationChannel.setInitialRoute("empty")
//        flutterEngine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
//        FlutterEngineCache.getInstance().put("aaabbbccc", flutterEngine)
        initLifecycle()
    }

    //在Application里获取要显示页面的context
    private fun initLifecycle() {
        registerActivityLifecycleCallbacks(object : ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
                Log.e("aaaaaaaa-c", activity.localClassName)
            }

            override fun onActivityStarted(activity: Activity) {}

            override fun onActivityResumed(activity: Activity) {}

            override fun onActivityPaused(activity: Activity) {}

            override fun onActivityStopped(activity: Activity) {}
            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
            override fun onActivityDestroyed(activity: Activity) {
                Log.e("aaaaaaaa-d", activity.localClassName)
            }
        })
    }


//    override fun onTerminate() {
//        super.onTerminate()
//        flutterEngine.destroy()
//    }
}