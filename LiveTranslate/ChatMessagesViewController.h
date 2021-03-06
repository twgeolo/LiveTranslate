//
//  ChatMessagesViewController.h
//  LiveTranslate
//
//  Created by George Lo on 5/2/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSMessage.h"
#import "JSMessagesViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ChatMessagesViewController : JSMessagesViewController <CLLocationManagerDelegate, JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSString *userName;

@end
