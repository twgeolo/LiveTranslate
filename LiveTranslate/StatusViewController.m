//
//  StatusViewController.m
//  LiveTranslate
//
//  Created by George Lo on 4/21/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import "StatusViewController.h"

@interface StatusViewController ()

@end

@implementation StatusViewController {
    NSMutableArray *headerArray;
    NSMutableArray *titleArray;
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
    
    self.navigationItem.title = @"Status";
    UIButton *sideButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sideButton setImage:[UIImage imageNamed:@"SideMenu"] forState:UIControlStateNormal];
    sideButton.frame = CGRectMake(0, 0, 26, 26);
    [sideButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sideButton];
    
    headerArray = [[NSMutableArray alloc] initWithObjects:@"Your current status is:", @"Select your new status", @"", nil];
    if ([UserDefaults objectForKey:@"Status"]==nil) {
        [UserDefaults setObject:@"Available" forKey:@"Status"];
        [UserDefaults synchronize];
    }
    NSArray *currentStatus = [NSArray arrayWithObjects:[UserDefaults objectForKey:@"Status"], nil];
    NSArray *defaultStatus = [NSArray arrayWithObjects:@"Available", @"Busy", @"At work", @"At the gym", @"Studying", @"Sleeping", @"In a meeting", @"On a date", @"On a flight", nil];
    NSArray *clearStatus = [NSArray arrayWithObjects:@"", nil];
    titleArray = [[NSMutableArray alloc] initWithObjects:currentStatus, defaultStatus, clearStatus, nil];
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
    return headerArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [headerArray objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[titleArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    cell.textLabel.text = [[titleArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 1) {
        if ([cell.textLabel.text isEqualToString:[[titleArray objectAtIndex:0] objectAtIndex:0]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if (indexPath.section == 2) {
        UILabel *clearStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
        clearStatus.font = [UIFont systemFontOfSize:16];
        clearStatus.text = @"Clear Status";
        clearStatus.textColor = [UIColor redColor];
        clearStatus.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:clearStatus];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        YIPopupTextView* popupTextView = [[YIPopupTextView alloc] initWithPlaceHolder:@"Enter your status here" maxCount:140 buttonStyle:YIPopupTextViewButtonStyleRightCancelAndDone];
        popupTextView.delegate = self;
        popupTextView.caretShiftGestureEnabled = YES;
        [popupTextView showInViewController:self]; // recommended, especially for iOS7
    } else if (indexPath.section == 1) {
        MRProgressOverlayView *overlayView = [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
        overlayView.titleLabelText = @"Setting you status";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString *urlString = [NSString stringWithFormat:@"http://ec2-54-81-194-68.compute-1.amazonaws.com/setStatus?user=%@&statusMsg=%@", [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"Username"], [tableView cellForRowAtIndexPath:indexPath].textLabel];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ([[dict objectForKey:@"success"] isEqualToString:@"true"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[titleArray objectAtIndex:0] replaceObjectAtIndex:indexPath.row withObject:[tableView cellForRowAtIndexPath:indexPath].textLabel];
                        [UserDefaults setObject:[tableView cellForRowAtIndexPath:indexPath].textLabel forKey:@"Status"];
                        [UserDefaults synchronize];
                        [self.tableView reloadData];
                        overlayView.mode = MRProgressOverlayViewModeCheckmark;
                        overlayView.titleLabelText = @"Done";
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [overlayView dismiss:YES];
                        });
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:@"Failed" message:[dict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                        [overlayView dismiss:YES];
                    });
                }
            } else {
                overlayView.mode = MRProgressOverlayViewModeCross;
                overlayView.titleLabelText = @"Network Error";
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [overlayView dismiss:YES];
                });
            }
        });
    } else {
        MRProgressOverlayView *overlayView = [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
        overlayView.titleLabelText = @"Clearing you status";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString *urlString = [NSString stringWithFormat:@"http://ec2-54-81-194-68.compute-1.amazonaws.com/setStatus?user=%@&statusMsg=%@", [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"Username"], @""];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ([[dict objectForKey:@"success"] isEqualToString:@"true"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[titleArray objectAtIndex:0] replaceObjectAtIndex:indexPath.row withObject:@""];
                        [UserDefaults setObject:@"" forKey:@"Status"];
                        [UserDefaults synchronize];
                        [self.tableView reloadData];
                        overlayView.mode = MRProgressOverlayViewModeCheckmark;
                        overlayView.titleLabelText = @"Done";
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [overlayView dismiss:YES];
                        });
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:@"Failed" message:[dict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                        [overlayView dismiss:YES];
                    });
                }
            } else {
                overlayView.mode = MRProgressOverlayViewModeCross;
                overlayView.titleLabelText = @"Network Error";
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [overlayView dismiss:YES];
                });
            }
        });
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)popupTextView:(YIPopupTextView *)textView willDismissWithText:(NSString *)text cancelled:(BOOL)cancelled {
    if (!cancelled) {
        MRProgressOverlayView *overlayView = [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
        overlayView.mode = MRProgressOverlayViewModeIndeterminate;
        overlayView.titleLabelText = @"Setting your status";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *urlString = [NSString stringWithFormat:@"http://ec2-54-81-194-68.compute-1.amazonaws.com/setStatus?user=%@&statusmsg=%@",[[PDKeychainBindings sharedKeychainBindings] objectForKey:@"name"],text];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ([[dict objectForKey:@"success"] isEqualToString:@"true"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[titleArray objectAtIndex:0] replaceObjectAtIndex:0 withObject:text];
                        [UserDefaults setObject:text forKey:@"Status"];
                        [UserDefaults synchronize];
                        [self.tableView reloadData];
                        overlayView.mode = MRProgressOverlayViewModeCheckmark;
                        overlayView.titleLabelText = @"Done";
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [overlayView dismiss:YES];
                        });
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:@"Failed" message:[dict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                        [overlayView dismiss:YES];
                    });
                }
            } else {
                overlayView.mode = MRProgressOverlayViewModeCross;
                overlayView.titleLabelText = @"Network Error";
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [overlayView dismiss:YES];
                });
            }
        });
    }
}

@end
