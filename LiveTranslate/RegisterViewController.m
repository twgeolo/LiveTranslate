//
//  RegisterViewController.m
//  LiveTranslate
//
//  Created by George Lo on 4/21/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController {
    NSMutableArray *dataArray;
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
    
    dataArray = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", @"", nil];
    
    // Setup Register background
    UIImage *wallpaper = [UIImage imageNamed:@"RegisterWallpaper"];
    wallpaper = [wallpaper blurredImageWithRadius:5 iterations:2 tintColor:[UIColor blackColor]];
    UIImageView *backgroundIV = [[UIImageView alloc] initWithImage:wallpaper];
    backgroundIV.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    backgroundIV.contentMode = UIViewContentModeScaleToFill;
    
    // Add a black overlay to the background imageview
    UIView *blackView = [[UIView alloc] initWithFrame:backgroundIV.frame];
    blackView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.68];
    [backgroundIV addSubview:blackView];
    
    // Setup NavigationBar
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, ScreenWidth, 44)];
    [navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];
    navigationBar.translucent = YES;
    navigationBar.tintColor = [UIColor whiteColor];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.text = @"Registration";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    navigationItem.titleView = titleLabel;
    navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"X"] style:UIBarButtonItemStyleBordered target:self action:@selector(cancelRegistration:)];
    [navigationBar pushNavigationItem:navigationItem animated:YES];
    
    // Add title Label on the black overlay
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, navigationBar.frame.origin.y+44+10, ScreenWidth-40, 30)];
    nameLabel.font = [UIFont boldSystemFontOfSize:22];
    nameLabel.text = @"Live Translate";
    nameLabel.textColor = [UIColor whiteColor];
    [blackView addSubview:nameLabel];
    
    // Greeting Label
    UILabel *greetLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, nameLabel.frame.origin.y+30, ScreenWidth-40, 20)];
    greetLabel.font = [UIFont systemFontOfSize:15];
    greetLabel.text = @"Sign up to get started !";
    greetLabel.textColor = [UIColor whiteColor];
    [blackView addSubview:greetLabel];
    
    // Setup Username Field
    NSInteger TFWidth = ScreenWidth-60;
    NSInteger TFHeight = 46;
    UITextField *userTF = [[UITextField alloc] initWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, nameLabel.frame.origin.y+22+40, TFWidth, TFHeight)];
    userTF.tag = 0;
    userTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    userTF.delegate = self;
    userTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    userTF.returnKeyType = UIReturnKeyDone;
    userTF.userInteractionEnabled = YES;
    userTF.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.75];
    userTF.textColor = [UIColor whiteColor];
    userTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.6 alpha:1.0]}];
    UIView *userIconBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFHeight+15, TFHeight)];
    UIView *userBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFHeight, TFHeight)];
    userBgView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    [userIconBox addSubview:userBgView];
    UIImageView *userIconIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Username"]];
    userIconIV.frame = CGRectMake(10, 9, 26, 26);
    userIconIV.contentMode = UIViewContentModeScaleAspectFit;
    [userIconBox addSubview:userIconIV];
    userTF.leftView = userIconBox;
    userTF.leftViewMode = UITextFieldViewModeAlways;
    
    // Setup Password Field
    UITextField *passTF = [[UITextField alloc] initWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, userTF.frame.origin.y+40+10, TFWidth, TFHeight)];
    passTF.tag = 1;
    passTF.secureTextEntry = YES;
    passTF.delegate = self;
    passTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    passTF.returnKeyType = UIReturnKeyDone;
    passTF.userInteractionEnabled = YES;
    passTF.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.75];
    passTF.textColor = [UIColor whiteColor];
    passTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"PIN" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.6 alpha:1.0]}];
    UIView *passIconBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFHeight+15, TFHeight)];
    UIView *passBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFHeight, TFHeight)];
    passBgView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    [passIconBox addSubview:passBgView];
    UIImageView *passIconIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Password"]];
    passIconIV.frame = CGRectMake(10, 9, 26, 26);
    passIconIV.contentMode = UIViewContentModeScaleAspectFit;
    [passIconBox addSubview:passIconIV];
    passTF.leftView = passIconBox;
    passTF.leftViewMode = UITextFieldViewModeAlways;
    
    // Setup Password Confirmation Field
    UITextField *confTF = [[UITextField alloc] initWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, passTF.frame.origin.y+40+10, TFWidth, TFHeight)];
    confTF.tag = 2;
    confTF.secureTextEntry = YES;
    confTF.delegate = self;
    confTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    confTF.returnKeyType = UIReturnKeyDone;
    confTF.userInteractionEnabled = YES;
    confTF.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.75];
    confTF.textColor = [UIColor whiteColor];
    confTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Confirm PIN" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.6 alpha:1.0]}];
    UIView *confIconBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFHeight+15, TFHeight)];
    UIView *confBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFHeight, TFHeight)];
    confBgView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    [confIconBox addSubview:confBgView];
    UIImageView *confIconIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Confirm Password"]];
    confIconIV.frame = CGRectMake(10, 9, 26, 26);
    confIconIV.contentMode = UIViewContentModeScaleAspectFit;
    [confIconBox addSubview:confIconIV];
    confTF.leftView = confIconBox;
    confTF.leftViewMode = UITextFieldViewModeAlways;
    
    // Setup Phone Field
    UITextField *phoneTF = [[UITextField alloc] initWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, confTF.frame.origin.y+40+10, TFWidth, TFHeight)];
    phoneTF.tag = 3;
    phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    phoneTF.delegate = self;
    phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneTF.returnKeyType = UIReturnKeyDone;
    phoneTF.userInteractionEnabled = YES;
    phoneTF.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.75];
    phoneTF.textColor = [UIColor whiteColor];
    phoneTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Phone" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.6 alpha:1.0]}];
    UIView *phoneIconBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFHeight+15, TFHeight)];
    UIView *phoneBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFHeight, TFHeight)];
    phoneBgView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    [phoneIconBox addSubview:phoneBgView];
    UIImageView *phoneIconIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Phone"]];
    phoneIconIV.frame = CGRectMake(10, 9, 26, 26);
    phoneIconIV.contentMode = UIViewContentModeScaleAspectFit;
    [phoneIconBox addSubview:phoneIconIV];
    phoneTF.leftView = phoneIconBox;
    phoneTF.leftViewMode = UITextFieldViewModeAlways;
    
    // Setup Real name Field
    UITextField *realTF = [[UITextField alloc] initWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, phoneTF.frame.origin.y+40+10, TFWidth, TFHeight)];
    realTF.tag = 4;
    realTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    realTF.delegate = self;
    realTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    realTF.returnKeyType = UIReturnKeyDone;
    realTF.userInteractionEnabled = YES;
    realTF.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.75];
    realTF.textColor = [UIColor whiteColor];
    realTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Real name" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.6 alpha:1.0]}];
    UIView *realIconBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFHeight+15, TFHeight)];
    UIView *realBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFHeight, TFHeight)];
    realBgView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    [realIconBox addSubview:realBgView];
    UIImageView *realIconIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Real name"]];
    realIconIV.frame = CGRectMake(10, 9, 26, 26);
    realIconIV.contentMode = UIViewContentModeScaleAspectFit;
    [realIconBox addSubview:realIconIV];
    realTF.leftView = realIconBox;
    realTF.leftViewMode = UITextFieldViewModeAlways;
    
    // Setup Gender field
    UITextField *genderTF = [[UITextField alloc] initWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, realTF.frame.origin.y+40+10, TFWidth, TFHeight)];
    genderTF.tag = 5;
    genderTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    genderTF.delegate = self;
    genderTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    genderTF.returnKeyType = UIReturnKeyDone;
    genderTF.userInteractionEnabled = YES;
    genderTF.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.75];
    genderTF.textColor = [UIColor whiteColor];
    genderTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Gender" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.6 alpha:1.0]}];
    UIView *genderIconBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFHeight+15, TFHeight)];
    UIView *genderBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFHeight, TFHeight)];
    genderBgView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    [genderIconBox addSubview:genderBgView];
    UIImageView *genderIconIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Gender"]];
    genderIconIV.frame = CGRectMake(10, 9, 26, 26);
    genderIconIV.contentMode = UIViewContentModeScaleAspectFit;
    [genderIconBox addSubview:genderIconIV];
    genderTF.leftView = genderIconBox;
    genderTF.leftViewMode = UITextFieldViewModeAlways;
    
    // Setup Sign Up Button
    UIButton *signUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    signUpBtn.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    signUpBtn.frame = CGRectMake((ScreenWidth-TFWidth)/2, genderTF.frame.origin.y+40+30, TFWidth, TFHeight);
    [signUpBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    signUpBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [signUpBtn setTitle:@"SIGN UP" forState:UIControlStateNormal];
    [signUpBtn addTarget:self action:@selector(signUp:) forControlEvents:UIControlEventTouchUpInside];
    
    // Setup Notice Label
    UILabel *noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, signUpBtn.frame.origin.y+TFHeight, TFWidth, 60)];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@"By signing up, you agree to the Terms of Use Agreement and Privacy Policy."];
    [attributeString addAttribute:NSFontAttributeName
                            value:[UIFont systemFontOfSize:12]
                            range:NSMakeRange(0, attributeString.length)];
    [attributeString addAttribute:NSFontAttributeName
                            value:[UIFont boldSystemFontOfSize:13]
                            range:NSMakeRange(32, 23)];
    [attributeString addAttribute:NSFontAttributeName
                            value:[UIFont boldSystemFontOfSize:13]
                            range:NSMakeRange(59, 14)];
    noticeLabel.attributedText = attributeString;
    noticeLabel.textColor = [UIColor whiteColor];
    noticeLabel.numberOfLines = 3;
    
    // Add views
    [self.view addSubview:backgroundIV];
    [self.view addSubview:navigationBar];
    [self.view addSubview:userTF];
    [self.view addSubview:passTF];
    [self.view addSubview:confTF];
    [self.view addSubview:phoneTF];
    [self.view addSubview:realTF];
    [self.view addSubview:genderTF];
    [self.view addSubview:signUpBtn];
    [self.view addSubview:noticeLabel];
    
    // Tap on background to dismiss keyboard
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)]];
}

- (IBAction)signUp:(id)sender {
    [self dismissKeyboard:nil];
    
    // Check for empty fields
    for (NSString *dataStr in dataArray) {
        if (dataStr.length <= 0) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Please fill in all the fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
        }
    }
    
    // Check for password
    if (![dataArray[1] isEqualToString:dataArray[2]]) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"PIN and Confirm PIN must match" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    } else if ([dataArray[1] length] > 8) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"PIN has to be 8 digits or shorter" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    // Check for phone
    if ([dataArray[3] length] != 10) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"A phone number must be 10 digits long" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    MRProgressOverlayView *overlayView = [MRProgressOverlayView showOverlayAddedTo:self.view animated:YES];
    overlayView.titleLabelText = @"Registering";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *phoneNumber = [NSString stringWithFormat:@"%@-%@-%@", [dataArray[3] substringToIndex:3], [dataArray[3] substringWithRange:NSMakeRange(3, 3)], [dataArray[3] substringFromIndex:6]];
        NSString *urlString = [[NSString stringWithFormat:@"http://ec2-54-81-194-68.compute-1.amazonaws.com/register?name=%@&pin=%@&phone=%@&realname=%@&gender=%c",dataArray[0],dataArray[1],phoneNumber,dataArray[4],[[dataArray[5] uppercaseString] characterAtIndex:0]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@",urlString);
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"success"] isEqualToString:@"true"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    overlayView.mode = MRProgressOverlayViewModeCheckmark;
                    overlayView.titleLabelText = @"Your account has been created";
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self dismissViewControllerAnimated:YES completion:^{
                            [overlayView dismiss:YES];
                        }];
                    });
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [overlayView dismiss:YES];
                    [[[UIAlertView alloc] initWithTitle:@"Failed" message:[dict objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                overlayView.mode = MRProgressOverlayViewModeCross;
                overlayView.titleLabelText = @"Network Error\nPlease try again later";
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [overlayView dismiss:YES];
                });
            });
        }
    });
}

- (IBAction)dismissKeyboard:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    for (UIView *subView in self.view.subviews) {
        subView.isFirstResponder ? [subView resignFirstResponder] : 0;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 5) {
        [[[UIAlertView alloc] initWithTitle:@"Gender" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Male", @"Female", nil] show];
        [self dismissKeyboard:nil];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -90, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
        [dataArray replaceObjectAtIndex:5 withObject:[alertView buttonTitleAtIndex:buttonIndex]];
        [self reloadTextFieldAtIndex:5 WithText:[dataArray objectAtIndex:5]];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length > 0) {
        [dataArray replaceObjectAtIndex:textField.tag withObject:textField.text];
        [self reloadTextFieldAtIndex:textField.tag WithText:[dataArray objectAtIndex:textField.tag]];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    [self dismissKeyboard:nil];
    return YES;
}

- (IBAction)cancelRegistration:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)reloadTextFieldAtIndex: (NSInteger)index WithText: (NSString *)text {
    for (UIView *view in self.view.subviews) {
        if ( [view isKindOfClass:[UITextField class]] ) {
            UITextField *textField = (UITextField *)view;
            if (textField.tag == index) {
                textField.text = text;
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
