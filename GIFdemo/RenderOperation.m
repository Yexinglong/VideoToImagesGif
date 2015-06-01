//
//  RenderOperation.m
//  GIFdemo
//
//  Created by 叶星龙 on 15/3/18.
//  Copyright (c) 2015年 一修科技. All rights reserved.
//

#import "RenderOperation.h"
#import "AHIImagesToGIF.h"
@interface NSDictionary (JSSorting)

- (NSArray *) sortedKeys;

@end

@implementation NSDictionary (JSSorting)

- (NSArray *) sortedKeys
{
    return [[self allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        double first = [obj1 doubleValue];
        double second = [obj2 doubleValue];
        
        if (first > second) {
            return NSOrderedDescending;
        }
        
        if (first < second) {
            return NSOrderedAscending;
        }
        
        return NSOrderedSame;
    }];
}

@end

@interface RenderOperation()

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVAssetImageGenerator *generator;

@property (nonatomic, assign) CGRect frame;
@property (strong, nonatomic) NSArray *offsets;

@property (strong, nonatomic) NSString *stringPath;

@end

@implementation RenderOperation

#pragma mark - Memory mgmt

- (id) initWithAsset:(AVAsset *)asset
{
    self = [super init];
    
    if (self) {
        self.asset = asset;
        
        
        self.offsets = [NSArray array];
        
        self.generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        
        self.generator.appliesPreferredTrackTransform = YES;
    }
    
    return self;
}
#pragma mark - NSOperation overrides

- (void) main
{
    
    NSError *error = nil;
    
    
    if (self.isCancelled) {
        return;
    }
    
    if (error) {
        NSLog(@"Error extracting reference image from asset: %@", [error localizedDescription]);
        return;
    }
    //这里调帧图大小，越接近原尺寸就越清晰
    size_t height = (size_t)180;
    size_t width = (size_t)180;
    
    
    self.generator.maximumSize = CGSizeMake(width, height);
    
    
    
    if (self.isCancelled) {
        return;
    }
    
    NSDictionary *images = nil;
    images = [self extractFromAssetAt:[self generateOffsets:self.asset] error:&error];
    if (self.isCancelled) {
        return;
    };
    NSMutableArray *  strip =[NSMutableArray array];
    if (images) {
        NSArray *times = [self generateOffsets:self.asset];
        
        
        for (int idx = 0; idx < [times count]; idx++) {
            
            NSNumber *time = [times objectAtIndex:idx];
            CGImageRef image = (__bridge CGImageRef)([images objectForKey:time]);
            UIImage * naImage =[[UIImage alloc]initWithCGImage:image];
            //            naImage= [self scaleToSize:naImage size:CGSizeMake(200, 200)];
            NSData *imagedata =UIImageJPEGRepresentation(naImage, 0.6);
            UIImage * UIImageCompress=[UIImage imageWithData:imagedata];
            UIImage *addimage =[self imageWithLogoText:UIImageCompress text:@"叶星龙"];
            [strip addObject:addimage];
            
            NSLog(@"%d",idx);
        }
       
        [AHIImagesToGIF saveGIFToPhotosWithImages:strip
                                          withFPS:10
                               animateTransitions:NO
                                withCallbackBlock:^(BOOL success ,id Path) {
                                    if (success) {
                                        _stringPath=Path;
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                            self.renderCompletionBlock(_stringPath, error);
                                        });
                                        NSLog(@"Success %@",Path);
                                        
                                    } else {
                                        _stringPath =@"获取视频失败";
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            self.renderCompletionBlock(_stringPath, error);
                                        });
                                        NSLog(@"Failed");
                                    }
                                    
                                }];
        
        
    }else
    {
        
    }
    
}
- (UIImage *)imageWithLogoText:(UIImage *)img text:(NSString *)text1
{
    /////注：此为后来更改，用于显示中文。zyq,2013-5-8
    CGSize size = CGSizeMake(180, img.size.height);          //设置上下文（画布）大小
    UIGraphicsBeginImageContext(size);                       //创建一个基于位图的上下文(context)，并将其设置为当前上下文
    CGContextRef contextRef = UIGraphicsGetCurrentContext(); //获取当前上下文
    CGContextTranslateCTM(contextRef, 0, img.size.height);   //画布的高度
    CGContextScaleCTM(contextRef, 1.0, -1.0);                //画布翻转
    CGContextDrawImage(contextRef, CGRectMake(0, 0, img.size.width, img.size.height), [img CGImage]);  //在上下文种画当前图片
    
    [[UIColor lightTextColor] set];                                //上下文种的文字属性
    CGContextTranslateCTM(contextRef, 0, img.size.height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    UIFont *font = [UIFont boldSystemFontOfSize:13];
    CGSize textSize = [self TextSize:text1 Font:13];
//    [text1 drawInRect:CGRectMake(img.size.width -textSize.width, img.size.height-textSize.height, textSize.width,textSize.height) withFont:font];       //此处设置文字显示的位置
    [text1 drawInRect:CGRectMake(img.size.width -textSize.width, img.size.height-textSize.height, textSize.width,textSize.height)  withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,[UIColor lightTextColor],NSForegroundColorAttributeName,nil]];
    UIImage *targetimg =UIGraphicsGetImageFromCurrentImageContext();  //从当前上下文种获取图片
    UIGraphicsEndImageContext();                            //移除栈顶的基于当前位图的图形上下文。
    return targetimg;
    
    
    
    
}
-(CGSize )TextSize:(NSString *)text Font:(int )font
{
    UIFont *labelfont=[UIFont boldSystemFontOfSize:font];
    CGSize TextSize = [text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:labelfont,NSFontAttributeName,nil]];
   
    return TextSize;
}
#pragma mark - Support

- (NSArray *) generateOffsets:(AVAsset *) asset
{
    
    
    double duration = CMTimeGetSeconds(asset.duration);
    
    
    NSMutableArray *indexes = [NSMutableArray array];
    
    double time = 0.0f;
    
    while (time < duration) {
        [indexes addObject:[NSNumber numberWithDouble:time]];
        time +=0.1;
    }
    [indexes removeLastObject];
    
    return indexes;
}

- (NSDictionary *) extractFromAssetAt:(NSArray *)indexes error:(NSError **)error
{
    NSMutableDictionary *images = [NSMutableDictionary dictionaryWithCapacity:[indexes count]];
    NSLog(@"%li",[indexes count]);
    CMTime actualTime;
    
    for (NSNumber *number in indexes) {
        
        if (self.isCancelled) {
            return nil;
        }
        
        double offset = [number doubleValue];
        NSLog(@"%f",offset);
        if (offset < 0 || offset > CMTimeGetSeconds(self.asset.duration)) {
            continue;
        }
        
        self.generator.requestedTimeToleranceBefore = kCMTimeZero;
        self.generator.requestedTimeToleranceAfter = kCMTimeZero;
        CMTime t = CMTimeMakeWithSeconds(offset, (int32_t)[indexes count]);
        CGImageRef source = [self.generator copyCGImageAtTime:t actualTime:nil error:error];
        
        if (!source) {
            NSLog(@"Error copying image at index %f: %@", CMTimeGetSeconds(actualTime), [*error localizedDescription]);
            return nil;
        }
    
        [images setObject:CFBridgingRelease(source) forKey:number];
    }
    
    return images;
}
@end
