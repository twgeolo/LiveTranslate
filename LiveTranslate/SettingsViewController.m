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
    rowTitleAry = [NSMutableArray arrayWithObjects:[NSArray arrayWithObject:@"Language"], [NSArray arrayWithObjects:@"List View", @"Grid View", nil], [NSArray arrayWithObjects:@"Glowing Wallpaper", nil], [NSArray arrayWithObject:@""], nil];
    rowDetailAry = [NSMutableArray arrayWithObjects:[NSArray arrayWithObject:[ApplicationDelegate languageForKey:[UserDefaults objectForKey:@"Lang"]]], [NSArray arrayWithObjects:@"", @"", nil], [NSArray arrayWithObjects:@"", nil], [NSArray arrayWithObject:@""], nil];
    
    self.navigationItem.title = @"Settings";
    self.tableView.rowHeight = 50;
    self.tableView.separatorColor = [UIColor clearColor];
    [ApplicationDelegate customizeViewController:self tableView:YES];
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
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.75 alpha:1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UISwitch *setSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else if (indexPath.section == 1) {
        setSwitch.tag = indexPath.row;
        [setSwitch addTarget:self action:@selector(changeLayout:) forControlEvents:UIControlEventValueChanged];
        if (indexPath.row == 0) {
            setSwitch.on = ![UserDefaults integerForKey:@"FriendsGrid"];
        } else {
            setSwitch.on = [UserDefaults integerForKey:@"FriendsGrid"];
        }
        cell.accessoryView = setSwitch;
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [setSwitch addTarget:self action:@selector(changeGlow:) forControlEvents:UIControlEventValueChanged];
            setSwitch.on = ![UserDefaults integerForKey:@"NoGlow"];
        }
        cell.accessoryView = setSwitch;
    } else if (indexPath.section == 3) {
        BButton *logOutButton = [[BButton alloc] initWithFrame:CGRectMake(30, 0, ScreenWidth-60, tableView.rowHeight) type:BButtonTypeDanger style:BButtonStyleBootstrapV3];
        [logOutButton addTarget:self action:@selector(logOut:) forControlEvents:UIControlEventTouchUpInside];
        logOutButton.titleLabel.font = [UIFont systemFontOfSize:19];
        [logOutButton setTitle:@"Log Out" forState:UIControlStateNormal];
        [cell.contentView addSubview:logOutButton];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [[[UIActionSheet alloc] initWithTitle:@"Send/Receive Language" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"English", @"Spanish", @"Korean", @"Japanese", @"Chinese Traditional", @"Chinese Simplified", @"Hindi", nil] showInView:self.view];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
        if ([actionSheet.title isEqualToString:@"Send/Receive Language"]) {
            switch (buttonIndex) {
                case 0:
                    [UserDefaults setObject:@"en" forKey:@"Lang"];
                    break;
                case 1:
                    [UserDefaults setObject:@"es" forKey:@"Lang"];
                    break;
                case 2:
                    [UserDefaults setObject:@"ko" forKey:@"Lang"];
                    break;
                case 3:
                    [UserDefaults setObject:@"ja" forKey:@"Lang"];
                    break;
                case 4:
                    [UserDefaults setObject:@"zh-TW" forKey:@"Lang"];
                    break;
                case 5:
                    [UserDefaults setObject:@"zh-CN" forKey:@"Lang"];
                    break;
                case 6:
                    [UserDefaults setObject:@"hi" forKey:@"Lang"];
                    break;
                default:
                    break;
            }
            [UserDefaults synchronize];
            [rowDetailAry replaceObjectAtIndex:0 withObject:[NSArray arrayWithObject:[ApplicationDelegate languageForKey:[UserDefaults objectForKey:@"Lang"]]]];
            [self.tableView reloadData];
        }
    }
}

- (IBAction)changeLayout:(id)sender {
    UISwitch *setSwitch = (UISwitch *)sender;
    if (setSwitch.tag == 0) {
        [UserDefaults setInteger:!setSwitch.on forKey:@"FriendsGrid"];
    } else if (setSwitch.tag == 1) {
        [UserDefaults setInteger:setSwitch.on forKey:@"FriendsGrid"];
    }
    [UserDefaults synchronize];
    [self.tableView reloadData];
}

- (IBAction)changeGlow:(id)sender {
    UISwitch *setSwitch = (UISwitch *)sender;
    [UserDefaults setInteger:!setSwitch.on forKey:@"NoGlow"];
    [UserDefaults synchronize];
}

- (IBAction)logOut:(id)sender {
    [self.navigationController.sideMenuViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
