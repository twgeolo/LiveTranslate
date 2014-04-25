//
//  SideMenuViewController.h
//  MusicMate
//
//  Created by George Lo on 3/30/14.
//  Copyright (c) 2014 George Lo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import "ProfileViewController.h"
#import "FriendsViewController.h"
#import "ChatsViewController.h"
#import "SettingsViewController.h"
#import <MessageUI/MessageUI.h>

@interface SideMenuViewController : UIViewController <MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@end
