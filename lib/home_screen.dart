import 'package:flutter/material.dart';
import 'package:keka_to_do_list/pages/widgets.dart';
import 'package:keka_to_do_list/pages/nav_bar.dart';
import 'package:keka_to_do_list/Todo.dart';
import 'package:keka_to_do_list/sqflite/todo_db.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {

  Future<List<Todo>>? futureTodos;
  final todoDB = TodoDB();
  List<String> cats = [];

  @override
  void initState() {
    super.initState();
    fetchTodos();
    fetchCats();
  }

  void fetchCats() async {
    var temp = await todoDB.fetchCategories();
    setState(() {
      cats = temp;
    });
  }

  void fetchTodos() {
    setState(() {
      futureTodos = todoDB.fetchAll();
    });
  }

  bool searchBar = false;
  Map filters = {
    "searchValue" : "",
    "category" : "All",
    "priority" : "All",
    "status" : "All"
  };

  @override
  Widget build(BuildContext context) {
    fetchCats();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black
        ),
        flexibleSpace: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.15,),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: double.infinity,
                        curve: Curves.easeInOut,
                        height: searchBar ? 40 : 0,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: searchBar ? 1 : 0,
                          child: TextField(
                            onTapOutside: (event) {
                              final FocusScopeNode currentScope = FocusScope.of(context);
                              if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              }
                            },
                            onChanged: (value) {
                              setState(() {
                                filters['searchValue'] = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: "Search Title",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.grey
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.grey
                                ),
                              ),
                            ),
                          ),
                        )
                      ),
                    ),
                  )
                ),
                IconButton(
                  icon: Image.asset(
                    searchBar ? "assets/icons/close.png" : "assets/icons/search-interface-symbol.png",
                    width: searchBar ? 20 : 24,
                  ),
                  onPressed: () {
                    setState(() {
                      filters['searchValue'] = "";
                      searchBar = !searchBar;
                    });
                  },
                ),
                const SizedBox(width: 5,)
              ],
            ),
          ),
        ),
      ),
      drawer: NavBar(
        onSubmit: (value) {
          filters = {
            "searchValue" : "",
            "category" : "All",
            "priority" : "All",
            "status" : "All"
          };
          setState(() {
            filters[value['key']] = value['value'];
            Navigator.of(context).pop();
          });
        },
        createTask: () {
          Navigator.of(context).pop();
          showDialog(
            barrierDismissible: false,
            context: context, 
            builder: (_) => CreateTodoWidget(
              onSubmit: (data) async {
                await todoDB.create(title: data['title'], description: data['description'], dueDate: data['dueDate'], createdDate: DateTime.now().toString(), deletedDate: "Pending...", priority: data['priority'], category: data['category']);
                if(!mounted) return;
                fetchTodos();
                Navigator.of(context).pop();
              },
            ),
          );
        },
        deleteAll: () async {
          var result = await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
                actionsPadding: const EdgeInsets.fromLTRB(0, 10, 25, 10),
                title: const Center(
                  child: Text(
                    "Confirmation",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  )
                ),
                content: const Text("""All Tasks will be Removed.
  Do you want to proceed?"""),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('OK'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              );
            },
          );

          if (result != null && result) {
            todoDB.deleteTable('todos');
            fetchTodos();
          }
        },
        renameCategory: () async {
          final catController = TextEditingController();
          final newCatController = TextEditingController();
          var result = await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return cats.isEmpty ? AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: const Center(
                  child: Text(
                    "Rename a Category",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  )
                ),
                contentPadding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
                actionsPadding: const EdgeInsets.fromLTRB(0, 10, 25, 10),
                content: const Text("There are no Categories!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('OK'),
                  ),
                ],
              )
              : AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
                actionsPadding: const EdgeInsets.fromLTRB(0, 10, 25, 10),
                title: const Center(
                  child: Text(
                    "Rename a Category",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  )
                ),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DropdownMenu(
                        initialSelection: cats[0],
                        width: MediaQuery.of(context).size.width*0.7,
                        label: const Text(
                          "Categories",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2
                          ),
                        ),
                        dropdownMenuEntries: cats.map((e) => DropdownMenuEntry(value: e, label: e)).toList(),
                        onSelected: (value) {
                          setState(() {
                            catController.text = value ?? "";
                          });
                        },
                      ),
                      const SizedBox(height: 10,),
                      TextFormField(
                        controller: newCatController,
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        decoration: const InputDecoration(
                          labelText: 'New Category Name',
                          border : OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )
                        ),
                        validator: (value) => value != null && value.isEmpty ? "New Category Name is Required" : null,
                      )
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('OK'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              );
            },
          );

          if (result != null && result) {
            if(catController.text == ""){
              catController.text = cats[0];
            }
            todoDB.renameCategory(prevCat: catController.text, newCat: newCatController.text);
            fetchTodos();
          }
        }
      ),
      
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<List<Todo>>(
              future: futureTodos,
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator(),);
                }else{
                  final todos = snapshot.data!;
                  Map catFreq = {};
                  catFreq["All"] = 0;
                  for(final todo in todos){
                    catFreq["All"] = (catFreq["All"] ?? 0) + 1;
                    catFreq[todo.data['category']] = (catFreq[todo.data['category']] ?? 0) + 1;
                  }
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 5, 0, 5),
                          child: Text(
                            "CATEGORIES",
                            style: TextStyle(
                              letterSpacing: 2.0,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.12,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final MapEntry<dynamic, dynamic> entry = catFreq.entries.elementAt(index);
                              
                              return Padding(
                                padding: const EdgeInsets.all(10),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      filters['category'] = entry.key;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: filters['category'] == entry.key ? Colors.grey : Colors.white,
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 7,
                                        )
                                      ]
                                    ),
                                    width: MediaQuery.of(context).size.width*0.35,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text(
                                              entry.value == 1 ? "${entry.value} Task" : "${entry.value} Tasks",
                                              style: TextStyle(
                                                color: filters['category'] == entry.key ? Colors.white : Colors.black
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "${entry.key}", 
                                            style: TextStyle(
                                              fontSize: 20, 
                                              fontWeight: FontWeight.bold,
                                              color: filters['category'] == entry.key ? Colors.white : Colors.black
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.fade,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }, 
                            itemCount: catFreq.length
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 15,),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: DropdownMenu(
                    initialSelection: filters['priority'],
                    label: const Text(
                      "PRIORITY",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2
                      ),
                    ),
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                        value: "All", 
                        label: "All"
                      ),
                      DropdownMenuEntry(
                        value: 0, 
                        label: "Low"
                      ),
                      DropdownMenuEntry(
                        value: 1, 
                        label: "Medium"
                      ),
                      DropdownMenuEntry(
                        value: 2, 
                        label: "High"
                      ),
                    ],
                    onSelected: (value) {
                      setState(() {
                        filters['priority'] = value;
                      });
                    },
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: DropdownMenu(
                    initialSelection: filters['status'],
                    label: const Text(
                      "STATUS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2
                      ),
                    ),
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                        value: "All", 
                        label: "All"
                      ),
                      DropdownMenuEntry(
                        value: 0, 
                        label: "New"
                      ),
                      DropdownMenuEntry(
                        value: 1, 
                        label: "In Progress"
                      ),
                      DropdownMenuEntry(
                        value: 2, 
                        label: "Completed"
                      ),
                    ],
                    onSelected: (value) {
                      setState(() {
                        filters['status'] = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5,),

            Expanded(
              flex: 4,
              child: FutureBuilder<List<Todo>>(
                future: futureTodos,
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return const Center(child: CircularProgressIndicator(),);
                  }else{
                    final todos = snapshot.data!;
                    return todos.isEmpty ? const Center(
                      child: Text("Empty Todo List"),
                    ) :  Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                            child: Text(
                              "TASKS",
                              style: TextStyle(
                                letterSpacing: 2.0,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                if(index == todos.length){
                                  return const SizedBox(height: 50,);
                                }
                                final todo = todos[index];
                                return ((todo.data['title'] == "" || todo.data['title'].toUpperCase().contains(filters['searchValue'].toUpperCase())) && 
                                        (filters['category'] == "All" || todo.data['category'] == filters['category']) && 
                                        (filters['priority'] == "All" || todo.data['priority'] == filters['priority']) && 
                                        (filters['status'] == "All" || todo.data['status'] == filters['status'])) ? Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 7,
                                          )
                                        ]
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                        child: ListTile(
                                          leading: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Container(
                                              width: MediaQuery.of(context).size.width*0.05,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: todo.data['priority'] == 0 ? Colors.yellow : todo.data['priority'] == 1 ? Colors.orange : Colors.red,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            todo.data['title'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Due Date - ${DateFormat('yyyy-MM-dd').format(todo.data['dueDate'])}"),
                                              Text("Status - ${(todo.data['status'] == 0 ? "New" : todo.data['status'] == 1 ? "In Progress" : "Completed")}"),
                                            ],
                                          ),
                                          trailing: Wrap(
                                            spacing: 0,
                                            children: [
                                              IconButton(
                                                onPressed: () async {
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context, 
                                                    builder: (_) => Hero(
                                                      tag: "Edit",
                                                      child: CreateTodoWidget(
                                                        todo: todo,
                                                        onSubmit: (data) async {
                                                          await todoDB.update(id: data['id'], newData: data['newData']);
                                                          if(!mounted) return;
                                                          fetchTodos();
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(Icons.edit, color: Colors.grey,),
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  await todoDB.delete(todo.data['id']);
                                                  fetchTodos();
                                                },
                                                icon: const Icon(Icons.delete, color: Colors.red,),
                                              ),
                                            ]
                                          ),
                                          onTap: () {
                                            showDialog(
                                              barrierDismissible: false,
                                              context: context, 
                                              builder: (_) => ViewTodo(
                                                todo : todo,
                                                todoDB : todoDB,
                                                onSubmit: (data) async {
                                                  await todoDB.update(id: data['id'], newData: data['newData']);
                                                  if(!mounted) return;
                                                  fetchTodos();
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ) : const SizedBox() ;
                              }, 
                              itemCount: todos.length+1
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          showDialog(
            barrierDismissible: false,
            context: context, 
            builder: (_) => CreateTodoWidget(
              onSubmit: (data) async {
                await todoDB.create(title: data['title'], description: data['description'], dueDate: data['dueDate'], createdDate: DateTime.now().toString(), deletedDate: "Pending...", priority: data['priority'], category: data['category']);
                if(!mounted) return;
                fetchTodos();
                Navigator.of(context).pop();
              },
            ),
          );
        },
        backgroundColor: Colors.grey,
        label: const Text(
          "Create New Task",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}