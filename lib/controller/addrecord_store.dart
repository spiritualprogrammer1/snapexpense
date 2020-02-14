import 'dart:async';
import 'dart:io';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snapexpenses/model/addrecord_moor.dart';
part 'addrecord_store.g.dart';

class AddRecordController = _AddRecordController with _$AddRecordController;

abstract class _AddRecordController with Store {
  SnapExpenseDatabase db;

  StreamController<List<Addrecord>> _streamController;

  @observable
  ObservableStream<List<Addrecord>> recordStream;

  @observable
  DateTime dateset;

  _AddRecordController() {
    db = SnapExpenseDatabase();
    _streamController = StreamController<List<Addrecord>>();
    filterAllRecord;
    recordStream = ObservableStream(_streamController.stream);
  }

  //time filter
  bool _timestampFilter(DateTime timestamp, DateTime newtimestamp,
      {int filterType = 0}) {
    //special condtion if new date is null return all data so always return true
    if(newtimestamp==null)
      return true;
    //fitertype 0-days, 1 - month, 2 -year
    if (filterType == 0) if (timestamp.day == newtimestamp.day &&
        timestamp.year == newtimestamp.year &&
        timestamp.month == newtimestamp.month)
      return true;
    else
      return false;
    else if (filterType == 1) if (timestamp.year == newtimestamp.year &&
        timestamp.month == newtimestamp.month)
      return true;
    else
      return false;
    else if (timestamp.year == newtimestamp.year)
      return true;
    else
      return false;
  }

  @computed
  void get filterAllRecord {
    print(dateset);
    db.watchAllRecords().listen((d) {
      final newRecord = d.where((test) {
        return _timestampFilter(test.timestamp, dateset);
      }).toList();
      print(newRecord);
      _streamController.add(newRecord);
    });
  }
  
  @action
  void filterDate(DateTime mydate){
    dateset=mydate;
  }
  @action
  filterFakeId() {
    dateset=DateTime.now();
    //filterAllRecord;
    // print(await db.getRecords);
    //id = 9;
    //print(recordStream);
    // recordStream=recordStream.map((e){
    //   print(e.toList().toString());
    //   e.where((test)=>test.id==9);
    // });
    // print(await recordStream);
    // _streamController.close();
    //db.watchAllRecords().listen((d){
    //recordStream=ObservableStream(d.where((condition)=>condition.id==9).toList().stream);
    // print(d.where((condition)=>condition.id==9).toList());
    // });
    // _streamController1 = StreamController<List<Addrecord>>();
    //  _streamController1.addStream(db.watchAllRecords());
    // recordStream =  ObservableStream(_streamController1.stream);
    //recordList=ObservableFuture(db.getRecords);
    //recordList= ObservableList(db.getRecords.then((v)=>v.where((c)=>c.id==9).toList()));
    // await _streamController.close();
    // print("fake action");
    // print(await recordList);
    //list = await ObservableFuture(recordList.then((v)=>v.where((c)=>c.id==9).toList()));  ///this is way to filter deep array of object
    //print(await recordList);
  }
  @computed
  bool get state{
   // print(recordStream.status);
   //return true;
    // if(recordStream==null){
    //   return true;
    // }else 
    if(recordStream.status==StreamStatus.waiting)
    {
      return true;
      }else{
        return false;
      }
  }

  @computed
  Future<String> get getFilePath async {
    //the path where file is created
    Directory dir = await getExternalStorageDirectory();
    print(dir.path);
    String appPath = '${dir.path}/Pictures/';
    await Directory(appPath).create(recursive: true);
    return appPath;
  }

  @action
  Future<bool> uploadFile(File f) async {
    final file = File(await getFilePath + basename(f.path));
    print(file.path);
    var img = f.readAsBytesSync();
    file.writeAsBytesSync(img);
    print("file upload");
    return true;
  }

  @action
  Future insertRecord(Addrecord newrecord) async {
    return await db.insertRecords(newrecord);
  }

  @action
  Future<bool> deleteRecord(Addrecord oldrecord) async {
    int status = await db.deleteRecords(oldrecord);
    if (status > 0) {
      return true;
    } else
      return false;
  }

  @action
  Future<bool> updateRecord(Addrecord updaterecord) async {
    bool status = await db.updateRecords(updaterecord);
    if (status) {
      return true;
    } else
      return false;
  }

  void dispose() async {
    //await _streamController.close();
  }
}
