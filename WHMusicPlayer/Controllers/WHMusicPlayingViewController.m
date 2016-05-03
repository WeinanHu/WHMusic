//
//  WHMusicPlayingViewController.m
//  WHMusicPlayer
//
//  Created by Wayne on 16/4/27.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import "WHMusicPlayingViewController.h"
#import "WHPlayingTool.h"
#import "WHMusicTool.h"
#import "UIImageView+CornerRadius.h"
#import <AVFoundation/AVFoundation.h>
#define IMAGE_VIEW_TAG 1234

#define ANIMATION_VIEW_TAG 5678
@interface WHMusicPlayingViewController ()<AVAudioPlayerDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *imageContainerView;


@property (weak, nonatomic) IBOutlet UILabel *musicNameLabel;
@property (weak, nonatomic) IBOutlet UISlider *playingSlider;
@property (weak, nonatomic) IBOutlet UILabel *playingOverTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *playingTimeLabel;

@property (weak, nonatomic) IBOutlet UIButton *playingOrPause;
@property(nonatomic,strong) AVAudioPlayer *player;

@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,strong) NSArray *lrcArr;
@property(nonatomic,strong) NSArray *lrcTimes;
@property(nonatomic,strong) NSArray *lrcContents;
@property(nonatomic,strong) NSTimer *lrcShowTimer;
@property(nonatomic,assign) NSInteger lrcIndex;
@property (weak, nonatomic) IBOutlet UITableView *lrcTableView;
@end

@implementation WHMusicPlayingViewController
#pragma mark - 按钮动作：开始或暂停播放 、上一首、下一首、显示歌词
- (IBAction)lrcShowOrHidden:(id)sender {
    if (self.lrcTableView.hidden == YES) {
        [self.lrcTableView setHidden:NO];
        [self setUpLrcShowTimer];
    }else{
        [self.lrcTableView setHidden:YES];
        [self.lrcShowTimer invalidate];
    }
}

- (IBAction)playOrPause:(id)sender {
    //播放
    self.musicNameLabel.text = [WHMusicTool CurrentPlayingMusic].name;
    if (self.playingOrPause.isSelected ==NO) {
        self.playingOrPause.selected = YES;
        [self setUpTimer];
        if (self.lrcTableView.hidden==NO) {
            [self setUpLrcShowTimer];
        }
        
        [[WHPlayingTool getAvAudioPlayer] play];
        
    }else{
    //暂停
        self.playingOrPause.selected = NO;
        if (self.lrcTableView.hidden==NO) {
            [self.lrcShowTimer invalidate];
        }
        [self.timer invalidate];
        [[WHPlayingTool getAvAudioPlayer] pause];
    }
}

- (IBAction)next:(id)sender {
    [self imageSceneChange];
    [WHMusicTool setCurrentPlayingMusic:[WHMusicTool nextMusic]];
//    [self setUpImageView];
    [self setUpTimer];
    if (self.lrcTableView.hidden==NO) {
        
        [self setUpLrcShowTimer];
    }
    self.playingSlider.value = 0;
    self.musicNameLabel.text = [WHMusicTool CurrentPlayingMusic].name;
    [[WHPlayingTool getAvAudioPlayer] play];
    
}

- (IBAction)presious:(id)sender {
    [self imageSceneChange];
    [WHMusicTool setCurrentPlayingMusic:[WHMusicTool previousMusic]];
//    [self setUpImageView];
    if (self.lrcTableView.hidden==NO) {
        
        [self setUpLrcShowTimer];
    }
    
    [self setUpTimer];
    self.playingSlider.value = 0;
    self.musicNameLabel.text = [WHMusicTool CurrentPlayingMusic].name;

    [[WHPlayingTool getAvAudioPlayer] play];
}
#pragma mark - slider的处理
- (IBAction)MusicTimeChangeBegin:(id)sender {
    [self.timer invalidate];
    [[WHPlayingTool getAvAudioPlayer]pause];
    
    
}

- (IBAction)musicTimeChangeEnd:(UISlider *)sender {
    [self setUpTimer];
    if (self.lrcTableView.hidden==NO) {
        
        [self setUpLrcShowTimer];
    }
    if (sender.value ==1) {
        [self next:nil];
        return;
    }
    [WHPlayingTool setMusicTime:[WHPlayingTool playingOverTime]*sender.value];
    self.playingTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",((NSInteger)[WHPlayingTool playingTime])/60,((NSInteger)[WHPlayingTool playingTime])%60];
    [[WHPlayingTool getAvAudioPlayer]play];
}
#pragma mark - 返回table
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 视图加载
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setUpImageView];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.lrcTableView.delegate = self;
    self.lrcTableView.dataSource = self;
    self.lrcTableView.backgroundColor = [UIColor colorWithWhite:0.369 alpha:0.518];
    self.musicNameLabel.text = [WHMusicTool CurrentPlayingMusic].name;
    self.lrcTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.playingOverTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",((NSInteger)[WHPlayingTool playingOverTime])/60,((NSInteger)[WHPlayingTool playingOverTime])%60];
    
    [self setUpTimer];
    self.playingOrPause.selected = [[WHPlayingTool getAvAudioPlayer]isPlaying]?YES:NO;
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - timer相关
-(void)setUpTimer{
    if (self.timer.isValid) {
        [self.timer invalidate];
    }
    [WHPlayingTool getAvAudioPlayer].delegate = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshTime) userInfo:nil repeats:YES];
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.imageContainerView viewWithTag:IMAGE_VIEW_TAG].transform = CGAffineTransformRotate([self.imageContainerView viewWithTag:IMAGE_VIEW_TAG].transform, M_PI/5);
    } completion:nil];
    [UIView animateWithDuration:1 animations:^{
        
    }];

}
-(void)refreshTime{
    if ([[WHPlayingTool getAvAudioPlayer]isPlaying]) {
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            [self.imageContainerView viewWithTag:IMAGE_VIEW_TAG].transform = CGAffineTransformRotate([self.imageContainerView viewWithTag:IMAGE_VIEW_TAG].transform, M_PI/5);
        } completion:nil];
        
        self.playingTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",((NSInteger)[WHPlayingTool playingTime])/60,((NSInteger)[WHPlayingTool playingTime])%60];
        self.playingSlider.value =[WHPlayingTool playingTime]/[WHPlayingTool playingOverTime];
    }
}

#pragma mark - image相关
/**
 *  改变image图片
 */
-(void)changeImage{
   ((UIImageView*)[self.imageContainerView viewWithTag:IMAGE_VIEW_TAG]).image = [UIImage imageNamed:[WHMusicTool CurrentPlayingMusic].icon];
}
/**
 *  初始化图片
 */
-(void)setUpImageView{
    CGFloat superWidth = self.imageContainerView.frame.size.width;
    CGFloat superHeight = self.imageContainerView.frame.size.height;
    CGFloat sideLength = superWidth>superHeight?superHeight:superWidth;
    
    if ([self.imageContainerView viewWithTag:IMAGE_VIEW_TAG]) {
        [[self.imageContainerView viewWithTag:IMAGE_VIEW_TAG] removeFromSuperview];
    }
    if ([self.imageContainerView viewWithTag:ANIMATION_VIEW_TAG]) {
        [[self.imageContainerView viewWithTag:ANIMATION_VIEW_TAG] removeFromSuperview];
    }
    UIView *animationView = [[UIView alloc]initWithFrame:self.imageContainerView.bounds];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,sideLength ,sideLength )];
    //使用三方高效画圆角
    [imageView zy_cornerRadiusRoundingRect];
    [imageView zy_attachBorderWidth:2 color:[UIColor whiteColor]];
    imageView.center = CGPointMake(superWidth/2, superHeight/2);
    
    imageView.tag = IMAGE_VIEW_TAG;
    imageView.image = [UIImage imageNamed:[WHMusicTool CurrentPlayingMusic].icon];
    imageView.contentMode = UIViewContentModeTop;
//    imageView.layer.masksToBounds = YES;
//    imageView.layer.cornerRadius = sideLength/2;
//    imageView.layer.borderWidth = 2.0;
//    imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [animationView addSubview:imageView];
    animationView.tag = ANIMATION_VIEW_TAG;
    [self.imageContainerView addSubview:animationView];
    
}
/**
 *   切换歌曲时的动画
 */
-(void)imageSceneChange{
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        ((UIImageView*)[self.imageContainerView viewWithTag:ANIMATION_VIEW_TAG]).transform = CGAffineTransformScale(((UIImageView*)[self.imageContainerView viewWithTag:ANIMATION_VIEW_TAG]).transform, 0.5, 0.5);
        
    } completion:^(BOOL finished) {
        [self changeImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                ((UIImageView*)[self.imageContainerView viewWithTag:ANIMATION_VIEW_TAG]).transform = CGAffineTransformScale(((UIImageView*)[self.imageContainerView viewWithTag:ANIMATION_VIEW_TAG]).transform, 2, 2);
            } completion:^(BOOL finished) {
                
            }];
        });
    }];
}
#pragma mark - 其他
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - avplayer delegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self next:nil];
}
#pragma mark - tableView delegate & dataSource
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.lrcContents.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LrcCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LrcCell"];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.numberOfLines = 0;
        
    }
    if (self.lrcIndex == indexPath.row) {
        cell.backgroundColor = [UIColor colorWithRed:0.314 green:0.528 blue:0.636 alpha:0.749];
    }else{
        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.textLabel.text = self.lrcContents[indexPath.row];
    return cell;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - lrcTimer
static BOOL needFindIndex = NO;
static NSInteger compIdx = 0;
static BOOL needAnimate = NO;
-(void)setUpLrcShowTimer{
    needFindIndex = NO;
    compIdx = 0;
    needAnimate = NO;
    self.lrcArr = nil;
    self.lrcContents = nil;
    self.lrcTimes = nil;
    if ([self.lrcShowTimer isValid]) {
        [self.lrcShowTimer invalidate];
    }
    self.lrcShowTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(refreshLrc) userInfo:nil repeats:YES];
    self.lrcIndex = 0;
    [self refreshLrc];
}
-(void)refreshLrc{
    double playingTime =[WHPlayingTool playingTime];
    
    //find
    
    if (needFindIndex ==NO) {
        needFindIndex = YES;
        for (int i = 0; i<self.lrcContents.count; i++) {
            //find
            
            if ([self.lrcTimes[i] doubleValue]>[self.lrcTimes[compIdx] doubleValue]&&[self.lrcTimes[i] doubleValue]>playingTime) {
                compIdx = i;
                break;
            }
            if (i==self.lrcContents.count-1) {
                compIdx = i;
            }
            
        }
        self.lrcIndex = compIdx==0?0:compIdx-1;
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.lrcIndex inSection:0];
        [self.lrcTableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionTop animated:needAnimate];
        needAnimate = YES;
//        NSLog(@"-----%@",self.lrcTimes[compIdx]);
        [self.lrcTableView reloadData];
    }
    
    //judge
    if (playingTime>[self.lrcTimes[compIdx] doubleValue]) {
        
        
        needFindIndex = NO;
        
        
    }
    
    
}
#pragma mark - 懒加载
- (NSArray *)lrcArr {
    if (_lrcArr==nil) {
        
		_lrcArr = [WHMusicTool getLrc];
    }
	return _lrcArr;
}

- (NSArray *)lrcTimes {
    if (_lrcTimes==nil) {
        
        NSMutableArray *mutaArr = [NSMutableArray array];
        for (NSDictionary *dic in self.lrcArr) {
            NSString *str = dic[@"lrctime"];
            [mutaArr addObject:str];
        }
        _lrcTimes = mutaArr;
	
    }
	return _lrcTimes;
}

- (NSArray *)lrcContents {
    if (_lrcContents==nil) {
        
        NSMutableArray *mutaArr = [NSMutableArray array];
        for (NSDictionary *dic in self.lrcArr) {
            NSString *str = dic[@"lrc"];
            [mutaArr addObject:str];
        }
		_lrcContents = mutaArr;
	
    }
	return _lrcContents;
}

@end
