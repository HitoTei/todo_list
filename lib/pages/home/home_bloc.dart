import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/model/base_bloc.dart';
import 'package:todo_list/model/todo_item.dart';
import 'package:todo_list/pages/create_todo/create_todo_page.dart';
import 'package:todo_list/pages/edit_todo/edit_todo_page.dart';
import 'package:todo_list/pages/todo_detail/todo_detail_page.dart';
import 'package:todo_list/sql/sql_provider.dart';

class HomeBloc extends BaseBloc{
  SqlProvider _sql;

  StreamController<List<TodoItem>> _todoItemListStreamController = StreamController.broadcast();
  StreamSink<List<TodoItem>> get _todoItemListSink => _todoItemListStreamController.sink;

  Stream<List<TodoItem>> get todoItemListStream => _todoItemListStreamController.stream;

  Future<void> requestAllItems() async{
    await Future.delayed(Duration(milliseconds: 10));

    _sql.fetchAllItems().then((itemList){
      itemList.add(TodoItem(detail: 'detail',title: 'title'));
      _todoItemListSink.add(itemList);
    });
  }

  HomeBloc(){
    _sql = SqlProvider();
    requestAllItems();
  }

  void gotoTodoDetailPage(BuildContext context,{TodoItem item}){
    showDialog(
      context: context,
      builder: (_) =>
          SimpleDialog(
            title: Text(item.title),
            children: <Widget>[
              TodoDetailPage(item:item),
            ],
          )
    );
  }

  void gotoEditTodoPage(BuildContext context,{@required TodoItem item}){
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (BuildContext context) {
              return EditTodoPage(item:item);
            }
        )
    );
  }
  void gotoCreateTodoPage(BuildContext context) async{
    await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (BuildContext context) {
              return CreateTodoPage();
            }
        )
    );
  }

  void deleteItem({@required TodoItem item}){
    if(item.id == null)return;
    _sql.deleteItem(id: item.id);
    Future.delayed(Duration(milliseconds: 10)); // 削除しても残っているのはかなり面倒なのでこれだけ特別に更新は自動で行う
    requestAllItems();
  }

  @override
  void dispose(){
    _todoItemListStreamController.close();
  }

}