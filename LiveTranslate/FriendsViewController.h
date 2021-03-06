//
//  FriendsViewController.h
//  LiveTranslate
//
//  Created by George Lo on 4/21/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "MRProgress.h"
#import "Person.h"
#import "FXBlurView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+CWPopup.h"
#import "BButton.h"

@interface FriendsViewController : UITableViewController <UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@end
