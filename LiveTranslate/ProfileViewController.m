//
//  ProfileViewController.m
//  LiveTranslate
//
//  Created by George Lo on 4/25/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController {
    NSMutableArray *rowTitleAry;
    NSMutableArray *rowDetailAry;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    rowTitleAry = [[NSMutableArray alloc] initWithObjects:@"User ID", @"Real Name", @"Username", @"PIN", @"Phone", @"Status", @"Gender", nil];
    NSMutableString *dottedPassword = [NSMutableString new];
    for (int i = 0; i < [[[PDKeychainBindings sharedKeychainBindings] objectForKey:@"PIN"] length]; i++) {
        [dottedPassword appendString:@"●"];
    }
    rowDetailAry = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%li",(long)[UserDefaults integerForKey:@"id"]], [UserDefaults objectForKey:@"realName"], [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"Username"], dottedPassword, [UserDefaults objectForKey:@"phoneNumber"], [UserDefaults objectForKey:@"status"], [UserDefaults objectForKey:@"gender"], nil];
    
    self.tableView.rowHeight = 70;
    self.tableView.separatorColor = [UIColor clearColor];
    UIButton *sideButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sideButton setImage:[UIImage imageNamed:@"SideMenu"] forState:UIControlStateNormal];
    sideButton.frame = CGRectMake(0, 0, 25, 25);
    [sideButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sideButton];
    
    self.navigationItem.title = @"Profile";
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return rowTitleAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
    cell.textLabel.text = [rowTitleAry objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:18];
    cell.detailTextLabel.text = [rowDetailAry objectAtIndex:indexPath.row];
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryView = nil;
    
    if (indexPath.row == 0) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = indexPath.row;
        [button setImage:[UIImage imageNamed:@"Info"] forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, 24, 24);
        button.tintColor = [UIColor whiteColor];
        [button addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
    } else if (indexPath.row == 3 || indexPath.row == 5) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = indexPath.row;
        [button setImage:[UIImage imageNamed:@"Edit"] forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, 24, 24);
        button.tintColor = [UIColor whiteColor];
        [button addTarget:self action:@selector(editInfo:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
    }
    
    return cell;
}

- (IBAction)showInfo:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"User ID" message:@"This is the ID assigned to you by LiveTranslate SQL Database" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (IBAction)editInfo:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == 5) {
        YIPopupTextView* popupTextView = [[YIPopupTextView alloc] initWithPlaceHolder:@"Enter your status here" maxCount:140 buttonStyle:YIPopupTextViewButtonStyleRightCancelAndDone];
        popupTextView.text = [rowDetailAry objectAtIndex:5];
        popupTextView.delegate = self;
        popupTextView.caretShiftGestureEnabled = YES;
        popupTextView.placeholderColor = [UIColor lightTextColor];
        [popupTextView showInViewController:self]; // recommended, especially for iOS7
    }
}

- (void)popupTextView:(YIPopupTextView *)textView willDismissWithText:(NSString *)text cancelled:(BOOL)cancelled {
    if (!cancelled) {
        MRProgressOverlayView *overlayView = [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
        overlayView.mode = MRProgressOverlayViewModeIndeterminate;
        overlayView.titleLabelText = @"Setting your status...";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *urlString = [[NSString stringWithFormat:@"http://ec2-54-81-194-68.compute-1.amazonaws.com/setStatus?user=%@&statusmsg=%@",[[PDKeychainBindings sharedKeychainBindings] objectForKey:@"Username"],text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"%@",urlString);
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if ([[dict objectForKey:@"success"] isEqualToString:@"true"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [rowDetailAry replaceObjectAtIndex:5 withObject:text];
                        [UserDefaults setObject:text forKey:@"status"];
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    overlayView.mode = MRProgressOverlayViewModeCross;
                    overlayView.titleLabelText = @"Network Error";
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [overlayView dismiss:YES];
                    });
                });
            }
        });
    }
}

@end
