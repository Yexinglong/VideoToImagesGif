//
//  VideoToImagesGif.h
//  GIFdemo
//
//  Created by 叶星龙 on 15/3/19.
//  Copyright (c) 2015年 一修科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RenderOperation.h"
typedef void (^VideoToImagesGifBlock)(NSString *VideoToImagesGifPath, NSError *error);
@interface VideoToImagesGif : NSObject

+ (VideoToImagesGif *)shared;
/**
 
 *  @param asset AVURLAsset
 */
-(void)setupControlWithAVAsset:(AVAsset *)videoURLStr VideoToImagesGifBlock:(VideoToImagesGifBlock)block;
@end
