//
//  HotViewController.m
//  高仿映客
//
//  Created by JIAAIR on 16/7/2.
//  Copyright © 2016年 JIAAIR. All rights reserved.
//

#import "HotViewController.h"
#import "PlayerViewController.h"
#import "PlayerTableViewCell.h"
#import "ODRefreshControl.h"
#import "NetWorkEngine.h"
#import "PlayerModel.h"

// 千帆接口
#define MainData [NSString stringWithFormat:@"http://qf.56.com/home/v4/moreAnchor.ios?imei=F0E5DA05-2D39-4C64-96B1-709589586FB7&index=0&signature=4836aa20a15be22db215a628d766c9f7&size=48&ts=1479461479&type=0"]
#define Ratio 10/8
@interface HotViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UITableView * tableView;
@property (nonatomic, strong)NSMutableArray * dataArray;

@end

@implementation HotViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
    
    // 添加下拉刷新
    [self addRefresh];
    
    // 加载数据
    [self loadData];
    
}

#pragma mark ---- <加载数据>
- (void)loadData {
    [self.dataArray removeAllObjects];
    
    __weak __typeof(self)vc = self;
    NetWorkEngine * netWork = [[NetWorkEngine alloc] init];
    [netWork AfJSONGetRequest:MainData];
    netWork.successfulBlock = ^(id object){
        NSArray *listArray = [[object objectForKey:@"message"] objectForKey:@"anchors"];
        
        for (NSDictionary *dic in listArray) {
            
            PlayerModel *playerModel = [[PlayerModel alloc] initWithDictionary:dic];
            playerModel.city = dic[@"city"];
            playerModel.roomid = dic[@"roomid"];
            playerModel.portrait = dic[@"pic51"];
            playerModel.name = dic[@"name"];
            playerModel.online_users = [dic[@"focus"] intValue];
            playerModel.url = [NSString stringWithFormat:@"http://qf.56.com/play/v2/preLoading.ios?roomId=%@",playerModel.roomid];
            [vc.dataArray addObject:playerModel];
            
        }
        [vc.tableView reloadData];
    };
}

#pragma mark ---- <setupTableView>
- (void)setupTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = [UIScreen mainScreen].bounds.size.width * Ratio +1;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    
}

#pragma mark ---- <添加下拉刷新>
- (void)addRefresh {
    
    ODRefreshControl *refreshController = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshController addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshController {
    
//    double delayInSecinds = 3.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSecinds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [refreshController endRefreshing];
        [self loadData];
//    });
}

#pragma mark ---- <数据源方法>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"cell";
    PlayerTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell==nil) {
        
        cell = [[PlayerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    PlayerModel * playerModel = [self.dataArray objectAtIndex:indexPath.row];
    cell.playerModel = playerModel;
    
    return cell;
    
    
}

#pragma mark ---- <点击跳转直播>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerViewController * playerVc = [[PlayerViewController alloc] init];
    PlayerModel * PlayerModel = self.dataArray[indexPath.row];
    // 直播url
    playerVc.liveUrl = PlayerModel.url;
    // 直播图片
    playerVc.imageUrl = PlayerModel.portrait;
    [self.navigationController pushViewController:playerVc animated:true];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

@end
