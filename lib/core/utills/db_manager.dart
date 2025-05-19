import 'dart:convert';

import 'package:cartie/core/utills/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';


class DbManager {
  bool _isDbUpdateRunning = false;
  bool _isDbUpdatePending = false;
  late Box cache;
  late Box pendingCache;

  static final DbManager _instance = DbManager._privateConstructor();
  DbManager._privateConstructor();

  factory DbManager() {
    return _instance;
  }

  Future<Box> initCacheUsingName(String name) async {
    return await Hive.openBox(name);
  }

  void disposeCache(Box box) {
    box.close();
  }

  Future triggerDeltaRefresh() async {
    if (_isDbUpdateRunning) {
      _isDbUpdatePending = true;
    } else {
      _updateLocalCache();
    }
  }

  Future _updateLocalCache() async {
    _isDbUpdateRunning = true;

    // try {
    //   DateTime time = DateTime.now().toUtc();
    //   var updateResponse = await UpdateAPIs().getNewUpdates();
    //   if (updateResponse.success) {
    //     bool allSuccess = true;
    //     for (DbUpdate update in updateResponse.data) {
    //       String entityType = update.entityType;
    //       if (entityType == "LeadDetailsEntity") {
    //         //call lead getall API
    //         var entityGetResponse = await LeadAPIs().getLeadDetails(
    //             update.rowKeyOfUpdatedEntity,
    //             foreceRefresh: true);
    //         if (!entityGetResponse.success) {
    //           if (kDebugMode) {
    //             print("GetLeadDetails failed during background update");
    //           }
    //           allSuccess = false; //Todo handle failure at inidividual level
    //         }
    //       }
    //     }
    //     if (allSuccess) {
    //       await UpdateAPIs().updateLastRefreshedToken(time);
    //     }
    //   } else {
    //     if (kDebugMode) {
    //       print(
    //           "Failure in getting updates from server. Error message - ${updateResponse.message}");
    //     }
    //     //do nothing, updates could be fetched next time when server informs about update
    //   }
    //   if (_isDbUpdatePending) {
    //     _isDbUpdatePending = false;
    //     await _updateLocalCache();
    //   }
    // } on Exception catch (_, e) {
    //   if (kDebugMode) {
    //     print(e);
    //   }
    // }
    // _isDbUpdateRunning = false;
  }

  //to be called on logout
  Future<void> deleteFullLocalCache() async {
    await Hive.deleteFromDisk();

    //init again for continued use
    cache = await DbManager().initCacheUsingName(localCacheName);
    pendingCache = await DbManager().initCacheUsingName(localPendingCacheName);
  }

 
}
