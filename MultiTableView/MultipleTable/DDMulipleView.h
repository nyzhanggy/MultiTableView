#import <UIKit/UIKit.h>

@class DDMulipleView;
@protocol DDMulipleViewDataSources <NSObject>


/**
 分区的个数，也就是tableview的个数／segment的分段数
 */
- (NSInteger)numberOfSectionsInMulipleView:(DDMulipleView *)mulipleView ;


/**
 每个 section 对应的tableview
 */
- (UITableView *)mulipleView:(DDMulipleView *)mulipleView tableViewForSection:(NSInteger)section;

/**
 头视图
 */
- (UIView *)headerViewForMulipleView:(DDMulipleView *)mulipleView;

@optional
/**
 segment 每个分段的标题
 */
- (NSString *)mulipleView:(DDMulipleView *)mulipleView titleForSection:(NSInteger)section;

@end

@protocol DDMulipleViewDelegate<NSObject>

/**
 点击 segment 的回调
 */
- (void)mulipleView:(DDMulipleView *)mulipleView didSelectedSection:(NSInteger)section;
@end

@interface DDMulipleView : UIView

@property (nonatomic, weak) id<DDMulipleViewDataSources>dataSources;
@property (nonatomic, weak) id<DDMulipleViewDelegate>delegate;
@property (nonatomic, assign) CGFloat hoverOffset;                      /**< 悬停的偏移量 */
@property (nonatomic, strong) NSArray *tiltleArray;                     /**< segment 标题 */
@property (nonatomic, strong) UIColor *sectionNormalColor;              /**< segment 正常颜色 */
@property (nonatomic, strong) UIColor *sectionSelectedColor;            /**< segment 选中颜色 */


/**
 刷新头视图
 */
- (void)reloadHeaderView;


/**
 更新segment 分段的标题
 */
- (void)updateSectionTitleAtSection:(NSInteger)section;
- (void)updateSectionTitle:(NSString *)title atSection:(NSInteger)section;

/**
 更新tableview
 */
- (void)updateTableViewAtSection:(NSInteger)section;
@end
