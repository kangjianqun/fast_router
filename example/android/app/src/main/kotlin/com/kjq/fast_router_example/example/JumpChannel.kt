package com.kjq.fast_router_example.example

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.util.*

class JumpChannel(flutterEngine: BinaryMessenger, activity: MainActivity) : MethodCallHandler {
    private val batteryChannelName = "flutter.jump.platform"
    private var channel: MethodChannel
    private var mActivity: FlutterActivity

    private var resultMap = HashMap<String, MethodChannel.Result>()

    init {
        channel = MethodChannel(flutterEngine, batteryChannelName)
        channel.setMethodCallHandler(this)
        mActivity = activity
    }

    fun invokeMethod(method: String, arguments: Objects?) {
        print("invokeMethod :$method")
        channel.invokeMethod(method, arguments)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "jumpToPage" -> {
                val intent = Intent(mActivity, JumpTestActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
                mActivity.startActivityForResult(intent, 1111)
                resultMap["1111"] = result
            }
            "别的method" -> {
                //处理samples.flutter.jumpto.android下别的method方法
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == 1111) {
            resultMap["1111"]?.success(data?.extras?.get("ChannelResult"))
        }
    }
}