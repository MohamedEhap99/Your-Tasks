import 'dart:io';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class Home_Layout extends StatelessWidget{
  var titleController=TextEditingController();
  var timeController=TextEditingController();
  var dateController=TextEditingController();
 var scaffoldKey=GlobalKey<ScaffoldState>();
 var formkey=GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
   return BlocProvider(
     create: (BuildContext context)=>TodoAppCubit()..CreateDatabase(),
     child: BlocConsumer<TodoAppCubit,TodoAppStates>(
       listener: (BuildContext context, state) {
          if(state is InsertToDatabaseState){
            Navigator.pop(context);
          }
       },
       builder: (BuildContext context, Object? state) {
         TodoAppCubit Cubit=TodoAppCubit.get(context);
         return  Scaffold(
           key: scaffoldKey,
         appBar: AppBar(
           title: Text(Cubit.Titles[Cubit.CurrentIndex]),
         ),
         body:ConditionalBuilder(
             condition:state is ! GetDatabaseLoadingState ,
           builder:(context)=>Cubit.Screens[Cubit.CurrentIndex],
             fallback:(context)=>Center(child: CircularProgressIndicator()),
         ) ,
         floatingActionButton:Platform.isIOS?Container():FloatingActionButton(
           onPressed: (){
             if(Cubit.isBottomSheetShown){
               if(formkey.currentState!.validate()){
                 Cubit.InsertToDatabase(
                     title:titleController.text,
                   time:timeController.text,
                     date: dateController.text,
                 ).then((value){
                   Navigator.pop(context);
                   titleController.clear();
                   timeController.clear();
                   dateController.clear();
                   Cubit.ChangeBottomSheet(
                       isShow: false,
                       icon:Icons.edit,
                   );
                 });

               }

             }
             else{
               scaffoldKey.currentState?.showBottomSheet(
                     (context) =>Container(
                         child: Form(
                           key:formkey ,
                           child: Column(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               defualtFormField(
                                   labeltext: 'Task Title',
                                   prefixicon: Icons.title,
                                   borderradius: BorderRadius.circular(2.0),
                                   borderside: BorderSide(width: 2.0),
                                   Controller: titleController,
                                   validate:(String?value){
                                     if(value!.isEmpty){
                                       return'required';
                                     }
                                     return null;
                                   }
                               ),
                               SizedBox(height:15.0,),
                               defualtFormField(
                                   labeltext: 'Task Time',
                                   prefixicon: Icons.watch_later_outlined,
                                   borderradius: BorderRadius.circular(2.0),
                                   borderside: BorderSide(width: 2.0),
                                   Controller: timeController,
                                   validate:(String?value){
                                     if(value!.isEmpty){
                                       return'required';
                                     }
                                     return null;
                                   },
                                   ontap:(){
                                     showTimePicker(
                                         context: context,
                                         initialTime:TimeOfDay.now(),
                                     ).then((value){
                                       timeController.text=value!.format(context).toString();
                                       print(value.format(context));
                                     });
                                         }
                               ),
                               SizedBox(height:15.0,),
                               defualtFormField(
                                   labeltext: 'Task Date',
                                   prefixicon: Icons.calendar_today,
                                   borderradius: BorderRadius.circular(2.0),
                                   borderside: BorderSide(width: 2.0),
                                   Controller: dateController,
                                   validate:(String?value){
                                     if(value!.isEmpty){
                                       return'required';
                                     }
                                     return null;
                                   },
                                 ontap:(){
                                     showDatePicker(
                                         context: context,
                                         initialDate: DateTime.now(),
                                         firstDate: DateTime.now(),
                                         lastDate:DateTime.parse('2022-05-03'),
                                     ).then((value){
                                       dateController.text=DateFormat.yMMMd().format(value!);
                                     });
                                 }
                               ),

                             ],
                           ),
                         ),
                       ),

               ).closed.then((value){
                 Cubit.ChangeBottomSheet(
                     isShow:false ,
                     icon:Icons.edit,
                 );
               });
              Cubit.ChangeBottomSheet(
                  isShow:true ,
                  icon:Icons.add ,
              );
             }
           },
           child:Icon(Cubit.fabIcon),
         ),
         bottomNavigationBar:BottomNavigationBar(
           items: [
             BottomNavigationBarItem(
               icon:Icon(Icons.menu),
               label:'Tasks',
             ),
             BottomNavigationBarItem(
               icon:Icon(Icons.check_circle_outline),
               label: 'Done',
             ),
             BottomNavigationBarItem(
               icon:Icon(Icons.archive_outlined),
               label: 'Archive',
             ),
           ],
           currentIndex:Cubit.CurrentIndex ,
           onTap:(index){
             Cubit.ChangeIndex(index);
           } ,
         ),
       );
       },

     ),
   );
  }


}