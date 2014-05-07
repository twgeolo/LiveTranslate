//
//  SideMenuViewController.m
//  LiveTranslate
//
//  Created by George Lo on 3/30/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import "SideMenuViewController.h"

@interface SideMenuViewController ()

@property (strong, readwrite, nonatomic) UITableView *tableView;

@end

@implementation SideMenuViewController {
    NSArray *titleAry;
    NSArray *imageAry;
}

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
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(20, (self.view.frame.size.height - 48 * 8) / 2.0f, 200, 48 * 8) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];
    titleAry = [NSArray arrayWithObjects:@"Profile", @"Friends", @"Chats", @"Chat Map", @"Settings", @"Report Bug", @"", @"LiveTranslate 1.0\n   by log & kmedhi", nil];
    imageAry = [NSArray arrayWithObjects:@"Profile", @"Friends", @"Chats", @"Chat Map", @"Settings", @"Report Bug", nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MFMailComposeViewController *mc;
    switch (indexPath.row) {
        case 0:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[ProfileViewController alloc] init]] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 1:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[FriendsViewController alloc] init]] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 2:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[ChatsViewController alloc] init]] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 3:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[ChatMapViewController alloc] init]] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 4:
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] init]] animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 5:
            mc = [[MFMailComposeViewController alloc] init];
            mc.navigationBar.titleTextAttributes = @{
                                                     NSForegroundColorAttributeName: [UIColor blackColor],
                                                     NSFontAttributeName: [UIFont systemFontOfSize:17]
                                                     };
            mc.mailComposeDelegate = self;
            [mc setSubject:@"LiveTranslate 1.0"];
            [mc setMessageBody:[NSString stringWithFormat:@"CS 252 Lab 6 by George Lo and Krishnabh Medhi\n\nNSThread Stack Trace:\n%@", [NSThread callStackSymbols]] isHTML:NO];
            [mc setToRecipients:[NSArray arrayWithObjects:@"log@purdue.edu", @"kmedhi@purdue.edu", nil]];
            [mc.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0 green:122./255 blue:1 alpha:1]];
			mc.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:0 green:122./255 blue:1 alpha:1];
			mc.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0 green:122./255 blue:1 alpha:1];
            [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0 green:122./255 blue:1 alpha:1]];
            [self presentViewController:mc animated:YES completion:NULL];
            [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0 green:122./255 blue:1 alpha:1]];
        default:
            break;
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return titleAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:19];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    cell.textLabel.text = titleAry[indexPath.row];
    if (indexPath.row < 6) {
        cell.imageView.image = [UIImage imageNamed:imageAry[indexPath.row]];
    } else {
        cell.textLabel.numberOfLines = 2;
        cell.userInteractionEnabled = NO;
    }
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
