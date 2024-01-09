import 'package:flutter/material.dart';
import 'package:keka_to_do_list/sqflite/todo_db.dart';
import 'dart:io';
import 'dart:math';

class NavBar extends StatefulWidget {

  final ValueChanged<Map> onSubmit;
  final dynamic createTask;
  final dynamic deleteAll;
  final dynamic renameCategory;
  const NavBar({super.key, required this.onSubmit, required this.createTask, required this.deleteAll, required this.renameCategory});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {

  final todoDB = TodoDB();

  @override
  void initState() {
    fetchCats();
    super.initState();
  }

  List<String> cats = [];

  fetchCats() async {
    var temp = await todoDB.fetchCategories();
    setState(() {
      cats.add("All");
      cats.addAll(temp);
    });
  }

  Widget newTile(String title, String key, dynamic value) {
    return ListTile(
      horizontalTitleGap: 0,
      title: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 17
          ),
        ),
      ),
      onTap: () {
        widget.onSubmit({'key' : key, 'value' : value});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Stack(
            children: [
              FittedBox(
                fit: BoxFit.contain,
                child: Image.asset(
                  "assets/icons/background.jpg",
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  }, 
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black,
                    size: 25,
                  )
                )
              ),
              Positioned(
                left: 20,
                bottom: 25,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image(
                      color: Colors.black,
                      width: MediaQuery.of(context).size.width * 0.15,
                      image: const AssetImage('assets/to-do-list.png'),
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10,),
                    const Text(
                        "To - Do",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 30
                        ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10,),
          ExpansionTile(
            leading: Image.asset(
              "assets/icons/button.png",
              width: 23,
              color: Colors.black,
            ),
            title: const Text(
              "Category",
              style: TextStyle(
                fontSize: 17
              ),
            ),
            children: [
              SizedBox(
                height: min(69.0*cats.length, 275),
                child: ListView.separated(
                  itemCount: cats.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      child: ListTile(
                        horizontalTitleGap: 0,
                        title: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          child: Text(
                            cats[index],
                            style: const TextStyle(
                              fontSize: 17
                            ),
                          ),
                        ),
                        // leading: SizedBox(),
                        onTap: () {
                          widget.onSubmit({'key' : "category", 'value' : cats[index]});
                        },
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Divider(thickness: 0.5, color: Colors.black),
                  ),
                ),
              )
            ]
          ),
          ExpansionTile(
            leading: Image.asset(
              "assets/icons/button.png",
              width: 23,
              color: Colors.black,
            ),
            title: const Text(
              "Priority",
              style: TextStyle(
                fontSize: 17
              ),
            ),
            children: [
              newTile("All", "priority", "All"),
              const Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0), child: Divider(thickness: 0.5, color: Colors.black),) ,
              newTile("Low", "priority", 0),
              const Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0), child: Divider(thickness: 0.5, color: Colors.black),) ,
              newTile("Medium", "priority", 1),
              const Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0), child: Divider(thickness: 0.5, color: Colors.black),) ,
              newTile("High", "priority", 2),
            ]
          ),
          ExpansionTile(
            leading: Image.asset(
              "assets/icons/button.png",
              width: 23,
              color: Colors.black,
            ),
            title: const Text(
              "Status",
              style: TextStyle(
                fontSize: 17
              ),
            ),
            children: [
              newTile("All", "status", "All"),
              const Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0), child: Divider(thickness: 0.5, color: Colors.black),) ,
              newTile("New", "status", 0),
              const Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0), child: Divider(thickness: 0.5, color: Colors.black),) ,
              newTile("In Progress", "status", 1),
              const Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0), child: Divider(thickness: 0.5, color: Colors.black),) ,
              newTile("Completed", "status", 2),
            ]
          ),
          ListTile(
            horizontalTitleGap: 15,
            title: const Text(
              'Create New Task',
              style: TextStyle(
                fontSize: 17
              ),
            ),
            leading: const Icon(
              Icons.task_alt_rounded,
              color: Colors.green,
            ),
            onTap: () {
              widget.createTask();
            },
          ),
          ListTile(
            horizontalTitleGap: 15,
            title: const Text(
              'Rename a Category',
              style: TextStyle(
                fontSize: 17
              ),
            ),
            leading: Image.asset(
              "assets/icons/pencils.png",
              width: 23,
              color: Colors.black,
            ),
            onTap: () {
              widget.renameCategory();
            },
          ),
          ListTile(
            horizontalTitleGap: 15,
            title: const Text(
              'Delete all Tasks',
              style: TextStyle(
                fontSize: 17
              ),
            ),
            leading: Image.asset(
              "assets/icons/cross.png",
              width: 23,
              color: Colors.red,
            ),
            onTap: () {
              widget.deleteAll();
            }
          ),
          ListTile(
            horizontalTitleGap: 15,
            title: const Text(
              'Exit',
              style: TextStyle(
                fontSize: 17
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
              child: Image.asset(
                "assets/icons/logout.png",
                width: 23,
                color: Colors.blue,
              ),
            ),
            onTap: () {
              exit(0);
            },
          ),
        ],
      ),
    );
  }
}