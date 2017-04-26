
#import <UIKit/UIKit.h>
@class DDSegmentView;
@protocol DDSegmentViewDataSource <NSObject>

- (NSInteger)numberOfItemInSegment:(DDSegmentView *)segment;
- (NSString *)segment:(DDSegmentView *)segment titleForIndex:(NSInteger)index;

@end

@protocol DDSegmentViewDelegate <NSObject>
- (void)segment:(DDSegmentView *)segment didSelectedIndex:(NSInteger)index;

@end

@interface DDSegmentView : UIView
@property (nonatomic, weak) id<DDSegmentViewDataSource>dataSources;
@property (nonatomic, weak) id<DDSegmentViewDelegate>delegate;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectedColor;
- (void)changeIndex:(NSInteger)index;
- (void)changeTitleAtIndex:(NSInteger)index;
- (void)changeTitle:(NSString *)title atIndex:(NSInteger)index;
@end
