//
//  SignInViewController.m
//  LiveTranslate
//
//  Created by George Lo on 4/20/14.
//  Copyright (c) 2014 George Lo & Krishnabh Medhi. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController {
    NSString *username;
    NSString *password;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

// Changing Status Bar to LightContent style
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up Background ImageView
    UIImage *wallpaper = [UIImage imageNamed:@"SignInWallpaper"];
    wallpaper = [wallpaper blurredImageWithRadius:5 iterations:2 tintColor:[UIColor blackColor]];
    UIImageView *backgroundIV = [[UIImageView alloc] initWithImage:wallpaper];
    backgroundIV.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    backgroundIV.contentMode = UIViewContentModeScaleToFill;
    
    // Add a black overlay to the background imageview
    UIView *blackView = [[UIView alloc] initWithFrame:backgroundIV.frame];
    blackView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.68];
    [backgroundIV addSubview:blackView];
    
    // Add Icon and App Name on top of the black overlay
    UIImageView *iconIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon"]];
    NSInteger iconSideLength = ScreenWidth * 10 / 20;
    NSInteger startX = (ScreenWidth-iconSideLength)/2;
    iconIV.frame = CGRectMake(startX, 50, iconSideLength, iconSideLength);
    iconIV.layer.borderColor = [UIColor whiteColor].CGColor;
    iconIV.layer.borderWidth = 2;
    iconIV.layer.masksToBounds = YES;
    iconIV.layer.cornerRadius = 50;
    [blackView addSubview:iconIV];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50+iconSideLength+20, ScreenWidth, 22)];
    nameLabel.text = @"Live Translate";
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:28];
    [blackView addSubview:nameLabel];
    
    // Setup Username Field
    NSInteger TFWidth = ScreenWidth-60;
    NSInteger TFHeight = 44;
    UITextField *userTF = [[UITextField alloc] initWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, nameLabel.frame.origin.y+22+40, TFWidth, TFHeight)];
    userTF.tag = 0;
    userTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    userTF.delegate = self;
    userTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    userTF.returnKeyType = UIReturnKeyDone;
    userTF.userInteractionEnabled = YES;
    userTF.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.75];
    userTF.textColor = [UIColor whiteColor];
    userTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.8 alpha:1.0]}];
    UIView *userIconBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFHeight+20, TFHeight)];
    UIImageView *userIconIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Username"]];
    userIconIV.frame = CGRectMake(10, 9, 26, 26);
    userIconIV.contentMode = UIViewContentModeScaleAspectFit;
    [userIconBox addSubview:userIconIV];
    UIView *userSeparatorLine = [[UIView alloc] initWithFrame:CGRectMake(46, 8, 1, 28)];
    userSeparatorLine.backgroundColor = [UIColor whiteColor];
    [userIconBox addSubview:userSeparatorLine];
    userTF.leftView = userIconBox;
    userTF.leftViewMode = UITextFieldViewModeAlways;
    
    // Setup Password Field
    UITextField *passTF = [[UITextField alloc] initWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, userTF.frame.origin.y+40+20, TFWidth, TFHeight)];
    passTF.tag = 1;
    passTF.secureTextEntry = YES;
    passTF.delegate = self;
    passTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    passTF.returnKeyType = UIReturnKeyDone;
    passTF.userInteractionEnabled = YES;
    passTF.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.75];
    passTF.textColor = [UIColor whiteColor];
    passTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"PIN" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.8 alpha:1.0]}];
    UIView *passIconBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TFHeight+20, TFHeight)];
    UIImageView *passIconIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Password"]];
    passIconIV.frame = CGRectMake(10, 9, 26, 26);
    passIconIV.contentMode = UIViewContentModeScaleAspectFit;
    [passIconBox addSubview:passIconIV];
    UIView *passSeparatorLine = [[UIView alloc] initWithFrame:CGRectMake(46, 8, 1, 28)];
    passSeparatorLine.backgroundColor = [UIColor whiteColor];
    [passIconBox addSubview:passSeparatorLine];
    passTF.leftView = passIconBox;
    passTF.leftViewMode = UITextFieldViewModeAlways;
    
    // Setup Sign In Button
    UIButton *signInBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    signInBtn.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    signInBtn.frame = CGRectMake((ScreenWidth-TFWidth)/2, passTF.frame.origin.y+40+20, TFWidth, TFHeight);
    [signInBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    signInBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [signInBtn setTitle:@"SIGN IN" forState:UIControlStateNormal];
    [signInBtn addTarget:self action:@selector(signIn:) forControlEvents:UIControlEventTouchUpInside];
    
    // Setup Sign Up part
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, signInBtn.frame.origin.y+40+20, TFWidth, TFHeight)];
    hintLabel.font = [UIFont systemFontOfSize:14];
    hintLabel.text = @"Don't have an account?";
    hintLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.userInteractionEnabled = YES;
    [hintLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toRegister:)]];
    UILabel *registerLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, hintLabel.frame.origin.y+20, TFWidth, TFHeight)];
    registerLabel.font = [UIFont systemFontOfSize:15];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@"Register now"];
    [attributeString addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInt:1]
                            range:(NSRange){0,[attributeString length]}];
    registerLabel.attributedText = attributeString;
    registerLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    registerLabel.textAlignment = NSTextAlignmentCenter;
    registerLabel.userInteractionEnabled = YES;
    [registerLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toRegister:)]];
    
    // Add Views on self
    [self.view addSubview:backgroundIV];
    [self.view addSubview:userTF];
    [self.view addSubview:passTF];
    [self.view addSubview:signInBtn];
    [self.view addSubview:hintLabel];
    [self.view addSubview:registerLabel];
}

- (IBAction)signIn:(id)sender {
    // Resign First Responder if any
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    for (UIView *subView in self.view.subviews) {
        subView.isFirstResponder ? [subView resignFirstResponder] : 0;
    }
    
    // Check for empty fields
    if (username.length <= 0 || password.length <= 0) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please fill in your username and password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    MRProgressOverlayView *overlayView = [MRProgressOverlayView showOverlayAddedTo:self.view animated:YES];
    overlayView.titleLabelText = @"Signing In...";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlString = [[NSString stringWithFormat:@"http://ec2-54-81-194-68.compute-1.amazonaws.com/login?name=%@&pin=%@",username,password] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@",urlString);
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([[dict objectForKey:@"success"] isEqualToString:@"true"]) {
                [[PDKeychainBindings sharedKeychainBindings] setObject:username forKey:@"Username"];
                [[PDKeychainBindings sharedKeychainBindings] setObject:password forKey:@"PIN"];
                data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-54-81-194-68.compute-1.amazonaws.com/profile?username=%@",username]]];
                dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                [UserDefaults setInteger:[[dict objectForKey:@"user_id"] integerValue] forKey:@"id"];
                [UserDefaults setObject:[dict objectForKey:@"user_realName"] forKey:@"realName"];
                [UserDefaults setObject:[dict objectForKey:@"user_gender"] forKey:@"gender"];
                [UserDefaults setObject:[dict objectForKey:@"user_phoneNumber"] forKey:@"phoneNumber"];
                [UserDefaults setObject:[dict objectForKey:@"user_status"] forKey:@"status"];
                [UserDefaults synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [overlayView dismiss:YES];
                    TabBarViewController *tbvc = [[TabBarViewController alloc] init];
                    tbvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                    [self presentViewController:tbvc animated:YES completion:nil];
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

- (IBAction)toRegister:(id)sender {
    RegisterViewController *rvc = [[RegisterViewController alloc] init];
    rvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:rvc animated:YES completion:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, -210, ScreenWidth, ScreenHeight);
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 0) {
        username = textField.text;
    } else if (textField.tag == 1) {
        password = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    }];
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
