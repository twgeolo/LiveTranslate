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
    rowTitleAry = [[NSMutableArray alloc] initWithObjects:@"User ID", @"Name", @"Username", @"PIN", @"Phone", @"Status", @"Gender", nil];
    NSMutableString *dottedPassword = [NSMutableString new];
    for (int i = 0; i < [[[PDKeychainBindings sharedKeychainBindings] objectForKey:@"PIN"] length]; i++) {
        [dottedPassword appendString:@"●"];
    }
    rowDetailAry = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%li",(long)[UserDefaults integerForKey:@"id"]], [UserDefaults objectForKey:@"realName"], [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"Username"], dottedPassword, [UserDefaults objectForKey:@"phoneNumber"], [UserDefaults objectForKey:@"status"], [UserDefaults objectForKey:@"gender"], nil];
    
    self.tableView.rowHeight = 70;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.03];
    self.navigationItem.title = @"Profile";
    
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
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"User ID" andMessage:@"This is the ID assigned to you by LiveTranslate SQL Database"];
    [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    [alertView show];
}

- (IBAction)editInfo:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == 3) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Change PIN" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
        alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        [alertView textFieldAtIndex:0].placeholder = @"New PIN";
        [alertView textFieldAtIndex:0].secureTextEntry = YES;
        [alertView textFieldAtIndex:1].placeholder = @"Confirm PIN";
        [alertView textFieldAtIndex:1].secureTextEntry = YES;
        [alertView show];
    } else if (button.tag == 5) {
        YIPopupTextView* popupTextView = [[YIPopupTextView alloc] initWithPlaceHolder:@"Enter your status here" maxCount:140 buttonStyle:YIPopupTextViewButtonStyleRightCancelAndDone];
        popupTextView.text = [rowDetailAry objectAtIndex:5];
        popupTextView.delegate = self;
        popupTextView.caretShiftGestureEnabled = YES;
        popupTextView.placeholderColor = [UIColor lightTextColor];
        [popupTextView showInViewController:self];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
        if ([alertView.title isEqualToString:@"Change PIN"]) {
            if (![[alertView textFieldAtIndex:0].text isEqualToString:[alertView textFieldAtIndex:1].text]) {
                [[[UIAlertView alloc] initWithTitle:nil message:@"New PIN must match Confirm PIN" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                return;
            } else if ([alertView textFieldAtIndex:0].text.length > 8) {
                [[[UIAlertView alloc] initWithTitle:nil message:@"PIN must be 8 characters or shorter" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                return;
            }
            
            NSString *urlString = [NSString stringWithFormat:@"http://ec2-54-81-194-68.compute-1.amazonaws.com/changePin?username=%@&oldPin=%@&newPin=%@", [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"Username"], [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"PIN"], [alertView textFieldAtIndex:0].text];
            [ApplicationDelegate sendRequestWithURL:urlString successBlock:nil];
        }
    }
}

- (void)popupTextView:(YIPopupTextView *)textView willDismissWithText:(NSString *)text cancelled:(BOOL)cancelled {
    if (!cancelled) {
        NSString *urlString = [[NSString stringWithFormat:@"http://ec2-54-81-194-68.compute-1.amazonaws.com/setStatus?user=%@&statusmsg=%@&pin=%@",[[PDKeychainBindings sharedKeychainBindings] objectForKey:@"Username"],text, [[PDKeychainBindings sharedKeychainBindings] objectForKey:@"PIN"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [ApplicationDelegate sendRequestWithURL:urlString successBlock:^{
            [rowDetailAry replaceObjectAtIndex:5 withObject:text];
            [UserDefaults setObject:text forKey:@"status"];
            [UserDefaults synchronize];
            [self.tableView reloadData];
        }];
    }
}

@end
