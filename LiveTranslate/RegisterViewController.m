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
    navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"X"] style:UIBarButtonItemStyleBordered target:self.parentViewController action:@selector(dismissModalViewControllerAnimated:)];
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
    
    // Setup textFields
    NSInteger TFWidth = ScreenWidth-60;
    NSInteger TFHeight = 46;
    UITextField *userTF = [ApplicationDelegate makeRegisterTFWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, nameLabel.frame.origin.y+22+40, TFWidth, TFHeight) tag:0 delegate:self placeholder:@"Username" image:@"Username" keyboard:UIKeyboardTypeDefault];
    UITextField *passTF = [ApplicationDelegate makeRegisterTFWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, userTF.frame.origin.y+40+10, TFWidth, TFHeight) tag:1 delegate:self placeholder:@"PIN" image:@"Password" keyboard:UIKeyboardTypeDefault];
    passTF.secureTextEntry = YES;
    UITextField *confTF = [ApplicationDelegate makeRegisterTFWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, passTF.frame.origin.y+40+10, TFWidth, TFHeight) tag:2 delegate:self placeholder:@"Confirm PIN" image:@"Confirm Password" keyboard:UIKeyboardTypeDefault];
    confTF.secureTextEntry = YES;
    UITextField *phoneTF = [ApplicationDelegate makeRegisterTFWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, confTF.frame.origin.y+40+10, TFWidth, TFHeight) tag:3 delegate:self placeholder:@"Phone" image:@"Phone" keyboard:UIKeyboardTypeNumberPad];
    UITextField *realTF = [ApplicationDelegate makeRegisterTFWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, phoneTF.frame.origin.y+40+10, TFWidth, TFHeight) tag:4 delegate:self placeholder:@"Real name" image:@"Real name" keyboard:UIKeyboardTypeDefault];
    UITextField *genderTF = [ApplicationDelegate makeRegisterTFWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, realTF.frame.origin.y+40+10, TFWidth, TFHeight) tag:5 delegate:self placeholder:@"Gender" image:@"Gender" keyboard:UIKeyboardTypeDefault];
    
    // Setup Sign Up Button
    UIButton *signUpBtn = [ApplicationDelegate makeFlatButtonWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, genderTF.frame.origin.y+40+30, TFWidth, TFHeight) text:@"SIGN UP"];
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
    
    NSString *phoneNumber = [NSString stringWithFormat:@"%@-%@-%@", [dataArray[3] substringToIndex:3], [dataArray[3] substringWithRange:NSMakeRange(3, 3)], [dataArray[3] substringFromIndex:6]];
    NSString *urlString = [[NSString stringWithFormat:@"http://ec2-54-81-194-68.compute-1.amazonaws.com/register?name=%@&pin=%@&phone=%@&realname=%@&gender=%c",dataArray[0],dataArray[1],phoneNumber,dataArray[4],[[dataArray[5] uppercaseString] characterAtIndex:0]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [ApplicationDelegate sendRequestWithURL:urlString successBlock:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
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
