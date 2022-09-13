package com.kjq.fast_router_example.example

import android.content.Context
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.Toast
import io.flutter.plugin.platform.PlatformView

internal class NativeView(context: Context, id: Int, creationParams: Map<String?, Any?>?) : PlatformView {
    //    private val textView: TextView
    private val view: View
    private val context: Context

    override fun getView(): View {
        return view
    }

    override fun dispose() {
        Log.e("aaaaaaaa", "dispose: ")
    }

    init {
        Log.e("aaaaaaaa", "init: ")
//        this.context = ContextThemeWrapper(context,R.style.Theme_AppCompat)
        this.context = context
        view = LayoutInflater.from(this.context).inflate(R.layout.activity_jump_test, null)
        view.findViewById<Button>(R.id.button).setOnClickListener {
            Toast.makeText(this.context, "setOnClickListener", Toast.LENGTH_LONG).show()
        }
//        textView = TextView(context)
//        textView.textSize = 72f
//        textView.setBackgroundColor(Color.rgb(255, 255, 255))
//        textView.text = "Rendered on a native Android view (id: $id)"
    }

    override fun onFlutterViewDetached() {
        Toast.makeText(context, "onFlutterViewDetached", Toast.LENGTH_LONG).show()
        Log.e("aaaaaaaa", "onFlutterViewDetached: ")
    }

    override fun onFlutterViewAttached(flutterView: View) {
        Toast.makeText(context, "onFlutterViewDetached", Toast.LENGTH_LONG).show()
        Log.e("aaaaaaaa", "onFlutterViewAttached: ")
    }
}