import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

 defualtFormField({
  required String labeltext,
  required IconData prefixicon,
  required BorderRadius borderradius,
  required BorderSide borderside,
  required TextEditingController Controller,
 required String? Function(String?)? validate,
   void Function()? ontap,

})=>TextFormField(
  decoration:InputDecoration(
    labelText:labeltext,
    prefixIcon:Icon(prefixicon),
    border:OutlineInputBorder(
      borderRadius:borderradius,
      borderSide: borderside,

    ),
  ),
  controller:Controller,
  validator:validate,
    onTap:ontap ,
);


Widget buildTaskItem(Map model, context)=>Dismissible(
  key:Key(model['id'].toString()) ,
  onDismissed:(direction){
    TodoAppCubit.get(context).DeleteDataFromDatabase(id:model['id']);
  },
  child:   Padding(

    padding: const EdgeInsets.all(20.0),

    child: Row(

      children: [

        CircleAvatar(

          radius: 40.0,

          child: Text(

            '${model['time']}',

          ),

        ),

        SizedBox(width: 20.0,),

        Expanded(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            mainAxisSize:MainAxisSize.min,

            children: [

              Text('${model['title']}',

                style:TextStyle(

                  fontWeight:FontWeight.bold,

                  fontSize:18.0,

                ) ,

              ),

              Text('${model['date']}',

                style:TextStyle(

                  color: Colors.grey,

                ) ,

              ),

            ],

          ),

        ),

        SizedBox(width: 20.0,),

         IconButton(

          icon:Icon(

            Icons.check_box,

  color:Colors.green,

          ),

  onPressed: (){

            TodoAppCubit.get(context).UpdateDatabase(

                status: 'done',

                id: model['id'],

            );

          },

         ),

         IconButton(

          icon:Icon(

             Icons.archive,

            color: Colors.black45,

          ),

          onPressed: (){

            TodoAppCubit.get(context).UpdateDatabase(

                status: 'archive',

               id: model['id'],

            );

           },

         ),



      ],

    ),

  ),
);

Widget tasksBuilder({
  required List<Map> tasks,
})=>ConditionalBuilder(
  condition: tasks.length>0,
  builder:(context)=>ListView.separated(
    itemBuilder:(context,index)=>buildTaskItem(tasks[index],context),
    separatorBuilder:(context,index)=>Container(
      width:double.infinity,
      height: 10.0,
      color: Colors.grey[300],
    ) ,
    itemCount: tasks.length,
  ),
  fallback:(context)=>Center(
    child: Column(
      crossAxisAlignment:CrossAxisAlignment.center,
      mainAxisAlignment:MainAxisAlignment.center,
      children: [
        Icon(
          Icons.menu,
          size: 100.0,
          color: Colors.grey,
        ),
        Text(
          'No Tasks Yet, please Add Some Tasks',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),

      ],
    ),
  ),
);
