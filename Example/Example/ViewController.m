//
//  ViewController.m
//  Example
//
//  Created by HZ on 2018/9/12.
//  Copyright © 2018年 HZ. All rights reserved.
//

#import "ViewController.h"
#import <UploadImageTool/UploadImageTool.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImage *image = [self nomalSnapshotImage];
    [UploadImageTool uploadImage:image progress:nil success:^(NSString *url) {
        
    } failure:^{
        
    }];
}

/**
 普通的截图
 该API仅可以在未使用layer和OpenGL渲染的视图上使用
 
 @return 截取的图片
 */
- (UIImage *)nomalSnapshotImage
{
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, [UIScreen mainScreen].scale);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshotImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
