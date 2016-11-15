
//  Created byon 15/7/15.
//  Copyright (c) 2015年 All rights reserved.
//

#import "NetWorkEngine.h"
#import "AFNetworking.h"

@interface NetWorkEngine()
@property (nonatomic, strong)AFHTTPSessionManager * manager;

@end
@implementation NetWorkEngine
+ (NetWorkEngine *)shareNetWorkEngine
{
    static NetWorkEngine * data = nil;
    static dispatch_once_t onceToKen;
    dispatch_once(&onceToKen, ^{
        data = [[NetWorkEngine alloc] init];
    });
    return data;
}
// 取消请求数据的方法
- (void)cancelDataRequest
{
    [self.manager.operationQueue cancelAllOperations];
}
// 回调成功失败的方法

// 异步Post数据请求
- (void)AFJSONPostRequest:(NSString *)urlString
{
    NSString * str = [[NSString stringWithFormat:@"%@",urlString]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
    // 格式
    NSDictionary *dic = @{@"format":@"json"};
    NSLog(@"%@",dic);
    self.manager = [AFHTTPSessionManager manager ];
    // 取消请求数据
    [self cancelDataRequest];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    //成功方法
    [_manager POST:str parameters:dic constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.successfulBlock(responseObject);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);

    }];

}
// 同步Get数据请求
- (void)AfJSONGetRequest:(NSString *)urlString
{
    NSString * str = [[NSString stringWithFormat:@"%@",urlString]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * dic = @{@"format":@"json"};
    self.manager = [AFHTTPSessionManager manager ];
    //
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];

    [_manager GET:str parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.successfulBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
//        self.failBlock(error);
    }];

}






@end
