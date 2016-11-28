
#import "LiveViewController.h"
#import "PlayerViewController.h"
#import "ODRefreshControl.h"
#import "NetWorkEngine.h"
#import "PlayerModel.h"
#import <Masonry/Masonry.h>
#import "SVMemberReservationCell.h"

// 千帆接口
#define MainData [NSString stringWithFormat:@"http://qf.56.com/home/v4/moreAnchor.ios?imei=F0E5DA05-2D39-4C64-96B1-709589586FB7&index=0&signature=4836aa20a15be22db215a628d766c9f7&size=48&ts=1479461479&type=0"]

@interface LiveViewController () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) NSMutableArray * dataArray;

@end

@implementation LiveViewController


- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
        
    UIImage* logo = [UIImage imageNamed:@"logo4searchbar"];
    UIImageView* logoView = [[UIImageView alloc] initWithImage:logo];
    logoView.frame = CGRectMake(0, 0, logo.size.width, logo.size.height);
    self.navigationItem.titleView = logoView;

    [self setupView];
    
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
        [vc.collectionView reloadData];
    };
}

#pragma mark ---- <setupcollectionView>
- (void)setupView {
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);//分别为上、左、下、右
    
    UICollectionView* collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionView];
    
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    [collectionView registerClass:[SVMemberReservationCell class] forCellWithReuseIdentifier:@"SVMemberReservationCellId"];

    //4.设置代理
    collectionView.delegate = self;
    collectionView.dataSource = self;
    
    self.collectionView = collectionView;
}

#pragma mark ---- <添加下拉刷新>
- (void)addRefresh {
    
    ODRefreshControl *refreshController = [[ODRefreshControl alloc] initInScrollView:self.collectionView];
    [refreshController addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshController {
    
    [refreshController endRefreshing];
    [self loadData];
}

#pragma mark ---- <数据源方法>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
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

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SVMemberReservationCell *cell = (SVMemberReservationCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SVMemberReservationCellId" forIndexPath:indexPath];
    
    [cell updateWithdataDic:[self.dataArray objectAtIndex:indexPath.item] indexPath:indexPath.item];

    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = ([UIScreen mainScreen].bounds.size.width-20*3)/2;
    return CGSizeMake(width, width*10/9);
}


@end
