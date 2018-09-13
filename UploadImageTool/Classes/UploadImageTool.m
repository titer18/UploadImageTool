//
//  UploadImageTool.m
//  meb3.0
//
//  Created by hz on 16/4/6.
//  Copyright © 2016年 hz. All rights reserved.
//

#import "UploadImageTool.h"
#import "QiniuUploadHelper.h"
#import <AFNetworking/AFNetworking.h>

@implementation UploadImageTool

//给图片命名
+ (NSString*)getDateTimeString
{
    NSDateFormatter*formatter;
    
    NSString*dateString;
    
    formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"yyyy/MM/dd/HHmmss"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    
    return dateString;
}

//获取随机值
+ (NSString *)randomStringWithLength:(int)len
{
    NSString *letters =@"0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];
    
    for(int i=0; i < len; i++)
    {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random_uniform((int)[letters length])]];
    }
    
    return randomString;
}

//图片名字
+ (NSString *)fileName
{
    NSString *fileName = [NSString stringWithFormat:@"%@%@.jpg", [UploadImageTool getDateTimeString], [UploadImageTool randomStringWithLength:4]];
    return fileName;
}

//上传单张图片(safe)
+ (void)uploadImage:(UIImage *)image
               safe:(BOOL)isSafe
           progress:(QNUpProgressHandler)progress
            success:(void(^)(NSString*url))success
            failure:(void(^)(void))failure
{
    [UploadImageTool getQiniuUploadTokenWithSafe:isSafe success:^(NSString*token) {
        
        //压缩图片
        NSData *data = UIImageJPEGRepresentation([self imageByScalingToMaxSize:image], 1);
        
        if(!data)
        {
            if(failure)
            {
                failure();
            }
            
            return;
        }
        
        NSString *fileName = [self fileName];
        
        QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:nil
                                                   progressHandler:progress
                                                            params:nil
                                                          checkCrc:NO
                                                cancellationSignal:nil];
        
        QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
            builder.useHttps = YES;
        }];
        
        QNUploadManager *uploadManager = [QNUploadManager sharedInstanceWithConfiguration:config];
        
        [uploadManager putData:data
                           key:fileName
                         token:token
                      complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          
                          if(info.statusCode == 200 && resp)
                          {
                              QiniuUploadHelper *helper = [QiniuUploadHelper sharedUploadHelper];
                              NSString *host = isSafe ? helper.safeBaseURL : helper.baseURL;
                              
                              NSString *url = [NSString stringWithFormat:@"%@%@", host, resp[@"key"]];
                              
                              if(success)
                              {
                                  success(url);
                              }
                          }
                          else
                          {
                              if(failure)
                              {
                                  failure();
                              }
                          }
                      }option:opt];
    }failure:^{
        
    }];
}

//上传单张图片
+ (void)uploadImage:(UIImage *)image
           progress:(QNUpProgressHandler)progress
            success:(void(^)(NSString*url))success
            failure:(void(^)(void))failure
{
    [self uploadImage:image safe:NO progress:progress success:success failure:failure];
}

/**
 上传多张图片,按队列依次上传
 
 @param imageArray 图片数组<UIimage>
 @param isSafe 是否使用安全域名
 @param progress 上传进度block
 @param success 成功block返回url地址
 @param failure 失败block
 */
+ (void)uploadImages:(NSArray<UIImage *>*)imageArray
                safe:(BOOL)isSafe
            progress:(void(^)(CGFloat))progress
             success:(void(^)(NSArray*))success
             failure:(void(^)(void))failure
{
    if (imageArray.count == 0)
    {
        success(nil);
        return;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    __block CGFloat totalProgress = 0.0f;
    
    __block CGFloat partProgress = 1.0f / [imageArray count];
    
    __block NSUInteger currentIndex = 0;
    
    QiniuUploadHelper *uploadHelper = [QiniuUploadHelper sharedUploadHelper];
    
    __weak typeof(uploadHelper) weakHelper = uploadHelper;
    
    uploadHelper.singleFailureBlock = ^() {
        
        failure();
        
        return;
        
    };
    
    uploadHelper.singleSuccessBlock = ^(NSString *url) {
        if (!url.length) {
            return;
        }
        [array addObject:url];
        
        totalProgress += partProgress;
        
        if (progress)
        {
            progress(totalProgress);
        }
        
        currentIndex++;
        
        if([array count] == [imageArray count])
        {
            success([array copy]);
            
            return;
        }
        else
        {
            if (currentIndex < imageArray.count) {
                [UploadImageTool uploadImage:imageArray[currentIndex] safe:isSafe progress:nil success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];
            }
        }
    };
    
    [UploadImageTool uploadImage:imageArray.firstObject safe:isSafe  progress:nil success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];
}

//上传多张图片
+ (void)uploadImages:(NSArray<UIImage *>*)imageArray progress:(void(^)(CGFloat))progress success:(void(^)(NSArray*))success failure:(void(^)(void))failure
{
    [self uploadImages:imageArray safe:NO progress:progress success:success failure:failure];
}

//==!!ToDo:获取token没有使用加密
//获取七牛的token
+ (void)getQiniuUploadToken:(void(^)(NSString*))success failure:(void(^)(void))failure
{
    [self getQiniuUploadTokenWithSafe:NO success:success failure:failure];
}

//获取七牛上传token(安全)
+ (void)getQiniuUploadTokenWithSafe:(BOOL)isSafe success:(void(^)(NSString*token))success failure:(void(^)(void))failure
{
    QiniuUploadHelper *helper = [QiniuUploadHelper sharedUploadHelper];
    NSString *urlPath = helper.getTokenURL;
    
    NSDictionary *parameters = @{@"isCase": @(isSafe)};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    [manager GET:urlPath parameters:parameters  progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [self handleResponseObject:responseObject success:success failure:failure];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure)
        {
            failure();
        }
    }];
}

+ (void)handleResponseObject:(id)responseObject success:(void(^)(NSString*token))success failure:(void(^)(void))failure
{
    if ([responseObject[@"Success"] boolValue])
    {
        NSString *token = responseObject[@"Content"][@"Token"];
        success(token);
    }
    else
    {
        NSLog(@"%@", responseObject[@"Message"]);
        
        if (failure)
        {
            failure();
        }
    }
}

#define ORIGINAL_MAX_WIDTH 380.0f

#pragma mark - 处理图片
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@end
