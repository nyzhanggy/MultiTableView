//
//  IVESegmentView.m
//  MyDemo
//
//  Created by Ive on 16/4/8.
//  Copyright © 2016年 Ive. All rights reserved.
//

#import "IVESegmentView.h"
#import <objc/runtime.h>

@interface IVESegmentView (){
    MDSegmentType       _segType;
    CGFloat            _underLineHeight;
    CGFloat            _btnMaxY;
    MDSegmentBlock      _segmentBlock;
    UIView              *_underLineView;
    NSMutableArray      *_btns;
    UIColor             *_selectedColor;
}
@property (nonatomic,assign,readonly) NSInteger selectedIndex;
@end

@implementation IVESegmentView

const static char kBtnIndexKey;
-(instancetype)initWithFrame:(CGRect)frame buttons:(NSArray*)btnTitleArr type:(MDSegmentType)segType normalColor:(UIColor*)nornalColor selectedColor:(UIColor*)selectedColor underLineHeight:(CGFloat)underLineHeight block:(MDSegmentBlock)segmentBlock{
    self = [self initWithFrame:frame];
    if (self && [btnTitleArr count]>0) {
        _segType = segType;
        _underLineHeight = underLineHeight;
        _btnMaxY = CGRectGetHeight(frame)-underLineHeight;
        _segmentBlock = segmentBlock;
        _selectedColor = selectedColor;
        CGFloat btn_x = 0.0f;
        CGFloat average_width = CGRectGetWidth(frame)/[btnTitleArr count];
        int i = 0;
        _btns = [[NSMutableArray alloc] init];
        _selectedIndex = -1;
        for (NSString *title in btnTitleArr) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitleColor:nornalColor forState:UIControlStateNormal];
            [btn setTitleColor:selectedColor forState:UIControlStateSelected];
            [btn setTitle:title forState:UIControlStateNormal];
            [btn setFrame:CGRectMake(btn_x, 0, average_width, CGRectGetHeight(frame))];
            btn.titleLabel.font = [UIFont systemFontOfSize:14.f];
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            btn_x += average_width;
            
            objc_setAssociatedObject(btn, &kBtnIndexKey, @(i), OBJC_ASSOCIATION_ASSIGN);
            [btn addTarget:self action:@selector(actionButtonClick:) forControlEvents:UIControlEventTouchDown];
            [self addSubview:btn];
            [_btns addObject:btn];
            i++;
        }
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowRadius = 1;
        self.layer.shadowOpacity = 0.2;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        
    }
    return self;
}

- (void)actionButtonClick:(UIButton*)btn{
    NSInteger index = [objc_getAssociatedObject(btn, &kBtnIndexKey) integerValue];
    [self selectIndex:index doBlock:YES];
}

- (void)selectIndex:(NSUInteger)index doBlock:(BOOL)doblock{
    
    UIButton *btn = [_btns objectAtIndex:index];
    CGRect line_frame = [btn.titleLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(btn.frame), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:btn.titleLabel.font} context:nil];
    CGFloat minY  =  btn.center.y+CGRectGetHeight(line_frame)/2+2;
    if (_segType == MDSegmentTypeWithUnderLine) {
        minY = CGRectGetHeight(self.frame) - _underLineHeight;
    }
    CGRect underLineNewFrame = CGRectMake(btn.center.x-line_frame.size.width/2,minY, line_frame.size.width, _underLineHeight);
    if (!_underLineView || ![[self subviews] containsObject:_underLineView]) {
        _underLineView = [[UIView alloc] initWithFrame:underLineNewFrame];
        _underLineView.backgroundColor = _selectedColor;
        [self addSubview:_underLineView];
    }
    for (UIButton *btnItem in _btns) {
        if (btn == btnItem) {
            btnItem.selected = YES;
        }else{
            btnItem.selected = NO;
        }
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        _underLineView.frame = underLineNewFrame;
    } completion:^(BOOL finished) {
        
    }];
    if (doblock && _selectedIndex != index && _segmentBlock) {
        _segmentBlock(index);
    }
    _selectedIndex = index;
}

@end
