//
//  WHPlayingTool.m
//  WHMusicPlayer
//
//  Created by Wayne on 16/4/28.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import "WHPlayingTool.h"
#import "WHMusicTool.h"
static AVAudioPlayer *_player;
static WHMusic *_playingMusic;
@implementation WHPlayingTool

+(AVAudioPlayer *)getAvAudioPlayer{
    if (![_playingMusic isEqual:[WHMusicTool CurrentPlayingMusic]]) {
        _player = nil;
    }
    if (!_player) {
        _playingMusic = [WHMusicTool CurrentPlayingMusic];
        NSString *path = [[NSBundle mainBundle]pathForResource:_playingMusic.filename ofType:nil];
        NSURL *url = [NSURL URLWithString:path];
        _player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        [_player prepareToPlay];
    }
    return _player;
}
+(void)killPlayer{
    _player = nil;
}
+(NSTimeInterval)playingTime{
    
    return [self getAvAudioPlayer].currentTime;
}
+(NSTimeInterval)playingOverTime{
    
    return [self getAvAudioPlayer].duration;
}
+(void)setMusicTime:(NSTimeInterval)time{
    [[self getAvAudioPlayer] setCurrentTime:time];
}
@end
