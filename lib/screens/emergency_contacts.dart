import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../utils/common_colors.dart';
import '../utils/screen_constants.dart';
import '../utils/common_btn.dart';
import 'package:get/get.dart';
import '../models/emergency_contact_model.dart';
import '../repository/repository.dart';
import '../repository/network_url.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  _EmergencyContactsScreenState createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<Contact> allContacts = [];
  List<Contact> filteredContacts = [];
  List<Contact> selectedContacts = [];
  List<EmergencyContact> apiEmergencyContacts = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  final Repository _repository = Repository();

  @override
  void initState() {
    super.initState();
    // Receive selected contacts if coming from SelectedEmergencyContactsScreen
    final arguments = Get.arguments;
    if (arguments != null && arguments is List<Contact>) {
      selectedContacts = List.from(arguments);
    }
    _loadApiEmergencyContacts();
    fetchContacts();
    searchController.addListener(filterContacts);
  }

  Future<void> _loadApiEmergencyContacts() async {
    try {
      final response = await _repository.getApiCall(
        url: NetworkUrl.emergencyContacts,
      );

      if (response != null) {
        final contactResponse = EmergencyContactResponse.fromJson(response);
        if (contactResponse.success == true) {
          setState(() {
            apiEmergencyContacts = contactResponse.data ?? [];
          });
        }
      }
    } catch (e) {
      // Silently fail during initialization
    }
  }

  Future<void> fetchContacts() async {
    final status = await Permission.contacts.status;
    if (!status.isGranted) {
      final result = await Permission.contacts.request();
      if (!result.isGranted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contact permission denied")),
        );
        return;
      }
    }

    final contacts = await FlutterContacts.getContacts(withProperties: true);
    setState(() {
      allContacts = contacts.where((c) => c.phones.isNotEmpty).toList();
      filteredContacts = allContacts;
      isLoading = false;
    });
  }

  void filterContacts() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredContacts = allContacts.where((contact) {
        final name = contact.displayName.toLowerCase();
        final phones = contact.phones.map((p) => p.number).join().toLowerCase();
        return name.contains(query) || phones.contains(query);
      }).toList();
    });
  }

  void toggleSelection(Contact contact) {
    setState(() {
      if (selectedContacts.contains(contact)) {
        selectedContacts.remove(contact);
      } else {
        final totalContacts = apiEmergencyContacts.length + selectedContacts.length;
        if (totalContacts < 3) {
          selectedContacts.add(contact);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("You can only have up to 3 emergency contacts total.")),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.whiteColor,
      appBar: AppBar(
        backgroundColor: CommonColors.lightBlueColor3.withValues(alpha: 0.2),
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: false,
        title: Text(
          'Emergency Contacts',
          style: GoogleFonts.poppins(
            fontSize: FontSize.s14,
            fontWeight: FontWeight.w400,
            color: CommonColors.blackColor,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 4.w),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: CommonColors.lightBlueColor3,
                // padding: EdgeInsets.symmetric(horizontal: 2.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45),
                ),
              ),
              onPressed: () {
                // Handle help action
              },
              child: Text(
                'FAQ',
                style: GoogleFonts.poppins(
                  fontSize: FontSize.s11,
                  fontWeight: FontWeight.w500,
                  color: CommonColors.whiteColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Light blue background extension
          Container(
            height: 8.h,
            color: CommonColors.lightBlueColor3.withValues(alpha: 0.2),
          ),
          Column(
            children: [
              // Main white container
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 6.h),
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: CommonColors.whiteColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6.w),
                    topRight: Radius.circular(6.w),
                  ),
                ),
                child: Column(
                  children: [
                    // Search Box
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: CommonColors.whiteColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: CommonColors.greyColorf7f7f7,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 2,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s11,
                          color: CommonColors.blackColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search Contacts..',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: FontSize.s11,
                            color: CommonColors.greyColor818181,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: CommonColors.greyColor818181,
                            size: 6.w,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    // Maximum contacts text
                    Text(
                      "Add up to three contacts maximum (${apiEmergencyContacts.length + selectedContacts.length}/3)",
                      style: GoogleFonts.poppins(
                        fontSize: FontSize.s11,
                        color: CommonColors.greyColor818181,
                      ),
                    ),
                    // SizedBox(height: 2.h),
                  ],
                ),
              ),
              // Contacts List
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: EdgeInsets.only(
                          left: 5.w,
                          right: 5.w,
                          bottom: selectedContacts.isNotEmpty ? 12.h : 2.h,
                        ),
                        itemCount: filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = filteredContacts[index];
                          final phone = contact.phones.isNotEmpty
                              ? contact.phones.first.number
                              : "No number";
                          final isSelected = selectedContacts.contains(contact);

                          return Container(
                            margin: EdgeInsets.only(bottom: 2.h),
                            decoration: BoxDecoration(
                              color: CommonColors.whiteColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected
                                    ? CommonColors.greyColor878787
                                    : CommonColors.greyColor878787,
                                width: isSelected ? 1 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () => toggleSelection(contact),
                              borderRadius: BorderRadius.circular(3.w),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 2.w,
                                    right: 5.w,
                                    top: 1.h,
                                    bottom: 1.h),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 6.w,
                                      backgroundColor: CommonColors.greyDFDFDF,
                                      child: Text(
                                        contact.displayName.isNotEmpty
                                            ? contact.displayName[0]
                                                .toUpperCase()
                                            : '?',
                                        style: GoogleFonts.poppins(
                                          fontSize: FontSize.s14,
                                          fontWeight: FontWeight.w500,
                                          color: CommonColors.blackColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            contact.displayName,
                                            style: GoogleFonts.poppins(
                                              fontSize: FontSize.s11,
                                              fontWeight: FontWeight.w500,
                                              color: CommonColors.blackColor,
                                            ),
                                          ),
                                          Text(
                                            phone,
                                            style: GoogleFonts.poppins(
                                              fontSize: FontSize.s10,
                                              color:
                                                  CommonColors.greyColor818181,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Custom Radio Button
                                    Container(
                                      width: 5.w,
                                      height: 5.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: isSelected
                                            ? CommonColors.radioBtnGradient
                                            : null,
                                        border: isSelected
                                            ? null
                                            : Border.all(
                                                color: CommonColors
                                                    .greyColor585858,
                                                width: 2,
                                              ),
                                        color: CommonColors.whiteColor,
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 2.w,
                                                height: 2.w,
                                                decoration: const BoxDecoration(
                                                  color:CommonColors.whiteColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
          // Add Button
          if (selectedContacts.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: CommonColors.whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: CommonColors.blackColor.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: CommonButton(
                  text: 'Add',
                  onPressed: () async {
                    // Navigate to selected contacts screen
                    final updatedSelectedContacts = await Get.offNamed(
                      '/selected-emergency-contacts',
                      arguments: selectedContacts,
                    );


                    if (updatedSelectedContacts != null &&
                        updatedSelectedContacts is List<Contact>) {
                      setState(() {
                        selectedContacts = List.from(updatedSelectedContacts);
                      });
                    }
                  },
                  gradient: CommonColors.btnGradient,
                  textColor: CommonColors.whiteColor,
                  fontWeight: FontWeight.w600,
                  fontSize: FontSize.s12,
                  height: 6.5.h,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
