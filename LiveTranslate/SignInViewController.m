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
    UIView *blackView;
	BOOL isGlowing;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
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
    blackView = [[UIView alloc] initWithFrame:backgroundIV.frame];
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
    
    // Setup Username and Password Field
    NSInteger TFWidth = ScreenWidth-60;
    NSInteger TFHeight = 44;
    UITextField *userTF = [ApplicationDelegate makeSignInTFWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, nameLabel.frame.origin.y+22+40, TFWidth, TFHeight) tag:0 delegate:self placeholder:@"Username" image:@"Username"];
    UITextField *passTF = [ApplicationDelegate makeSignInTFWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, userTF.frame.origin.y+40+20, TFWidth, TFHeight) tag:1 delegate:self placeholder:@"PIN" image:@"Password"];
    passTF.secureTextEntry = YES;
    
    // Setup Sign In Button
    UIButton *signInBtn = [ApplicationDelegate makeFlatButtonWithFrame:CGRectMake((ScreenWidth-TFWidth)/2, passTF.frame.origin.y+40+20, TFWidth, TFHeight) text:@"SIGN IN"];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    blackView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.68];
    if (![UserDefaults integerForKey:@"NoGlow"] && !isGlowing ) {
        [self bright:nil];
		isGlowing = YES;
    } else {
        isGlowing = NO;
    }
}

- (IBAction)bright:(id)sender {
    if (![UserDefaults integerForKey:@"NoGlow"]) {
        [UIView animateWithDuration:2 animations:^{
            blackView.backgroundColor = [UIColor colorWithWhite:0.38 alpha:0.68];
        } completion:^(BOOL finished){
            [self dim:sender];
        }];
    }
}

- (IBAction)dim:(id)sender {
    if (![UserDefaults integerForKey:@"NoGlow"]) {
        [UIView animateWithDuration:2 animations:^{
            blackView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.68];
        } completion:^(BOOL finished){
            [self bright:sender];
        }];
    }
}

- (void)toMain {
    [ApplicationDelegate startRetrieveMessage];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[FriendsViewController alloc] init]];
    
    RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:navigationController
                                                                    leftMenuViewController:[SideMenuViewController new]
                                                                   rightMenuViewController:nil];
    sideMenuViewController.backgroundImage = [UIImage imageNamed:@"SideMenuWallpaper"];
    sideMenuViewController.menuPreferredStatusBarStyle = 1; // UIStatusBarStyleLightContent
    sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
    sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
    sideMenuViewController.contentViewShadowOpacity = 0.6;
    sideMenuViewController.contentViewShadowRadius = 12;
    sideMenuViewController.contentViewShadowEnabled = YES;
    sideMenuViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:sideMenuViewController animated:YES completion:nil];
}

- (IBAction)signIn:(id)sender {
    // Resign First Responder if any
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    for (UIView *subView in self.view.subviews) {
        subView.isFirstResponder ? [subView resignFirstResponder] : 0;
    }
    
    if (FORCE_LOGIN) {
        [self toMain];
    } else {
        // Check for empty fields
        if (username.length <= 0 || password.length <= 0) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Please fill in your username and password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
        }
        
        NSString *urlString = [[NSString stringWithFormat:@"http://ec2-54-81-194-68.compute-1.amazonaws.com/login?name=%@&pin=%@",username,password] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [ApplicationDelegate sendRequestWithURL:urlString successBlock:^{
            [[PDKeychainBindings sharedKeychainBindings] setObject:username forKey:@"Username"];
            [[PDKeychainBindings sharedKeychainBindings] setObject:password forKey:@"PIN"];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ec2-54-81-194-68.compute-1.amazonaws.com/profile?username=%@",username]]];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            [UserDefaults setInteger:[[dict objectForKey:@"user_id"] integerValue] forKey:@"id"];
            [UserDefaults setObject:[dict objectForKey:@"user_realName"] forKey:@"realName"];
            [UserDefaults setObject:[dict objectForKey:@"user_gender"] forKey:@"gender"];
            [UserDefaults setObject:[dict objectForKey:@"user_phoneNumber"] forKey:@"phoneNumber"];
            [UserDefaults setObject:[dict objectForKey:@"user_status"] forKey:@"status"];
            [UserDefaults synchronize];
            [self toMain];
        }];
    }
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
}

@end
