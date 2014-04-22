//
//  TabBarViewController.m
//  LiveTranslate
//
//  Created by George Lo on 4/21/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Friends
    UINavigationController *friendsNavController = [[UINavigationController alloc] initWithRootViewController:[[FriendsViewController alloc] init]];
    friendsNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Friends" image:[UIImage imageNamed:@"Friends"] tag:0];
    
    // Status
    UINavigationController *statusNavController = [[UINavigationController alloc] initWithRootViewController:[[StatusViewController alloc] init]];
    statusNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Status" image:[UIImage imageNamed:@"Status"] tag:1];
    
    // Chats
    UINavigationController *chatsNavController = [[UINavigationController alloc] initWithRootViewController:[[ChatsViewController alloc] init]];
    chatsNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Chats" image:[UIImage imageNamed:@"Chats"] tag:2];
    
    // Settings
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] init]];
    settingsNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"Settings"] tag:3];
    
    [self setViewControllers:@[friendsNavController, statusNavController, chatsNavController, settingsNavController] animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
