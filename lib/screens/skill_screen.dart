import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SkillScreen extends StatefulWidget {
  static String id = 'skill_screen';

  const SkillScreen({Key? key}) : super(key: key);

  @override
  State<SkillScreen> createState() => _SkillScreenState();
}

class _SkillScreenState extends State<SkillScreen> {
  late Map<String, List<Map<String, dynamic>>> skillsByCategory;

  TextEditingController skillNameController = TextEditingController();
  TextEditingController categoryNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSkillsFromFirestore();
    skillsByCategory = {};
    // Load skills from Firestore when the screen is loaded
     //loadSkillsFromFirestore();
  }

  Future<void> loadSkillsFromFirestore() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection("main_categories").get();

      skillsByCategory = {};

      for (final doc in querySnapshot.docs) {
        final categoryName = doc.id;
        final subSkillsSnapshot =
        await doc.reference.collection("sub_skills").get();

        final skillList = subSkillsSnapshot.docs
            .map((subDoc) => {
          "name": subDoc["name"],
          "isChecked": subDoc["isChecked"],
        })
            .toList();

        skillsByCategory[categoryName] = skillList;
      }

      setState(() {});
    } catch (e) {
      print('Error loading skills: $e');
    }
  }


  Future<void> addSkillToFirestore(String categoryName, String skillName) async {
    try {
      // Add the category to the 'categories' collection
      final categoryRef = FirebaseFirestore.instance.collection("main_categories").doc(categoryName);
      await categoryRef.set({
        'name': categoryName,
        // You can add additional category properties if needed
      });

      // Add the skill to the 'sub_skills' collection under the specified category
      final skillRef = categoryRef.collection("sub_skills").doc(skillName);
      await skillRef.set({
        'name': skillName,
        'isChecked': false,
      });

      print('Skill added to Firestore');
      // Reload skills from Firestore after adding a new skill
      loadSkillsFromFirestore();
    } catch (e) {
      print('Error adding skill: $e');
    }
  }


  Future<void> removeSkillFromFirestore(String categoryName, String documentId) async {
    try {
      // Assuming you have a 'skills' collection in Firestore
      final CollectionReference skillsCollection = FirebaseFirestore.instance.collection('skills');

      // Remove the skill from Firestore
      await skillsCollection
          .doc(categoryName)
          .collection('sub_skills')
          .doc(documentId)
          .delete();

      print('Skill removed from Firestore successfully');
      // Reload skills from Firestore after removing a skill
      loadSkillsFromFirestore();
    } catch (e) {
      print('Error removing skill from Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    //loadSkillsFromFirestore();
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: const [
            Text('Skills'),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add Skill to Database:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: categoryNameController,
                decoration: InputDecoration(labelText: 'Category Name'),
              ),
              TextField(
                controller: skillNameController,
                decoration: InputDecoration(labelText: 'Skill Name'),
              ),
              SizedBox(
                height: 15.0,
              ),
              ElevatedButton(
                onPressed: () {
                  final categoryName = categoryNameController.text;
                  final skillName = skillNameController.text;

                  if (categoryName.isNotEmpty && skillName.isNotEmpty) {
                    addSkillToFirestore(categoryName, skillName);
                  }
                },
                child: Text("Add Skill"),
              ),
              const SizedBox(
                height: 15.0,
              ),
              const Divider(),
              const SizedBox(height: 20),
              const Text(
                "Skills in Database:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("main_categories").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final categories = snapshot.data?.docs ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categories.map((category) {
                      final categoryName = category["name"];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryName,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: category.reference.collection("sub_skills").snapshots(),
                            builder: (context, subSnapshot) {
                              if (subSnapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }

                              if (subSnapshot.hasError) {
                                return Text('Error: ${subSnapshot.error}');
                              }

                              final skills = subSnapshot.data?.docs ?? [];

                              return Column(
                                children: skills.map((skill) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Row(
                                      children: [
                                        Checkbox(
                                          activeColor: Colors.deepPurpleAccent,
                                          value: skill["isChecked"],
                                          onChanged: (val) {
                                            // Update the local state when checkbox is changed
                                            // Implement your logic to update Firestore here
                                          },
                                        ),
                                        Expanded(
                                          child: Text(skill["name"]),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () async {
                                            // Remove the skill from Firestore
                                            await category.reference
                                                .collection("sub_skills")
                                                .doc(skill.id)
                                                .delete();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
