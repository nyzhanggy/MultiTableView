#import <UIKit/UIKit.h>

@class DDMultipleView;
@protocol DDMultipleViewDataSources <NSObject>


/**
 分区的个数，也就是tableview的个数／segment的分段数
 */
- (NSInteger)numberOfSectionsInMultipleView:(DDMultipleView *)multipleView ;


/**
 每个 section 对应的tableview
 */
- (UITableView *)multipleView:(DDMultipleView *)multipleView tableViewForSection:(NSInteger)section;

/**
 头视图
 */
- (UIView *)headerViewForMultipleView:(DDMultipleView *)multipleView;

@optional
/**
 segment 每个分段的标题
 */
- (NSString *)multipleView:(DDMultipleView *)multipleView titleForSection:(NSInteger)section;

@end

@protocol DDMultipleViewDelegate<NSObject>

/**
 点击 segment 的回调
 */
- (void)multipleView:(DDMultipleView *)multipleView didSelectedSection:(NSInteger)section;
@end

@interface DDMultipleView : UIView

@property (nonatomic, weak) id<DDMultipleViewDataSources>dataSources;
@property (nonatomic, weak) id<DDMultipleViewDelegate>delegate;
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
