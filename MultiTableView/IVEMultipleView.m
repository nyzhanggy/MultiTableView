//
//  MDMulipleView.m
//  MyDemo
//
//  Created by Ive on 16/4/8.
//  Copyright © 2016年 Ive. All rights reserved.
//

#import "IVEMultipleView.h"
#import "IVESegmentView.h"
@interface UIView (IVEUpdateFrame)
- (void)updateMinX:(CGFloat)minX;
- (void)updateMinY:(CGFloat)minY;
- (void)updateWidth:(CGFloat)width;
- (void)updateHeight:(CGFloat)height;
@end

typedef NS_ENUM(NSInteger,ScrollDirection) {
    ScrollDirectionDefult = 0,
    ScrollDirectionLeft = -1,
    ScrollDirectionRight = 1

};

static NSString * const kMDMulipleViewContentOffset = @"contentOffset";
@interface IVEMultipleView ()<UIScrollViewDelegate> {
    NSInteger _currentIndex;
    UIView *_baseHeaderView;
    ScrollDirection _scrollDirection;
    CGFloat _beginDraggingX;
    BOOL _isClickSegment;

}
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) IVESegmentView *segmentView;

@end

@implementation IVEMultipleView
@dynamic currentIndex;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _currentIndex = 0;
        self.clipsToBounds = YES;
        [self addSubview:self.scrollView];
        _scrollDirection = ScrollDirectionDefult;
        _isClickSegment = NO;
    }
    return self;
}

- (void)dealloc {
    for (NSInteger index = 0; index < _tableViews.count; index ++) {
        UITableView *subTableView = [_tableViews objectAtIndex:index];
        [subTableView removeObserver:self forKeyPath:kMDMulipleViewContentOffset];
    }
}


#pragma mark - --UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _isClickSegment = NO;
    if(scrollView.decelerating) {
        scrollView.scrollEnabled = NO; /*正在滚动的时候，把禁止滚动，防止从第一个直接跳到第三个或第四*/
    } else {
        _scrollDirection = ScrollDirectionDefult;
        _beginDraggingX = scrollView.contentOffset.x;
    }

}
/*
    左右滑动的时候，判断滑动方向，并且更新将要出现的tableview的contentoffset；
    如果是点击的就不做处理
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        if (_isClickSegment) {
            return;
        }
        if (scrollView.contentOffset.x < _beginDraggingX) {
            if (_scrollDirection != ScrollDirectionLeft) {
                _scrollDirection = ScrollDirectionLeft;
                NSInteger index = floor(_beginDraggingX/CGRectGetWidth(scrollView.frame));
                [self updateTableViewContentOffsetWithIndex:index -1];
            }
        } else if (scrollView.contentOffset.x > _beginDraggingX) {
            if (_scrollDirection != ScrollDirectionRight) {
                _scrollDirection = ScrollDirectionRight;
                NSInteger index = floor(_beginDraggingX/CGRectGetWidth(scrollView.frame));
                [self updateTableViewContentOffsetWithIndex:index + 1];
            }
        }
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _currentIndex = scrollView.contentOffset.x/CGRectGetWidth(self.scrollView.frame);
    if (scrollView == self.scrollView) {
        [_segmentView selectIndex:_currentIndex doBlock:NO];
    }
    _scrollDirection = ScrollDirectionDefult;
    scrollView.scrollEnabled = YES;
}
#pragma mark - --handler

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _isClickSegment = YES;
    [self updateTableViewContentOffsetWithIndex:currentIndex];
    _currentIndex = currentIndex;
    [self.scrollView setContentOffset:CGPointMake(currentIndex * CGRectGetWidth(self.scrollView.frame), 0) animated:YES];
    _scrollDirection = ScrollDirectionDefult;

}

- (void)updateTableViewContentOffsetWithIndex:(NSInteger)index {
    if (index < 0 || index >= self.tableViews.count) {
        return;
    }

    UITableView *currentTableView = self.tableViews[_currentIndex];
    
    UITableView *tableView = self.tableViews[index];
    if (currentTableView.contentOffset.y < CGRectGetHeight(_headerView.frame)) {
        tableView.contentOffset = currentTableView.contentOffset;
    } else {
        if (tableView.contentOffset.y < CGRectGetHeight(_headerView.frame)) {
            tableView.contentOffset = CGPointMake(0, CGRectGetHeight(_headerView.frame));
        }
    }
}


- (void)changeSegmentViewContentOffSet:(CGPoint)contentOffset {
    
    if (contentOffset.y >= CGRectGetHeight(_headerView.frame)) {
        
        [_baseHeaderView updateMinY:-CGRectGetHeight(_headerView.frame)];
    } else if (contentOffset.y < 0){
        [_baseHeaderView updateMinY:0];
    } else {
        [_baseHeaderView updateMinY:-contentOffset.y];
    }
}

#pragma mark - --KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    UITableView *currentTableView = [_tableViews objectAtIndex:_currentIndex];
    if (object == currentTableView) {
        CGPoint point = [[change valueForKey:@"new"] CGPointValue];
        [self changeSegmentViewContentOffSet:point];
    }
    
}
#pragma mark - --setter and getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.backgroundColor = [UIColor lightGrayColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.clipsToBounds = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (IVESegmentView *)segmentView {
    if (!_segmentView) {
        __weak typeof(self) wSelf = self;
        _segmentView = [[IVESegmentView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 44) buttons:self.segmentTitles type:MDSegmentTypeWithUnderLine normalColor:[UIColor blackColor] selectedColor:[UIColor blueColor] underLineHeight:1 block:^(NSUInteger segmentIndex) {
            [wSelf setCurrentIndex:segmentIndex];
        }];
        _segmentView.backgroundColor = [UIColor whiteColor];
        [_segmentView selectIndex:0 doBlock:NO];
    }
    return _segmentView;
}

- (void)setTableViews:(NSArray *)tableViews {
    _tableViews = [tableViews mutableCopy];
    [self handleTitleArray];
    for (NSInteger index = 0; index < _tableViews.count; index ++) {
        UITableView *subTableView = [_tableViews objectAtIndex:index];
        [subTableView updateMinX:CGRectGetWidth(subTableView.frame) * index];
        [self.scrollView addSubview:subTableView];
        [subTableView addObserver:self forKeyPath:kMDMulipleViewContentOffset options:NSKeyValueObservingOptionNew context:nil];
        UIView *tempHeaderView = [[UIView alloc] initWithFrame:_baseHeaderView.bounds];
        subTableView.tableHeaderView = tempHeaderView;
    }
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * _tableViews.count, CGRectGetHeight(_scrollView.frame));
}

/**
 *  防止title数量和tableview数量不一致
 */
- (void)handleTitleArray{
    if (_segmentTitles && _segmentTitles.count > 0) {
        if (_segmentTitles.count > _tableViews.count) {
            _segmentTitles = [_segmentTitles subarrayWithRange:NSMakeRange(0, _tableViews.count)];
        } else if (_segmentTitles.count < _tableViews.count) {
            NSMutableArray *array = [NSMutableArray arrayWithArray:_segmentTitles];
            for (NSInteger index = 0; index < _tableViews.count - _segmentTitles.count; index ++) {
                [array addObject:@"unkonw"];
            }
            _segmentTitles = [array copy];
        }
        [_baseHeaderView updateHeight:CGRectGetHeight(_headerView.frame) + CGRectGetHeight(self.segmentView.frame)];
        [_baseHeaderView addSubview:self.segmentView];
        [_segmentView updateMinY:CGRectGetHeight(_headerView.frame)];
    }
}

- (void)setHeaderView:(UIView *)headerView {
    _headerView = headerView;
    if (!_baseHeaderView) {
       
        _baseHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(_headerView.frame))];
       
        [_baseHeaderView addSubview:_headerView];
        
        
    }
    [self addSubview:_baseHeaderView];
}

@end


@implementation UIView (IVEUpdateFrame)
- (void)updateMinX:(CGFloat)minX {
    self.frame = CGRectMake(minX, CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}
- (void)updateMinY:(CGFloat)minY {
    self.frame = CGRectMake(CGRectGetMinX(self.frame), minY, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}
- (void)updateWidth:(CGFloat)width {
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), width, CGRectGetHeight(self.frame));
}
- (void)updateHeight:(CGFloat)height{
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), height);
}
@end