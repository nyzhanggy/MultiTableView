
#import "DDSegmentView.h"

@interface DDSegmentView () {
    NSMutableArray *_itemsArray;
    NSInteger _selectedIndex;
}
@property (nonatomic, strong) UIView *underLineView;

@end

@implementation DDSegmentView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self initViews];
}
- (void)initViews {
    _itemsArray = [NSMutableArray array];
    _selectedIndex = 0;
    [_itemsArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self addSubview:self.underLineView];
    
    NSInteger numberOfSection = [self.dataSources numberOfItemInSegment:self];
    CGFloat itemWidth = CGRectGetWidth(self.frame)/numberOfSection;
    
    for (NSInteger i = 0; i < numberOfSection; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setTitle:[self.dataSources segment:self titleForIndex:i] forState:UIControlStateNormal];
        btn.frame = CGRectMake(itemWidth * i, 0, itemWidth, CGRectGetHeight(self.frame));
        btn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [self addSubview:btn];
        if (i == 0) {
            [btn setTitleColor:self.selectedColor forState:UIControlStateNormal];
            [self updateUnderLineViewWithButton:btn];
        } else {
            [btn setTitleColor:self.normalColor forState:UIControlStateNormal];
        }
        [_itemsArray addObject:btn];
    }
    
}
- (void)changeIndex:(NSInteger)index {
    if (index > _itemsArray.count) {
        return;
    }
    UIButton *button = [_itemsArray objectAtIndex:index];
    [self buttonClick:button];
}

- (void)changeTitleAtIndex:(NSInteger)index {
    NSString *newTitle = [self.dataSources segment:self titleForIndex:index];
    [self changeTitle:newTitle atIndex:index];
}

- (void)changeTitle:(NSString *)title atIndex:(NSInteger)index {
    if (index < _itemsArray.count) {
        UIButton *button = _itemsArray[index];
        if (![button.titleLabel.text isEqualToString:title]) {
            [button setTitle:title forState:UIControlStateNormal];
            if (_selectedIndex == index) {
                [self updateUnderLineViewWithButton:button];
            }
        }
    }
}

-(void)buttonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(segment:didSelectedIndex:)]) {
        [self.delegate segment:self didSelectedIndex:button.tag];
    }
    if (_selectedIndex == button.tag) {
        return;
    }
    if (_selectedIndex >= 0) {
        UIButton *selectedButton = _itemsArray[_selectedIndex];
        [selectedButton setTitleColor:self.normalColor forState:UIControlStateNormal];
    }
    
    [UIView animateWithDuration:.15 animations:^{
        [self updateUnderLineViewWithButton:button];
    }];
    [button setTitleColor:self.selectedColor forState:UIControlStateNormal];
    _selectedIndex = button.tag;
    
}
- (void)updateUnderLineViewWithButton:(UIButton *)button {
    CGRect lineFrame = [button.titleLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(button.frame), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:button.titleLabel.font} context:nil];
    self.underLineView.frame = CGRectMake(button.center.x-lineFrame.size.width/2, button.center.y+CGRectGetHeight(lineFrame)/2+2, lineFrame.size.width, 1);
    _underLineView.hidden = NO;
     
}
#pragma mark - setter && getter

- (UIView *)underLineView {
    if (!_underLineView) {
        _underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
        _underLineView.backgroundColor = self.selectedColor;
        _underLineView.hidden = YES;
    }
    return _underLineView;
}

- (UIColor *)normalColor {
    if (!_normalColor) {
        _normalColor = [UIColor blackColor];
    }
    return _normalColor;
}
- (UIColor *)selectedColor {
    if (!_selectedColor) {
        if (_normalColor) {
            _selectedColor = _normalColor;
        } else {
            _selectedColor = [UIColor blackColor];
        }
    }
    return _selectedColor;
}
@end
