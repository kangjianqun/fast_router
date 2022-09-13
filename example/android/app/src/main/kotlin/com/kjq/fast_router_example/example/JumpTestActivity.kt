package com.kjq.fast_router_example.example

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngineCache

class JumpTestActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_jump_test)
        findViewById<Button>(R.id.button).setOnClickListener {
            val char = FlutterEngineCache.getInstance().get("aaaccc")
            char?.navigationChannel?.pushRoute("/empty")
            startActivity(Intent(this, MainActivity::class.java))
//            navigateUpTo(Intent(this, MainActivity::class.java))
        }
    }

    override fun finish() {
        val data = Intent()
        data.putExtra("ChannelResult", "data")
        setResult(RESULT_OK, data)
        super.finish()
    }

}