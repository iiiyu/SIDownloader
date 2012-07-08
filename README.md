---
layout: post
title: "iOS笔记(8)"
date: 2012-07-07 21:15
comments: true
categories: iOS
---


# iOS笔记 基于MKNetworkKit的断点续传

## 背景
上次写过用ASIHTTPRequest做断点续传的例子。但是一个是写的比较搓。一个是ASIHTTPRequest库已经不在维护。最后是扩展性不是很好。所以花了很长时间改写用MKNetworkKit来写。

如果需要回顾一下ASIHTTPRequest的断点续传的在[这里](http://www.iiiyu.com/blog/2012/04/25/learning-ios-notes-six/)


<!--more-->

## MKNetworkKit

下载地址是

	https://github.com/MugunthKumar/MKNetworkKit

作者本人的臭屁介绍在[这里](http://blog.mugunthkumar.com/products/ios-framework-introducing-mknetworkkit/)

### 使用MKNetworkKit
1. 首先把clone下来的MKNetworkKit文件夹拖进你的项目里面
2. 到项目里面增加CFNetwork.Framework SystemConfiguration.framework 和 Security.framework.
3. 把MKNetworkKit.h包含到你的pch文件里面。
4. 如果是iOS，删除NSAlert+MKNetworkKitAdditions.h这个文件
5. 如果是Mac，删除UIAlertView+MKNetworkKitAdditions.h这个文件

这样，再看看[介绍](http://blog.mugunthkumar.com/products/ios-framework-introducing-mknetworkkit/)里面的例子。应该就能看懂普通用法了。然后畅快的使用MKNetworkKit库了。


## 改写目标
上次写的ASIHTTPRequest续传其实已经可以用了。但是为什么需要重新写呢。就是重用！！！

一直都很少自己设计接口什么的。其实只是做了写体力的劳动，把一堆逻辑换成代码给堆了起来。觉得没有人会去重用自己的代码。很少去花心思想怎么样才能写好。

这次改写就只有一个目标，为了更好更多人能使用断点续传来下载。

## 功能

### 下载持久化
下载的持久化的微观含义是在push到新的view或者pop出当前view。下载应该在后台继续进行。
宏观含义是按home把程序放入后台以后，下载继续进行。

### 保持进度条
每次进入下载的view的时候progressview都应该保持一致

### 暂停恢复下载
可以随时暂停下载和恢复下载

这次改写，这些功能都实现了，啊哈哈哈。

## 实现

### MKNetworkKit库修改
最开始使用MKNetworkKit库做下载的时候，progressview的数值一直不对。经过boss的观察，应该是某个东西写错地方了。然后 修改了某两个函数才可以的。详细如下：
找到MKNetworkOperation.m文件
``` objc
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
 
  NSUInteger size = [self.response expectedContentLength] < 0 ? 0 : [self.response expectedContentLength];
  self.response = (NSHTTPURLResponse*) response;
 
  // dont' save data if the operation was created to download directly to a stream.
  if([self.downloadStreams count] == 0)
    self.mutableData = [NSMutableData dataWithCapacity:size];
  else
    self.mutableData = nil;
 
  for(NSOutputStream *stream in self.downloadStreams)
    [stream open];
 
  NSDictionary *httpHeaders = [self.response allHeaderFields];
 
  // if you attach a stream to the operation, MKNetworkKit will not cache the response.
  // Streams are usually "big data chunks" that doesn't need caching anyways.
 
  if([self.request.HTTPMethod isEqualToString:@"GET"] && [self.downloadStreams count] == 0) {
   
    // We have all this complicated cache handling since NSURLRequestReloadRevalidatingCacheData is not implemented
    // do cache processing only if the request is a "GET" method
    NSString *lastModified = [httpHeaders objectForKey:@"Last-Modified"];
    NSString *eTag = [httpHeaders objectForKey:@"ETag"];
    NSString *expiresOn = [httpHeaders objectForKey:@"Expires"];
   
    NSString *contentType = [httpHeaders objectForKey:@"Content-Type"];
    // if contentType is image,
   
    NSDate *expiresOnDate = nil;
   
    if([contentType rangeOfString:@"image"].location != NSNotFound) {
     
      // For images let's assume a expiry date of 7 days if there is no eTag or Last Modified.
      if(!eTag && !lastModified)
        expiresOnDate = [[NSDate date] dateByAddingTimeInterval:kMKNetworkKitDefaultImageCacheDuration];
      else   
        expiresOnDate = [[NSDate date] dateByAddingTimeInterval:kMKNetworkKitDefaultImageHeadRequestDuration];
    }
   
    NSString *cacheControl = [httpHeaders objectForKey:@"Cache-Control"]; // max-age, must-revalidate, no-cache
    NSArray *cacheControlEntities = [cacheControl componentsSeparatedByString:@","];
   
    for(NSString *substring in cacheControlEntities) {
     
      if([substring rangeOfString:@"max-age"].location != NSNotFound) {
       
        // do some processing to calculate expiresOn
        NSString *maxAge = nil;
        NSArray *array = [substring componentsSeparatedByString:@"="];
        if([array count] > 1)
          maxAge = [array objectAtIndex:1];
       
        expiresOnDate = [[NSDate date] dateByAddingTimeInterval:[maxAge intValue]];
      }
      if([substring rangeOfString:@"no-cache"].location != NSNotFound) {
       
        // Don't cache this request
        expiresOnDate = [[NSDate date] dateByAddingTimeInterval:kMKNetworkKitDefaultCacheDuration];
      }
    }
   
    // if there was a cacheControl entity, we would have a expiresOnDate that is not nil.       
    // "Cache-Control" headers take precedence over "Expires" headers
   
    expiresOn = [expiresOnDate rfc1123String];
   
    // now remember lastModified, eTag and expires for this request in cache
    if(expiresOn)
      [self.cacheHeaders setObject:expiresOn forKey:@"Expires"];
    if(lastModified)
      [self.cacheHeaders setObject:lastModified forKey:@"Last-Modified"];
    if(eTag)
      [self.cacheHeaders setObject:eTag forKey:@"ETag"];
  }
   
    if ([self.mutableData length] == 0 || [self.downloadStreams count] > 0) {
        // This is the first batch of data
        // Check for a range header and make changes as neccesary
        NSString *rangeString = [[self request] valueForHTTPHeaderField:@"Range"];
        if ([rangeString hasPrefix:@"bytes="] && [rangeString hasSuffix:@"-"]) {
            NSString *bytesText = [rangeString substringWithRange:NSMakeRange(6, [rangeString length] - 7)];
            self.startPosition = [bytesText integerValue];
            self.downloadedDataSize = self.startPosition;
            DLog(@"Resuming at %d bytes", self.startPosition);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
 

 
  if([self.downloadStreams count] == 0)
    [self.mutableData appendData:data];
 
  for(NSOutputStream *stream in self.downloadStreams) {
   
    if ([stream hasSpaceAvailable]) {
      const uint8_t *dataBuffer = [data bytes];
      [stream write:&dataBuffer[0] maxLength:[data length]];
    }       
  }
 
  self.downloadedDataSize += [data length];
 
  for(MKNKProgressBlock downloadProgressBlock in self.downloadProgressChangedHandlers) {
   
    if([self.response expectedContentLength] > 0) {
     
      double progress = (double)(self.downloadedDataSize) / (double)(self.startPosition + [self.response expectedContentLength]);
      downloadProgressBlock(progress);
    }       
  }
}
```

具体改了哪，忘记了。有心思对照源码看看。应该是属于MKNetworkKit的bug。也不知道新版改过来没有。但是你clone我的demo，这个版本是可以的。

## 断点下载库
其实我一共就写了两个简单的类而已。

基础的是SIBreakpointsDownload。继承于MKNetworkOperation。判断了续传的位置。

一个SIDownloadManager写成单例，继承于MKNetworkEngine。用来管理多任务下载。

使用的时候就只用SIDownloadManager这个类来添加下载，暂停下载。然后想在下载的前后、出错时候、progressview改变时候对view作出改变。就实现它的delegate就好了。

demo地址

	git@github.com:iiiyu/SIDownloader.git
	
其实已经很简单了，照着demo改改就能自己用了。

## 总结
这次改写以后，代码结构变的很清晰。复杂性和耦合性都有所降低。可用性提高。而且，反正我是没有google到可以直接拿来用的断点下载库。这次娃哈哈就有了。然后blog也2月没有更新，鄙视自己。以后应该会慢慢更新恢复正常。最后，希望对大家有所帮助。


	
	
