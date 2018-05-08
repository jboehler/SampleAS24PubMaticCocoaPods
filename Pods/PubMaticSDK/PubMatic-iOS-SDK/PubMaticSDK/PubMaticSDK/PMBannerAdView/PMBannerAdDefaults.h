/*
 
 * PubMatic Inc. ("PubMatic") CONFIDENTIAL
 
 * Unpublished Copyright (c) 2006-2017 PubMatic, All Rights Reserved.
 
 *
 
 * NOTICE:  All information contained herein is, and remains the property of PubMatic. The intellectual and technical concepts contained
 
 * herein are proprietary to PubMatic and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret or copyright law.
 
 * Dissemination of this information or reproduction of this material is strictly forbidden unless prior written permission is obtained
 
 * from PubMatic.  Access to the source code contained herein is hereby forbidden to anyone except current PubMatic employees, managers or contractors who have executed
 
 * Confidentiality and Non-disclosure agreements explicitly covering such access.
 
 *
 
 * The copyright notice above does not evidence any actual or intended publication or disclosure  of  this source code, which includes
 
 * information that is confidential and/or proprietary, and is a trade secret, of  PubMatic.   ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE,
 
 * OR PUBLIC DISPLAY OF OR THROUGH USE  OF THIS  SOURCE CODE  WITHOUT  THE EXPRESS WRITTEN CONSENT OF PubMatic IS STRICTLY PROHIBITED, AND IN VIOLATION OF APPLICABLE
 
 * LAWS AND INTERNATIONAL TREATIES.  THE RECEIPT OR POSSESSION OF  THIS SOURCE CODE AND/OR RELATED INFORMATION DOES NOT CONVEY OR IMPLY ANY RIGHTS
 
 * TO REPRODUCE, DISCLOSE OR DISTRIBUTE ITS CONTENTS, OR TO MANUFACTURE, USE, OR SELL ANYTHING THAT IT  MAY DESCRIBE, IN WHOLE OR IN PART.
 
 */

//
//  PMDefaults.h
//   PMBannerAdView 
//

//
#import <Foundation/Foundation.h>

#ifndef  PMBannerAdView_PMDefaults_h
#define  PMBannerAdView_PMDefaults_h

//
// Timeout for various network requests.
//
static NSTimeInterval PM_DEFAULT_NETWORK_TIMEOUT __attribute__((unused)) = 5;

//
// Default injection HTML for rich media ads.
//
// IMPORTANT:
//  This string is a format specifier and uses %@ for parameters.
//  The first parameter represens the ad content.
//  DO NOT change the order or inclusion of these parameters.
//
static NSString* PM_RICHMEDIA_FORMAT __attribute__((unused)) = @"<html><head><meta name=\"viewport\" content=\"user-scalable=0;\"/><style>*:not(input){-webkit-touch-callout:none;-webkit-user-select:none;-webkit-text-size-adjust:none;}body{margin:0;padding:0;}</style></head><body><div align=\"center\">%@</div></body></html>";

static NSString* PM_RICHMEDIA_FORMAT_WITHMRAIDJS __attribute__((unused)) = @"<html><head><meta name=\"viewport\" content=\"user-scalable=0;\"/><style>*:not(input){-webkit-touch-callout:none;-webkit-text-size-adjust:none;}body{margin:0;padding:0;}</style><script type=\"text/javascript\">console={},console.log=function(e){var n=document.createElement('IFRAME');n.setAttribute('src','console://localhost?'+e),document.documentElement.appendChild(n),n.parentNode.removeChild(n),n=null},console.debug=console.log,console.info=console.log,console.warn=console.log,console.error=console.log,window.mraid_init=function(){console.log('mraid_init');var e=window.mraid={};e.returnResult=function(e){return e().toString()},e.returnInfo=function(e){var n='',o=e();for(property in o)n&&(n+='&'),n+=encodeURIComponent(property)+'='+encodeURIComponent(o[property]);return n},e.nativeInvoke=function(e){var n=document.createElement('IFRAME');n.setAttribute('src',e),document.documentElement.appendChild(n),n.parentNode.removeChild(n),n=null};var n=e.EVENTS={READY:'ready',ERROR:'error',STATE_CHANGE:'stateChange',VIEWABLE_CHANGE:'viewableChange',SIZE_CHANGE:'sizeChange'},o={};e.addEventListener=function(e,n){console.log('addEventListener');var t=o[e];t||(o[e]=[],t=o[e]);for(var r=0;r<t.length;++r)if(n===t[r])return;t.push(n)},e.removeEventListener=function(e,n){console.log('removeEventListener');var t=o[e];t&&(n?delete t[n]:o[e]=null)},e.fireChangeEvent=function(e,n){console.log('fireChangeEvent handler:'+e+' with:'+n);var t=o[e];if(t)for(var r=0;r<t.length;++r)console.log('fireChangeEvent invoked handler'),t[r](n)},e.fireErrorEvent=function(e,t){console.log('fireErrorEvent handler:'+e+' action:'+t);var r=o[n.ERROR];if(r)for(var i=0;i<r.length;++i)r[i](e,t)},e.fireEvent=function(e){console.log('fireEvent handler:'+e);var n=o[e];if(n)for(var t=0;t<n.length;++t)n[t]()},e.getVersion=function(){return console.log('getVersion'),'2.0'};var t=(e.FEATURES={SMS:'sms',TEL:'tel',CALENDAR:'calendar',STORE_PICTURE:'storePicture',INLINE_VIDEO:'inlineVideo'},{});e.setSupports=function(e,n){t[e]=n},e.supports=function(e){return console.log('supports'),t[e]};var r=e.STATES={LOADING:'loading',DEFAULT:'default',EXPANDED:'expanded',RESIZED:'resized',HIDDEN:'hidden'},i=r.LOADING;e.setState=function(o){var t=i!=o;i=o,t?e.fireChangeEvent(n.STATE_CHANGE,i):i===r.RESIZED&&e.fireChangeEvent(n.STATE_CHANGE,i)},e.getState=function(){return console.log('getState'),i};var a=e.PLACEMENT_TYPES={INLINE:'inline',INTERSTITIAL:'interstitial'},s=a.INLINE;e.setPlacementType=function(e){s=e},e.getPlacementType=function(){return console.log('getPlacementType'),s};var l=!1;e.setViewable=function(o){var t=l!=o;l=o,t&&e.fireChangeEvent(n.VIEWABLE_CHANGE,l)},e.isViewable=function(){return console.log('isViewable'),l},e.open=function(n){console.log('open');var o='mraid://open?url='+encodeURIComponent(n);e.nativeInvoke(o)},e.close=function(){console.log('close');var n='mraid://close';e.nativeInvoke(n)},e.playVideo=function(n){console.log('playVideo');var o='mraid://playVideo?url='+encodeURIComponent(n);e.nativeInvoke(o)};var c={width:0,height:0,useCustomClose:!1,isModal:!0};e.setExpandProperties=function(n){console.log('setExpandProperties');var o=['width','height','useCustomClose'];for(wf in o){var t=o[wf];void 0!==n[t]&&(c[t]=n[t])}var r='mraid://setExpandProperties?'+e.returnInfo(e.getExpandProperties);e.nativeInvoke(r)},e.getExpandProperties=function(){return console.log('getExpandProperties'),c},e.useCustomClose=function(n){console.log('useCustomClose');var o={useCustomClose:n};e.setExpandProperties(o)},e.expand=function(n){console.log('expand');var o='mraid://expand';n&&(o+='?url='+encodeURIComponent(n)),e.nativeInvoke(o)};var u=e.RESIZE_PROPERTIES_CUSTOM_CLOSE_POSITION={TOP_LEFT:'top-left',TOP_RIGHT:'top-right',CENTER:'center',BOTTOM_LEFT:'bottom-left',BOTTOM_RIGHT:'bottom-right'},v={width:0,height:0,customClosePosition:u.TOP_RIGHT,offsetX:0,offsetY:0,allowOffscreen:!1};e.setResizeProperties=function(n){console.log('setResizeProperties');var o=['width','height','customClosePosition','offsetX','offsetY','allowOffscreen'];for(wf in o){var t=o[wf];void 0!==n[t]&&(v[t]=n[t])}var r='mraid://setResizeProperties?'+e.returnInfo(e.getResizeProperties);e.nativeInvoke(r)},e.getResizeProperties=function(){return console.log('getResizeProperties'),v},e.resize=function(){console.log('resize');var n='mraid://resize';e.nativeInvoke(n)};var f=e.ORIENTATION_PROPERTIES_FORCE_ORIENTATION={PORTRAIT:'portrait',LANDSCAPE:'landscape',NONE:'none'},d={allowOrientationChange:!0,forceOrientation:f.NONE};e.setOrientationProperties=function(n){console.log('setOrientationProperties');var o=['allowOrientationChange','forceOrientation'];for(wf in o){var t=o[wf];void 0!==n[t]&&(d[t]=n[t])}var r='mraid://setOrientationProperties?'+e.returnInfo(e.getOrientationProperties);e.nativeInvoke(r)},e.getOrientationProperties=function(){return console.log('getOrientationProperties'),d};var g={x:0,y:0,width:0,height:0},E={width:0,height:0},p={x:0,y:0,width:0,height:0},h={width:0,height:0};e.setCurrentPosition=function(t){var r=e.getSize();g=t;var i=e.getSize();if(r.width!==i.width||r.height!==i.height){var a=o[n.SIZE_CHANGE];if(a)for(var s=g.width,l=g.height,c=0;c<a.length;++c)a[c](s,l)}},e.getCurrentPosition=function(){console.log('getCurrentPosition');var n='mraid://updateCurrentPosition';return e.nativeInvoke(n),g},e.getSize=function(){console.log('getSize');var e={width:g.width,height:g.height};return e},e.setMaxSize=function(e){E=e},e.getMaxSize=function(){return console.log('getMaxSize'),E},e.setDefaultPosition=function(e){p=e},e.getDefaultPosition=function(){return console.log('getDefaultPosition'),p},e.setScreenSize=function(e){h=e},e.getScreenSize=function(){return console.log('getScreenSize'),h},e.storePicture=function(n){console.log('storePicture');var o='mraid://storePicture?url='+encodeURIComponent(n);e.nativeInvoke(o)},e.createCalendarEvent=function(n){console.log('createCalendarEvent');var o='mraid://createCalendarEvent?event='+encodeURIComponent(JSON.stringify(n));e.nativeInvoke(o)},e.nativeInvoke('mraid://init')},window.mraid||window.mraid_init();</script></head><div align=\"center\">%@</div></html>";


#endif
