import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyAkro1dfzCpvfs6rOL1xnOx1P0RK0aXA0M",
        appId: "1:932419670359:android:653cef7f05d22d9261ee12",
        messagingSenderId: "",
        projectId: "fir-cloudstorage-9fcf2",
        storageBucket: "fir-cloudstorage-9fcf2.appspot.com"
    ));
  runApp(MaterialApp(home: FirebaseCrud(),debugShowCheckedModeBanner: false,));
}

class FirebaseCrud extends StatefulWidget{
  @override
  State<FirebaseCrud> createState() => _FirebaseCrudState();
}

class _FirebaseCrudState extends State<FirebaseCrud> {
  var name_controller = TextEditingController();
  var email_controller = TextEditingController();
  late CollectionReference _userCollection;

  @override
  void initState() {
    _userCollection = FirebaseFirestore.instance.collection("users");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            SizedBox(height: 100,),
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20),
              child: TextField(
                controller: name_controller,
                decoration: InputDecoration(
                  hintText: "name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20),
              child: TextField(
    controller: email_controller,
                decoration: InputDecoration(
                    hintText: "email",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                ),
              ),
            ),
            ElevatedButton(onPressed: () {
              addUser();
            }, child: Text("ADD USER")),
            StreamBuilder<QuerySnapshot>(
                stream: getUser(),
                builder: (context,snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error ${snapshot.error}");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final users = snapshot.data!.docs;
                  return Expanded(
                    child: ListView.builder(
                        itemBuilder: (context,index){
                          final user = users[index];
                          final userId = user.id;
                          final userName = user['name'];
                          final userEmail = user['email'];
                          return ListTile(
                            title: Text('$userName',style: TextStyle(fontSize: 20),),
                            subtitle: Text('$userEmail',style: TextStyle(fontSize: 15),),
                            trailing: Wrap(
                              children: [
                                IconButton(onPressed: () {
                                  editUser(userId);
                                }, icon: Icon(Icons.edit)),
                                IconButton(onPressed: () {
                                  deleteUser(userId);
                                }, icon: Icon(Icons.delete)),
                              ],
                            ),
                          );
                        },itemCount: users.length,),
                  );
                })
          ],
        ));
  }

  void addUser() async {
    return _userCollection.add({
      'name' : name_controller.text,
      'email' : email_controller.text
    }).then((value) {
      print("user added successfully");
      name_controller.clear();
      email_controller.clear();
    }).catchError((error){
      print("Failed to add user $error");
    });
  }

  Stream<QuerySnapshot>getUser() {
    return _userCollection.snapshots();
  }

  void editUser(var id) {
    showDialog(
        context: context,
        builder: (context) {
          final newname_controller = TextEditingController();
          final newemail_controller = TextEditingController();

          return AlertDialog(
            title: const Text("Update User"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newname_controller,
                  decoration: const InputDecoration(
                    hintText: "Enter name",border: OutlineInputBorder()
                  ),
                ),
                SizedBox(height: 15,),
                TextField(
                  controller: newemail_controller,
                  decoration: const InputDecoration(
                      hintText: "Enter email",border: OutlineInputBorder()
                  ),
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () {
                updateUser(id,newname_controller.text,newemail_controller.text).then((value){
                  Navigator.pop(context);
                });
              }, child: Text("Update"))
            ],
          );
        });
  }

  Future<void>updateUser(var id, String newname, String newemail) {
    return _userCollection
        .doc(id)
        .update({'name':newname,'email':newemail}).then((value){
          print("User Updated Successfully");
    }).catchError((error) {
      print("User Data Updation Failed $error");
    });
  }

  Future<void> deleteUser(var id) {
    return _userCollection.doc(id).delete().then((value){
      print("User Deleted Successfully");
    }).catchError((error) {
      print("User Deletion Failed $error");
    });
  }
}