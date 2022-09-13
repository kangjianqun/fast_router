package com.kjq.fast_router_example.example

import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        FlutterEngineCache.getInstance().put("aaaccc", flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        //跳转到原生Android页面
        jumpChannel = JumpChannel(flutterEngine.dartExecutor.binaryMessenger, this)
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("<platform-view-type>", NativeViewFactory())
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 1111) {
            jumpChannel?.onActivityResult(requestCode, resultCode, data)
        }
    }

    companion object {
        var jumpChannel: JumpChannel? = null
    }
}
