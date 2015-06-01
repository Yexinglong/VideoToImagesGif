//
//  MBProgressHUD+YXL.h
//  SocialApplications
//
//  Created by Yexinglong on 14-10-5.
//  Copyright (c) 2014年 Yexinglong. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (YXL)
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;


+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;

+ (void)showMessage:(NSString *)message;

+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;

@end
