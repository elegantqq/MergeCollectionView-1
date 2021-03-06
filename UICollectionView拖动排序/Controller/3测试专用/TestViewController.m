//
//  TestViewController.m
//  UICollectionView拖动排序
//
//  Created by Lym on 2017/4/11.
//  Copyright © 2017年 Lym. All rights reserved.
//

#import "TestViewController.h"
#import "MergeCollectionViewCell.h"
#import "MergeCollectionView.h"
#import "Config.h"

static const int ITEM_NUMBER = 10;                     //item数量
static NSString * const kImage = @"kImage";             //logo图片
static NSString * const kTitle = @"kTitle";             //图片标题

typedef NS_ENUM(NSInteger, kMoveType){
    kMoveTypeNone,
    kMoveTypeExchange,
    kMoveTypeMerge
};
@interface TestViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;//collectionView数据源数组
@property (nonatomic, strong) NSMutableArray<NSArray *> *containerArray;//记录包含合并的数组
@property (nonatomic, strong) MergeCollectionView * collectionView;
@property (nonatomic, assign) kMoveType moveType;//移动方式，移动or合并


@end

@implementation TestViewController
- (NSMutableArray *)containerArray{
    if (!_containerArray) {
        _containerArray = [[NSMutableArray alloc]init];
    }
    return _containerArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCollectionView];
    _moveType = kMoveTypeNone;
    
    _dataArray = [NSMutableArray array];
    //添加数据源
    for (int i = 1; i <= ITEM_NUMBER; i++) {
        NSString *str = [NSString stringWithFormat:@"%d", i];
        UIImage *image = [UIImage imageNamed:@"proper_logo"];
        NSDictionary *dic = @{kImage:image,kTitle:str};
        [_dataArray addObject:dic];
        [self.containerArray addObject:@[dic]];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - ---------- 创建collectionView ----------
- (void)createCollectionView {
    
    _collectionView = [[MergeCollectionView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT - 20)];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    /*
     *  增加长按手势
     *  触发长按事件时间为0.5秒
     */
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongGesture:)];
    longGesture.minimumPressDuration = 0.5f;
    [_collectionView addGestureRecognizer:longGesture];
}

#pragma mark - ---------- item数量 ----------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

#pragma mark - ---------- Cell的内容 ----------
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MergeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MergeCollectionViewCell"
                                                                              forIndexPath:indexPath];
    cell.contentLabel.text = [NSString stringWithFormat:@"请假审批%@",self.dataArray[indexPath.item][kTitle]];
    cell.imageView.image = self.dataArray[indexPath.item][kImage];
    return cell;
}

#pragma mark - ---------- Cell的点击事件 ----------
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - ---------- 允许拖动 ----------
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

#pragma mark - ---------- 拖动手势 ----------
static UIView *snapedView;              //截图快照
static NSIndexPath *currentIndexPath;   //当前路径
static NSIndexPath *oldIndexPath;       //旧路径
static NSIndexPath *startIndexPath;   //起始路径
- (void)handlelongGesture:(UILongPressGestureRecognizer *)longGesture{
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:{//手势开始
            //判断手势落点位置是否在Item上
            oldIndexPath = [self.collectionView indexPathForItemAtPoint:[longGesture locationInView:self.collectionView]];
            startIndexPath = oldIndexPath;
            if (oldIndexPath == nil) {
                break;
            }
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:oldIndexPath];
            //使用系统截图功能，得到cell的截图视图
            
            snapedView = [cell snapshotViewAfterScreenUpdates:NO];
            snapedView.frame = cell.frame;
            [self.collectionView addSubview:snapedView];
            //截图后隐藏当前cell
            cell.hidden = YES;
            CGPoint currentPoint = [longGesture locationInView:self.collectionView];
            [UIView animateWithDuration:0.25 animations:^{
//                snapedView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                snapedView.center = CGPointMake(currentPoint.x, currentPoint.y);
            }];
        }
            break;
        case UIGestureRecognizerStateChanged:{//手势改变
            //当前手指位置 - 截图视图位置移动
            CGPoint currentPoint = [longGesture locationInView:self.collectionView];
            snapedView.center = CGPointMake(currentPoint.x, currentPoint.y);
            for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
                if ([self.collectionView indexPathForCell:cell] == oldIndexPath) {
                    continue;
                }
                CGFloat space = sqrtf(pow(snapedView.center.x - cell.center.x, 2) + powf(snapedView.center.y - cell.center.y, 2));
////                if (space <= snapedView.bounds.size.width*3 / 4) {
////                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        currentIndexPath = [self.collectionView indexPathForCell:cell];
////                        //                    if (space <= 10.0) {
////                        //                        UICollectionViewCell *targetCell = [self.collectionView cellForItemAtIndexPath:currentIndexPath];//移动目标cell
////                        //                        [UIView animateWithDuration:0.25 animations:^{
////                        //                            snapedView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
////                        //                        } completion:^(BOOL finished) {
////                        //                            targetCell.contentView.backgroundColor = [UIColor grayColor];
////                        //                        }];
////                        //                        oldIndexPath = currentIndexPath;
////                        //                    }
                        if(space <= snapedView.bounds.size.width*3 / 4){
//                            [self.collectionView moveItemAtIndexPath:oldIndexPath toIndexPath:currentIndexPath];
                            oldIndexPath = currentIndexPath;
                        }
////                    });
////                }
            }
        }
            break;
        default:{//手势结束和其他状态
            CGPoint currentPoint = [longGesture locationInView:self.collectionView];
            snapedView.center = CGPointMake(currentPoint.x, currentPoint.y);

            //计算截图视图和哪个cell相交
            for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
                //当前隐藏的cell就不需要交换了，直接continue
                if ([self.collectionView indexPathForCell:cell] == oldIndexPath) {
                    _moveType = kMoveTypeNone;
                    currentIndexPath = startIndexPath;
                    continue;
                }
                //计算中心距
                CGFloat space = sqrtf(pow(snapedView.center.x - cell.center.x, 2) + powf(snapedView.center.y - cell.center.y, 2));
                NSLog(@"%f",space);
                //如果相交一半就移动
                if(space <= snapedView.bounds.size.width*3 / 4){
                    currentIndexPath = [self.collectionView indexPathForCell:cell];
                    //移动 会调用willMoveToIndexPath方法更新数据源
                    _moveType = kMoveTypeExchange;
                    //更改移动后的起始indexPath，用于后面获取隐藏的cell,是移动后的位置
                    oldIndexPath = currentIndexPath;
                }
                //如果中心距离小于10就合并
                if (space <= 10.0) {
                    if (self.containerArray[startIndexPath.row].count==1) {
                        currentIndexPath = [self.collectionView indexPathForCell:cell];
                        _moveType = kMoveTypeMerge;
                        //更改移动后的起始indexPath，用于后面获取隐藏的cell,是移动前的位置
                        oldIndexPath = startIndexPath;
                    }else{
                        
                    }
                }
            }
            if (_moveType == kMoveTypeExchange) {
//                [self.collectionView moveItemAtIndexPath:startIndexPath toIndexPath:currentIndexPath];
                //移除数据插入到新的位置
                id obj = [_dataArray objectAtIndex:startIndexPath.item];
                [_dataArray removeObject:[_dataArray objectAtIndex:startIndexPath.item]];
                [_dataArray insertObject:obj
                                 atIndex:currentIndexPath.item];
                id containerObj = [self.containerArray objectAtIndex:startIndexPath.item];
                [self.containerArray removeObject:[self.containerArray objectAtIndex:startIndexPath.item]];
                [self.containerArray insertObject:containerObj
                                          atIndex:currentIndexPath.item];
                
            }else if (_moveType == kMoveTypeMerge){
                //设置合并后的新数组
                NSMutableArray *mergeArray = [[NSMutableArray alloc]init];
                [self.containerArray[currentIndexPath.row] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [mergeArray addObject:obj];
                }];
                [mergeArray addObject:self.containerArray[startIndexPath.item][0]];
                [self.containerArray replaceObjectAtIndex:currentIndexPath.item withObject:mergeArray];
                [_dataArray replaceObjectAtIndex:currentIndexPath.row withObject:@{kTitle:@"合成兽",kImage:[self setMergeImageWithImageArray:self.containerArray[currentIndexPath.item]]}];
                [_dataArray removeObject:[_dataArray objectAtIndex:startIndexPath.item]];
                [self.containerArray removeObjectAtIndex:startIndexPath.item];
            }
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:oldIndexPath];//原来隐藏的cell
            UICollectionViewCell *targetCell = [self.collectionView cellForItemAtIndexPath:currentIndexPath];//移动目标cell
            //结束动画过程中停止交互，防止出问题
            self.collectionView.userInteractionEnabled = NO;
            //给截图视图一个动画移动到隐藏cell的新位置
            [UIView animateWithDuration:0.25 animations:^{
                snapedView.center = targetCell.center;
//                snapedView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            } completion:^(BOOL finished) {
                //移除截图视图、显示隐藏的cell并开启交互
                [snapedView removeFromSuperview];
                cell.hidden = NO;
                self.collectionView.userInteractionEnabled = YES;
                [self.collectionView reloadData];
            }];
        }
            break;
    }
}

#pragma mark - ---------- 合成新图标 ----------
- (UIImage *)setMergeImageWithImageArray:(NSArray *)imageArray{
    //新图标大小
    CGSize size = CGSizeMake(SCREEN_WIDTH/4-40, SCREEN_WIDTH/4-40);
    UIGraphicsBeginImageContext(size);
    //从数组中取图片进行拼接
    [imageArray enumerateObjectsUsingBlock:^(NSDictionary* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *image = obj[kImage];
        [image drawInRect:CGRectMake(5/WIDTH_5S_SCALE + 15/WIDTH_5S_SCALE*(idx%2),
                                     5/WIDTH_5S_SCALE + 15/WIDTH_5S_SCALE*(idx/2),
                                     10/WIDTH_5S_SCALE,
                                     10/WIDTH_5S_SCALE)];
        if (idx>=3) {
            *stop = YES;
        }
    }];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}
@end
