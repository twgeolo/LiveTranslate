//
//  SettingsViewController.m
//  LiveTranslate
//
//  Created by George Lo on 4/21/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController {
    NSMutableArray *sectionTitleAry;
    NSMutableArray *rowTitleAry;
    NSMutableArray *rowDetailAry;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self = [super initWithStyle:UITableViewStyleGrouped];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sectionTitleAry = [[NSMutableArray alloc] initWithObjects:@"Chats", @"Friends", @"Sign In", @"", nil];
    rowTitleAry = [NSMutableArray arrayWithObjects:[NSArray arrayWithObject:@"Send/Receive Language"], [NSArray arrayWithObjects:@"List View", @"Grid View", nil], [NSArray arrayWithObjects:@"Glowing Wallpaper", nil], [NSArray arrayWithObject:@""], nil];
    rowDetailAry = [NSMutableArray arrayWithObjects:[NSArray arrayWithObject:@"English"], [NSArray arrayWithObjects:@"", @"", nil], [NSArray arrayWithObjects:@"", nil], [NSArray arrayWithObject:@""], nil];
    
    self.navigationItem.title = @"Settings";
    UIButton *sideButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sideButton setImage:[UIImage imageNamed:@"SideMenu"] forState:UIControlStateNormal];
    sideButton.frame = CGRectMake(0, 0, 25, 25);
    [sideButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sideButton];
    
    self.tableView.rowHeight = 50;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar"] forBarMetrics:UIBarMetricsDefault];
    UIImage *wallpaperImage = [[UIImage imageNamed:@"Wallpaper"] blurredImageWithRadius:5 iterations:2 tintColor:[UIColor blackColor]];
    [self.navigationController.view setBackgroundColor:[UIColor colorWithPatternImage:wallpaperImage]];
    
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    blackView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.68];
    [self.navigationController.view insertSubview:blackView atIndex:0];
    UIView *blackView2 = [[UIView alloc] initWithFrame:CGRectMake(0, -20, ScreenWidth, 64)];
    blackView2.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.68];
    [self.navigationController.navigationBar insertSubview:blackView2 atIndex:1];
    
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return sectionTitleAry.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sectionTitleAry objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[rowTitleAry objectAtIndex:section] count];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = [UIColor colorWithWhite:0.875 alpha:1.0];
    header.textLabel.font = [UIFont boldSystemFontOfSize:19];
    CGRect headerFrame = header.frame;
    headerFrame.size.height = headerFrame.size.height + 20;
    header.textLabel.frame = headerFrame;
    header.textLabel.textAlignment = NSTextAlignmentLeft;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [[rowTitleAry objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [[rowDetailAry objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    UISwitch *setSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            setSwitch.on = ![UserDefaults integerForKey:@"FriendsGrid"];
        } else {
            setSwitch.on = [UserDefaults integerForKey:@"FriendsGrid"];
        }
        cell.accessoryView = setSwitch;
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            setSwitch.on = ![UserDefaults integerForKey:@"NoGlow"];
        }
        cell.accessoryView = setSwitch;
    } else if (indexPath.section == 3) {
        BButton *logOutButton = [[BButton alloc] initWithFrame:CGRectMake(30, 0, ScreenWidth-60, tableView.rowHeight) type:BButtonTypeDanger style:BButtonStyleBootstrapV3];
        logOutButton.titleLabel.font = [UIFont systemFontOfSize:19];
        [logOutButton setTitle:@"Log Out" forState:UIControlStateNormal];
        [cell.contentView addSubview:logOutButton];
    }
    
    return cell;
}

@end
