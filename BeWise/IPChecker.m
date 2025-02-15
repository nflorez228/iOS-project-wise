//
//  IPChecker.m
//  BeWise
//
//  Created by Nicolas Florez on 6/21/17.
//  Copyright © 2017 BEWISE. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include "IPChecker.h"

@implementation IPChecker

+ (NSString *)getIP
{
    NSString *address = @"ip_address_error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *addr = NULL;
    int got = getifaddrs(&interfaces);
    if (got == 0) {
        addr = interfaces;
        while (addr != NULL) {
            if( addr->ifa_addr->sa_family == AF_INET) {
                if ([[NSString stringWithUTF8String:addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)addr->ifa_addr)->sin_addr)];
                }
            }
            
            addr = addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    
    return address;
}
@end
