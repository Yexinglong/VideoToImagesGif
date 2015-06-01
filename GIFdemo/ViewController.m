//
//  ViewController.m
//  GIFdemo
//
//  Created by 叶星龙 on 15/3/18.
//  Copyright (c) 2015年 一修科技. All rights reserved.
//

#import "ViewController.h"
#import "VideoToImagesGif.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

/**
 *  获取相册里所有的视频
 */
@property (strong, nonatomic) ALAssetsLibrary *assetLib;
/**
 *  所有的视频的路径
 */
@property (strong, nonatomic) NSMutableArray *assetPaths;

@property (strong, nonatomic) UITableView *tableView;


@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UITableView *tableView =[[UITableView alloc]initWithFrame:self.view.bounds];
    tableView.delegate=self;
    tableView.dataSource=self;
    [self.view addSubview:tableView];
    _tableView=tableView;
    
    
    
    _assetLib = [[ALAssetsLibrary alloc] init];
    _assetPaths = [NSMutableArray array];
    
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self scanForAssets];
    });
}
- (void) scanForAssets
{
    [self.assetPaths removeAllObjects];
    [self scanLibraryForAssets];
    
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.assetPaths count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"视频转GIF";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"AssetCellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [self.assetPaths[indexPath.row] lastPathComponent];
    cell.textLabel.textColor = [UIColor blackColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        AVURLAsset*asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:cameraItem.cameraFile.cameraVideoURLStr] options:nil];
//        [[VideoToImagesGif shared] setupControlWithAVAsset:asset VideoToImagesGifBlock:^(NSString *VideoToImagesGifPath, NSError *error) {
//            NSLog(@"%@",VideoToImagesGifPath);
//            
//        }];
//    });
    AVURLAsset* asset = nil;
    
    
    asset = [AVURLAsset URLAssetWithURL:self.assetPaths[indexPath.row] options:nil];
    NSLog(@"%@",self.assetPaths[indexPath.row]);
    
    NSLog(@"11111111     %@",asset);
    
    
    /**
     *  这里才是主要的
     *  @param VideoToImagesGifPath 这里返回是GIF保存路径
     */
#warning 一句话调用
    [[VideoToImagesGif shared] setupControlWithAVAsset:asset VideoToImagesGifBlock:^(NSString *VideoToImagesGifPath, NSError *error) {
        NSLog(@"%@",VideoToImagesGifPath);
    }];
}

- (void) scanLibraryForAssets
{
    [self.assetLib enumerateGroupsWithTypes:ALAssetsGroupAll
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                     if (!group) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             
                                             [_tableView reloadData];
                                         });
                                     }
                                     
                                     [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                         if (![[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                                             return;
                                         }
                                         
                                         [self.assetPaths addObject:[result valueForProperty:ALAssetPropertyAssetURL]];
                                     }];
                                 }
                               failureBlock:^(NSError *error) {
                                   [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error occured scanning camera roll for assets" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                                   NSLog(@"error scanning directory: %@", error);
                               }
     ];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
