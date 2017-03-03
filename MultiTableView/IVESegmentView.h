//
//  IVESegmentView.h
//  MyDemo
//
//  Created by Ive on 16/4/8.
//  Copyright © 2016年 Ive. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MDSegmentType) {
    MDSegmentTypeDefault,
    MDSegmentTypeWithUnderLine
};
typedef void (^MDSegmentBlock)(NSUInteger segmentIndex) ;

@interface IVESegmentView : UIView

-(instancetype)initWithFrame:(CGRect)frame buttons:(NSArray*)btnTitleArr type:(MDSegmentType)segType normalColor:(UIColor*)nornalColor selectedColor:(UIColor*)selectedColor underLineHeight:(CGFloat)underLineHeight block:(MDSegmentBlock)segmentBlock;
- (void)selectIndex:(NSUInteger)index doBlock:(BOOL)doblock;
@end
