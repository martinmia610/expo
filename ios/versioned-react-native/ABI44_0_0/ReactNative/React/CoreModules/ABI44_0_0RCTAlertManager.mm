/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI44_0_0RCTAlertManager.h"

#import <ABI44_0_0FBReactNativeSpec/ABI44_0_0FBReactNativeSpec.h>
#import <ABI44_0_0RCTTypeSafety/ABI44_0_0RCTConvertHelpers.h>
#import <ABI44_0_0React/ABI44_0_0RCTAssert.h>
#import <ABI44_0_0React/ABI44_0_0RCTConvert.h>
#import <ABI44_0_0React/ABI44_0_0RCTLog.h>
#import <ABI44_0_0React/ABI44_0_0RCTUtils.h>

#import "ABI44_0_0CoreModulesPlugins.h"
#import "ABI44_0_0RCTAlertController.h"

@implementation ABI44_0_0RCTConvert (UIAlertViewStyle)

ABI44_0_0RCT_ENUM_CONVERTER(
    ABI44_0_0RCTAlertViewStyle,
    (@{
      @"default" : @(ABI44_0_0RCTAlertViewStyleDefault),
      @"secure-text" : @(ABI44_0_0RCTAlertViewStyleSecureTextInput),
      @"plain-text" : @(ABI44_0_0RCTAlertViewStylePlainTextInput),
      @"login-password" : @(ABI44_0_0RCTAlertViewStyleLoginAndPasswordInput),
    }),
    ABI44_0_0RCTAlertViewStyleDefault,
    integerValue)

@end

@interface ABI44_0_0RCTAlertManager () <ABI44_0_0NativeAlertManagerSpec>

@end

@implementation ABI44_0_0RCTAlertManager {
  NSHashTable *_alertControllers;
}

ABI44_0_0RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

- (void)invalidate
{
  for (UIAlertController *alertController in _alertControllers) {
    [alertController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
  }
}

/**
 * @param {NSDictionary} args Dictionary of the form
 *
 *   @{
 *     @"message": @"<Alert message>",
 *     @"buttons": @[
 *       @{@"<key1>": @"<title1>"},
 *       @{@"<key2>": @"<title2>"},
 *     ],
 *     @"cancelButtonKey": @"<key2>",
 *   }
 * The key from the `buttons` dictionary is passed back in the callback on click.
 * Buttons are displayed in the order they are specified.
 */
ABI44_0_0RCT_EXPORT_METHOD(alertWithArgs : (ABI44_0_0JS::NativeAlertManager::Args &)args callback : (ABI44_0_0RCTResponseSenderBlock)callback)
{
  NSString *title = [ABI44_0_0RCTConvert NSString:args.title()];
  NSString *message = [ABI44_0_0RCTConvert NSString:args.message()];
  ABI44_0_0RCTAlertViewStyle type = [ABI44_0_0RCTConvert ABI44_0_0RCTAlertViewStyle:args.type()];
  NSArray<NSDictionary *> *buttons =
      [ABI44_0_0RCTConvert NSDictionaryArray:ABI44_0_0RCTConvertOptionalVecToArray(args.buttons(), ^id(id<NSObject> element) {
                    return element;
                  })];
  NSString *defaultValue = [ABI44_0_0RCTConvert NSString:args.defaultValue()];
  NSString *cancelButtonKey = [ABI44_0_0RCTConvert NSString:args.cancelButtonKey()];
  NSString *destructiveButtonKey = [ABI44_0_0RCTConvert NSString:args.destructiveButtonKey()];
  UIKeyboardType keyboardType = [ABI44_0_0RCTConvert UIKeyboardType:args.keyboardType()];

  if (!title && !message) {
    ABI44_0_0RCTLogError(@"Must specify either an alert title, or message, or both");
    return;
  }

  if (buttons.count == 0) {
    if (type == ABI44_0_0RCTAlertViewStyleDefault) {
      buttons = @[ @{@"0" : ABI44_0_0RCTUIKitLocalizedString(@"OK")} ];
      cancelButtonKey = @"0";
    } else {
      buttons = @[
        @{@"0" : ABI44_0_0RCTUIKitLocalizedString(@"OK")},
        @{@"1" : ABI44_0_0RCTUIKitLocalizedString(@"Cancel")},
      ];
      cancelButtonKey = @"1";
    }
  }

  ABI44_0_0RCTAlertController *alertController = [ABI44_0_0RCTAlertController alertControllerWithTitle:title
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
  switch (type) {
    case ABI44_0_0RCTAlertViewStylePlainTextInput: {
      [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.secureTextEntry = NO;
        textField.text = defaultValue;
        textField.keyboardType = keyboardType;
      }];
      break;
    }
    case ABI44_0_0RCTAlertViewStyleSecureTextInput: {
      [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = ABI44_0_0RCTUIKitLocalizedString(@"Password");
        textField.secureTextEntry = YES;
        textField.text = defaultValue;
        textField.keyboardType = keyboardType;
      }];
      break;
    }
    case ABI44_0_0RCTAlertViewStyleLoginAndPasswordInput: {
      [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = ABI44_0_0RCTUIKitLocalizedString(@"Login");
        textField.text = defaultValue;
        textField.keyboardType = keyboardType;
      }];
      [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = ABI44_0_0RCTUIKitLocalizedString(@"Password");
        textField.secureTextEntry = YES;
      }];
      break;
    }
    case ABI44_0_0RCTAlertViewStyleDefault:
      break;
  }

  alertController.message = message;

  for (NSDictionary<NSString *, id> *button in buttons) {
    if (button.count != 1) {
      ABI44_0_0RCTLogError(@"Button definitions should have exactly one key.");
    }
    NSString *buttonKey = button.allKeys.firstObject;
    NSString *buttonTitle = [ABI44_0_0RCTConvert NSString:button[buttonKey]];
    UIAlertActionStyle buttonStyle = UIAlertActionStyleDefault;
    if ([buttonKey isEqualToString:cancelButtonKey]) {
      buttonStyle = UIAlertActionStyleCancel;
    } else if ([buttonKey isEqualToString:destructiveButtonKey]) {
      buttonStyle = UIAlertActionStyleDestructive;
    }
    __weak ABI44_0_0RCTAlertController *weakAlertController = alertController;
    [alertController
        addAction:[UIAlertAction
                      actionWithTitle:buttonTitle
                                style:buttonStyle
                              handler:^(__unused UIAlertAction *action) {
                                switch (type) {
                                  case ABI44_0_0RCTAlertViewStylePlainTextInput:
                                  case ABI44_0_0RCTAlertViewStyleSecureTextInput:
                                    callback(@[ buttonKey, [weakAlertController.textFields.firstObject text] ]);
                                    break;
                                  case ABI44_0_0RCTAlertViewStyleLoginAndPasswordInput: {
                                    NSDictionary<NSString *, NSString *> *loginCredentials = @{
                                      @"login" : [weakAlertController.textFields.firstObject text],
                                      @"password" : [weakAlertController.textFields.lastObject text]
                                    };
                                    callback(@[ buttonKey, loginCredentials ]);
                                    break;
                                  }
                                  case ABI44_0_0RCTAlertViewStyleDefault:
                                    callback(@[ buttonKey ]);
                                    break;
                                }
                              }]];
  }

  if (!_alertControllers) {
    _alertControllers = [NSHashTable weakObjectsHashTable];
  }
  [_alertControllers addObject:alertController];

  dispatch_async(dispatch_get_main_queue(), ^{
    [alertController show:YES completion:nil];
  });
}

- (std::shared_ptr<ABI44_0_0facebook::ABI44_0_0React::TurboModule>)getTurboModule:
    (const ABI44_0_0facebook::ABI44_0_0React::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<ABI44_0_0facebook::ABI44_0_0React::NativeAlertManagerSpecJSI>(params);
}

@end

Class ABI44_0_0RCTAlertManagerCls(void)
{
  return ABI44_0_0RCTAlertManager.class;
}
