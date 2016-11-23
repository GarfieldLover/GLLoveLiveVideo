

#import <UIKit/UIKit.h>
#import "PlayerModel.h"

@interface PlayerTableViewCell : UITableViewCell

@property (nonatomic, strong)UIImageView * iconImage;// 用户头像

@property (nonatomic, strong)UILabel * nameLabel;// 用户姓名

@property (nonatomic, strong)UIButton * address;// 用户地址

@property (nonatomic, strong)UILabel *peopleNumber;// 观看人数

@property (nonatomic, strong)UIImageView * coverImage;// 封面

@property (nonatomic, strong)PlayerModel * playerModel;

@end
