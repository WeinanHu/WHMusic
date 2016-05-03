//
//  WHMusicTool.m
//  WHMusicPlayer
//
//  Created by Wayne on 16/4/27.
//  Copyright © 2016年 WayneHu. All rights reserved.
//

#import "WHMusicTool.h"
static NSArray *_musicArray;
static WHMusic *_playingMusic;

@implementation WHMusicTool

+(NSArray *)musicArray{
    if (!_musicArray) {
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Musics.plist" ofType:nil];
        NSArray *musicArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
        
        //声明可变数组，存储转换后的模型对象
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *musicDic in musicArray) {
            WHMusic *music = [WHMusic new];
            [music setValuesForKeysWithDictionary:musicDic];
            [mutableArray addObject:music];
        }
        
        _musicArray = [mutableArray copy];
    }
    return _musicArray;
}
+(NSArray *)getCompleteLrc{
    NSString *lrcPath = [[NSBundle mainBundle]pathForResource:[self CurrentPlayingMusic].lrcname ofType:nil];
    NSString *lrcStr = [NSString stringWithContentsOfFile:lrcPath encoding:NSUTF8StringEncoding error:nil];
    NSArray *arr = [lrcStr componentsSeparatedByString:@"\n"];
    
    return [arr copy];
}

/**
 *  获取歌词
 *
 *  @return 返回一个字典数组，字典的key: lrctime表示时间，lrc表示歌词内容
 */
+(NSArray<NSDictionary*> *)getLrc{
    NSArray *completeLrc = [self getCompleteLrc];
    NSMutableArray *mutaArr = [NSMutableArray array];
    for (int i = 0; i<completeLrc.count;i++) {
        NSString *lineStr = completeLrc[i];
        //时间
        if (lineStr.length<=11) {
            continue;
        }
        NSMutableDictionary *lrcDic = [NSMutableDictionary dictionary];
        
        NSString *minute = [lineStr substringWithRange:(NSRange){1,2}];
        NSString *second = [lineStr substringWithRange:(NSRange){4,4}];
        NSTimeInterval time = [minute doubleValue]*60+[second doubleValue];
        [lrcDic setObject:[NSNumber numberWithDouble:time] forKey:@"lrctime"];
        
        
        //歌词
        NSString *musicLrc;
        
        musicLrc = [lineStr substringFromIndex:10];
        
        
        [lrcDic setObject:musicLrc forKey:@"lrc"];
        //加入歌词
        
        [mutaArr addObject:lrcDic];
    }
    return mutaArr;
}
+(void)setCurrentPlayingMusic:(WHMusic*)music{
    if (!music || _playingMusic==music) {
        return;
    }
    _playingMusic = music;
    
}
+(WHMusic*)CurrentPlayingMusic{
    return _playingMusic;
}
+(WHMusic*)nextMusic{
    WHMusic *retMusic;
    for (int i = 0; i<_musicArray.count; i++) {
        if (_playingMusic == _musicArray[i]) {
            retMusic = _musicArray[i==_musicArray.count-1?0:i+1];
        }
    }
    _playingMusic = retMusic;
    return retMusic;
}
+(WHMusic*)previousMusic{
    WHMusic *retMusic;
    for (int i = 0; i<_musicArray.count; i++) {
        if (_playingMusic == _musicArray[i]) {
            retMusic = _musicArray[i==0?_musicArray.count-1:i-1];
        }
    }
    _playingMusic = retMusic;

    return retMusic;
}
@end
