import 'dart:io';

import 'package:attendancesys/loginscreen.dart';
import 'package:attendancesys/model/user.dart' as LocalUser;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseUser;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color(0xffeef444c);
  String birth = "Date of birth";

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  void pickUploadProfilePic() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      // maxHeight: 512,
      // maxWidth: 512,
      imageQuality: 90,
    );

    if (image != null) {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("${LocalUser.User.employeeId.toLowerCase()}_profilepic.jpg");
      try {
        await ref.putFile(File(image.path));
      } catch (e) {
        print(e);
      }

      String downloadURL = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("Employee")
          .doc(LocalUser.User.id)
          .update({
        'profilePic': downloadURL,
      });

      setState(() {
        LocalUser.User.profilePicLink = downloadURL;
      });
    }
  }

  late BuildContext scaffoldContext; // Add this line

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    scaffoldContext = context; // Store context

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                pickUploadProfilePic();
              },
              child: Container(
                margin: const EdgeInsets.only(top: 80, bottom: 24),
                padding: const EdgeInsets.all(2),
                height: 120,
                width: 120,
                // alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: primary,
                ),
                // child:
                //  Center(
                child: LocalUser.User.profilePicLink == " "
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 80,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: LocalUser.User.profilePicLink,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Center(
                            child: CircularProgressIndicator(
                                value: downloadProgress.progress),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
              ),
            ),
            // ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Employee ${LocalUser.User.employeeId}",
                style: const TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            LocalUser.User.canEdit
                ? textField("First Name", "First name", firstNameController)
                : field("First Name", LocalUser.User.firstName),
            LocalUser.User.canEdit
                ? textField("Last Name", "Last name", lastNameController)
                : field("Last Name", LocalUser.User.lastName),
            LocalUser.User.canEdit
                ? GestureDetector(
                    onTap: () {
                      showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: primary,
                                  secondary: primary,
                                  onSecondary: Colors.white,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: primary,
                                  ),
                                ),
                                textTheme: const TextTheme(
                                  headlineMedium: TextStyle(
                                    fontFamily: "NexaBold",
                                  ),
                                  labelSmall: TextStyle(
                                    fontFamily: "NexaBold",
                                  ),
                                  labelLarge: TextStyle(
                                    fontFamily: "NexaBold",
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          }).then((value) {
                        setState(() {
                          birth = DateFormat("MM/dd/yyyy").format(value!);
                        });
                      });
                    },
                    child: field("Date of Birth", birth),
                  )
                : field("Date of Birth", LocalUser.User.birthDate),
            LocalUser.User.canEdit
                ? textField("Address", "Address", addressController)
                : field("Address", LocalUser.User.address),
            LocalUser.User.canEdit
                ? GestureDetector(
                    onTap: () async {
                      String firstName = firstNameController.text;
                      String lastName = lastNameController.text;
                      String birthDate = birth;
                      String address = addressController.text;

                      if (LocalUser.User.canEdit) {
                        if (firstName.isEmpty) {
                          showSnackBar("Please enter your first name!");
                        } else if (lastName.isEmpty) {
                          showSnackBar("Please enter your last name!");
                        } else if (birthDate.isEmpty) {
                          showSnackBar("Please enter your birth date!");
                        } else if (address.isEmpty) {
                          showSnackBar("Please enter your address!");
                        } else {
                          await FirebaseFirestore.instance
                              .collection("Employee")
                              .doc(LocalUser.User.id)
                              .update({
                            'firstName': firstName,
                            'lastName': lastName,
                            'birthDate': birthDate,
                            'address': address,
                            'canEdit': false,
                          }).then((value) {
                            setState(() {
                              LocalUser.User.canEdit = false;
                              LocalUser.User.firstName = firstName;
                              LocalUser.User.lastName = lastName;
                              LocalUser.User.birthDate = birthDate;
                              LocalUser.User.address = address;
                            });
                          });
                        }
                      } else {
                        showSnackBar(
                            "You can't edit anymore, please contact support team.");
                      }
                    },
                    child: Container(
                      height: kToolbarHeight,
                      width: screenWidth,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: primary,
                      ),
                      child: const Center(
                        child: Text(
                          "SAVE",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "NexaBold",
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            LocalUser.User.canEdit
                ? GestureDetector(
                    onTap: () async {
                      await _signOut(); // Call the _signOut function
                    },
                    child: Container(
                      height: kToolbarHeight,
                      width: screenWidth,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: primary,
                      ),
                      child: const Center(
                        child: Text(
                          "SIGN OUT",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "NexaBold",
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseUser.FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      scaffoldContext, // Use stored context
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Widget field(String title, String text) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "NexaBold",
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          height: kToolbarHeight,
          width: screenWidth,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.only(left: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.black54,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black54,
                fontFamily: "NexaBold",
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget textField(
      String title, String hint, TextEditingController controller) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "NexaBold",
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: controller,
            cursorColor: Colors.black54,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.black54,
                fontFamily: "NexaBold",
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black54,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          text,
        ),
      ),
    );
  }
}
