// Copyright 2022-present 650 Industries. All rights reserved.

#import <UIKit/UIKit.h>

#ifdef RN_FABRIC_ENABLED
#ifdef __cplusplus
#import <React/RCTViewComponentView.h>

@interface ExpoFabricViewObjC : RCTViewComponentView
@end

#else

// Interface visible in Swift
@interface ExpoFabricViewObjC
@end

#endif // __cplusplus
#else // Paper
#import <React/RCTView.h>

@interface ExpoFabricViewObjC : RCTView
@end

#endif // RN_FABRIC_ENABLED

@class EXAppContext;

// Addition to the interface that is visible in both Swift and Objective-C
@interface ExpoFabricViewObjC (ExpoFabricViewInterface)

@property (nonatomic, strong, nullable) UIView *contentView;

- (void)dispatchEvent:(nonnull NSString *)eventName payload:(nullable id)payload;

- (void)updateProp:(nonnull NSString *)propName withValue:(nonnull id)value;

- (void)installCallbacks;

- (void)prepareForRecycle;

#pragma mark - Methods injected to the class in runtime

- (nullable EXAppContext *)__injectedAppContext;
- (nonnull NSString *)__injectedModuleName;

@end

#import <React/RCTView.h>
@class ExpoFabricView;
@interface ExpoView : RCTView
@property (nonatomic, nullable, weak) ExpoFabricView *viewManager;
- (void)dispatchEvent:(nonnull NSString *)eventName payload:(nullable id)payload;
@end

//open class ExpoViewSw: RCTView {
//  public weak var viewManager: ExpoFabricView?
//
//  public func dispatch(event: String, payload: Any? = nil) {
//    viewManager?.dispatchEvent(event, payload: payload)
//  }
//}
