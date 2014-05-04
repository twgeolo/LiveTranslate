//
//  AppDelegate.h
//  LiveTranslate
//
//  Created by George Lo on 4/20/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


- (void)startRetrieveMessage;
- (void)stopRetrieveMessage;
- (FMResultSet *)executeQuery:(NSString*)sql, ...;
- (BOOL)executeUpdate:(NSString*)sql, ...;
- (void)sendRequestWithURL: (NSString *)urlStr
              successBlock:(void (^)(void))completion;
- (UIButton *)makeFlatButtonWithFrame: (CGRect)rect
                                 text: (NSString *)title;
- (UITextField *)makeRegisterTFWithFrame: (CGRect)rect
                                     tag: (NSInteger)tag
                                delegate: (id)delegate
                             placeholder: (NSString *)placeholder
                                   image: (NSString *)imageName
                                keyboard: (UIKeyboardType)keyboardType;
- (UITextField *)makeSignInTFWithFrame: (CGRect)rect
                                   tag: (NSInteger)tag
                              delegate: (id)delegate
                           placeholder: (NSString *)placeholder
                                 image: (NSString *)imageName;
- (void)customizeViewController: (UIViewController *)sender tableView: (BOOL)tvBool;
- (UIImage *)circularImage:(UIImage*)image withFrame:(CGRect)frame;
- (void)getContacts;
- (NSString *)languageForKey: (NSString *)key;

@end
