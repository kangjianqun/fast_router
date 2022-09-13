package com.kjq.fast_router_example.example

import android.content.Context
import androidx.appcompat.view.ContextThemeWrapper
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        return NativeView(ContextThemeWrapper(context, R.style.Theme_AppCompat_Light), viewId, creationParams)
    }

}