//
//  ChatsViewController.h
//  LiveTranslate
//
//  Created by George Lo on 4/21/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatSelectFriendViewController.h"
#import "ChatMessagesViewController.h"
#import "YIPopupTextView.h"
#import "FMDB.h"
#import <CoreLocation/CoreLocation.h>

@interface ChatsViewController : UITableViewController <CLLocationManagerDelegate, UIGestureRecognizerDelegate, YIPopupTextViewDelegate>

- (void)sendMessageToPeople:(NSArray *)pplAry;
    
@end
