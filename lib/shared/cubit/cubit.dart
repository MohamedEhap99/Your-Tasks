import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archive_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class TodoAppCubit extends Cubit<TodoAppStates>{
  TodoAppCubit(): super(initialState());
 static TodoAppCubit get(context)=>BlocProvider.of(context);
  List<Widget> Screens=[
    New_Tasks_Screen(),
    Done_Tasks_Screen(),
    Archive_Tasks_Screen(),
  ];
  List<String>Titles=[
    'New Tasks',
    'Done Tasks',
    'Archive Tasks',
  ];
  int CurrentIndex=0;
  void ChangeIndex(int index){
    CurrentIndex=index;
    emit(ChangeIndexBottomNavBarState());
  }

  Database? database;
  List<Map> newtasks=[];
  List<Map> donetasks=[];
  List<Map> archivetasks=[];

  void CreateDatabase(){
     openDatabase(
        'todo.db',
        version: 1,
        onCreate:(database,version){
          database.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, time TEXT, date TEXT, status TEXT)').then((value){
            print('table created');
          }).catchError((error){
            print('Error when creating table ${error.toString()}');
          });
        },
        onOpen:(database){
          GetDataFromDatabase(database);
          print('database opened');
        }
    ).then((value){
      database=value;
      emit(CreateDatabaseState());
    });
  }

  InsertToDatabase({
  required String title,
  required String time,
  required String date,
})async{
   await database?.transaction((txn)async{
      txn.rawInsert(
          'INSERT INTO tasks (title, time ,date, status) VALUES ("$title","$time","$date","new")'
      ).then((value){
        print('$value inserted successfully');
        emit(InsertToDatabaseState());
        GetDataFromDatabase(database);
      }).catchError((error){
        print('Error when inserting new record ${error.toString()}');
      });

    }

    );

  }

  void GetDataFromDatabase(database){
     newtasks=[];
     donetasks=[];
     archivetasks=[];
     emit(GetDatabaseLoadingState());
    return  database.rawQuery('SELECT * FROM tasks').then((value){
      value.forEach((element){
        if(element['status']=='new'){
          newtasks.add(element);
        }
        else if(element['status']=='done'){
          donetasks.add(element);
        }
        else{
          archivetasks.add(element);
        }
      });
      emit(GetDataFromDatabaseState());
    });
  }

  bool isBottomSheetShown=false;
  IconData fabIcon=Icons.edit;

  void ChangeBottomSheet({
  required bool isShow,
  required IconData icon,
}){
 isBottomSheetShown=isShow;
 fabIcon=icon;
 emit(ChangeBottomSheetState());
  }

  void UpdateDatabase({
  required String status,
  required int id,
})async{
     database!.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id]).then((value){
          GetDataFromDatabase(database);
      emit(UpdateDatabaseState());
     });

}

void DeleteDataFromDatabase({
  required int id,
}){
  database!.rawDelete('DELETE FROM tasks WHERE id= ?', [id]).then((value){
    GetDataFromDatabase(database);
    emit(DeleteDataFromDatabaseState());
  });

}

}