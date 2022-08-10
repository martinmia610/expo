// Copyright 2022-present 650 Industries. All rights reserved.

import React

/**
 The view that just extends `RCTView`. In the future we may add more features here.
 */
open class ExpoViewSw: RCTView {
  public weak var viewManager: ExpoFabricView?

  public func dispatch(event: String, payload: Any? = nil) {
    viewManager?.dispatchEvent(event, payload: payload)
  }
}
