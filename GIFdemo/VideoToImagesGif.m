//
//  VideoToImagesGif.m
//  GIFdemo
//
//  Created by 叶星龙 on 15/3/19.
//  Copyright (c) 2015年 一修科技. All rights reserved.
//

#import "VideoToImagesGif.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+YXL.h"
#import "SvGifView.h"
@interface VideoToImagesGif ()
@property (strong, nonatomic) NSOperationQueue *renderQueue;
@end


@implementation VideoToImagesGif
+ (VideoToImagesGif *)shared {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
        
    });
    return instance;
}
-(void)VideoToImagesGifrenderQueue
{
    self.renderQueue = [[NSOperationQueue alloc] init];
    self.renderQueue.maxConcurrentOperationCount = 1;
    [self.renderQueue setSuspended:NO];
}

/**
 *  @param asset AVURLAsset
 */
-(void)setupControlWithAVAsset:(AVAsset *)videoURLStr VideoToImagesGifBlock:(VideoToImagesGifBlock)block
{
    [self VideoToImagesGifrenderQueue];
    [self.renderQueue cancelAllOperations];
    
    RenderOperation *op = nil;
//    AVURLAsset* asset = nil;
//    asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoURLStr] options:nil];
    op = [[RenderOperation alloc] initWithAsset:videoURLStr];
    /**
     *  回调
     *  @param stringPath 返回转GIF成功保存的路径
     *  @param error      返回错误
     */
    UIView * view = [[UIApplication sharedApplication].windows lastObject];
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"jiafei" withExtension:@"gif"];
    SvGifView *gifView = [[SvGifView alloc] initWithCenter:CGPointMake(320/2, 130) fileURL:fileUrl];
    gifView.backgroundColor = [UIColor clearColor];
    gifView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [gifView startGif];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = NSLocalizedString(@"正在制作GIF",nil);
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = YES;
    // 设置图片
    hud.customView = gifView;
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    


    __block MBProgressHUD *mbp =hud;
    
   
    op.renderCompletionBlock = ^(NSString *stringPath, NSError *error) {
        
        if (error) {
            [MBProgressHUD showError:NSLocalizedString(@"制作失败",nil)];
            [mbp hide:YES];
            [gifView stopGif];
            NSLog(@"error rendering image strip: %@", error);
        }else
        {
            
        }
        if([stringPath isEqualToString:@"获取视频失败"])
        {
            [MBProgressHUD showError:NSLocalizedString(@"制作失败",nil)];
            [mbp hide:YES];
            [gifView stopGif];
            NSLog(@"失败");
        }else
        {
            [MBProgressHUD showSuccess:NSLocalizedString(@"制作成功",nil)];
            [mbp hide:YES];
            [gifView stopGif];
            NSLog(@"%@",stringPath);
        }
        block(stringPath,error);
    };
    [self.renderQueue addOperation:op];
}@end
