//
//  UploadImageTool.h
//  meb3.0
//
//  Created by hz on 16/4/6.
//  Copyright © 2016年 hz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Qiniu/QiniuSDK.h>

@interface UploadImageTool : NSObject

//获取七牛上传token
+ (void)getQiniuUploadToken:(void(^)(NSString*token))success failure:(void(^)(void))failure;

//获取七牛上传token(safe)
+ (void)getQiniuUploadTokenWithSafe:(BOOL)isSafe success:(void(^)(NSString *token))success failure:(void(^)(void))failure;

/**
 *上传图片
 *
 *@param image 需要上传的image
 *@param progress 上传进度block
 *@param success 成功block返回url地址
 *@param failure 失败block
 */
+ (void)uploadImage:(UIImage*)image
           progress:(QNUpProgressHandler)progress
            success:(void(^)(NSString*url))success
            failure:(void(^)(void))failure;

/**
 *上传图片(安全)
 *
 *@param image 需要上传的image
 *@param isSafe 是否使用安全域名
 *@param progress 上传进度block
 *@param success 成功block返回url地址
 *@param failure 失败block
 */
+ (void)uploadImage:(UIImage *)image
               safe:(BOOL)isSafe
           progress:(QNUpProgressHandler)progress
            success:(void(^)(NSString*url))success
            failure:(void(^)(void))failure;

/**
 上传多张图片,按队列依次上传

 @param imageArray 图片数组<UIimage>
 @param progress 上传进度block
 @param success 成功block返回url地址
 @param failure 失败block
 */
+ (void)uploadImages:(NSArray<UIImage *>*)imageArray
            progress:(void(^)(CGFloat))progress
             success:(void(^)(NSArray*))success
             failure:(void(^)(void))failure;

/**
 上传多张图片,按队列依次上传(安全)
 
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
             failure:(void(^)(void))failure;

+ (void)handleResponseObject:(id)responseObject success:(void(^)(NSString *token))success failure:(void(^)(void))failure;

@end
