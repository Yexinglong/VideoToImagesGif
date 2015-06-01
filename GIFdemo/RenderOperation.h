//
//  RenderOperation.h
//  GIFdemo
//
//  Created by 叶星龙 on 15/3/18.
//  Copyright (c) 2015年 一修科技. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
@class JSRenderOperation;

typedef void (^JSRenderOperationCompletionBlock)(NSString *stringPath, NSError *error);

@interface RenderOperation : NSOperation

@property (nonatomic, copy) JSRenderOperationCompletionBlock renderCompletionBlock;

- (id) initWithAsset:(AVAsset *)asset;

@end