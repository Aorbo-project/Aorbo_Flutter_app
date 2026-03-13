import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../utils/common_colors.dart';
import '../utils/common_images.dart';
import '../utils/screen_constants.dart';
import '../utils/common_btn.dart';
import '../models/emergency_contact_model.dart';
import '../repository/repository.dart';
import '../repository/network_url.dart';

class SelectedEmergencyContactsScreen extends StatefulWidget {
  const SelectedEmergencyContactsScreen({super.key});

  @override
  State<SelectedEmergencyContactsScreen> createState() =>
      _SelectedEmergencyContactsScreenState();
}

class _SelectedEmergencyContactsScreenState
    extends State<SelectedEmergencyContactsScreen> {
  List<Contact> selectedContacts = [];
  List<EmergencyContact> apiEmergencyContacts = [];
  bool isLoading = true;
  final Repository _repository = Repository();

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments;
    if (arguments != null && arguments is List<Contact>) {
      selectedContacts = List.from(arguments);
    }
    _loadEmergencyContacts();
  }

  Future<void> _loadEmergencyContacts() async {
    try {
      setState(() => isLoading = true);
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
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _saveEmergencyContacts() async {
    if (selectedContacts.isEmpty) {
      Get.back();
      return;
    }

    try {
      setState(() => isLoading = true);

      int successCount = 0;
      String? errorMessage;

      for (final contact in selectedContacts) {
        final phone = contact.phones.isNotEmpty
            ? contact.phones.first.number
            : '';

        final body = {
          'name': contact.displayName,
          'phone': phone,
          'relationship': contact.displayName,
        };

        try {
          final response = await _repository.postApiCall(
            url: NetworkUrl.emergencyContacts,
            body: body,
          );

          if (response != null) {
            final createResponse = EmergencyContactCreateResponse.fromJson(
              response,
            );
            if (createResponse.success == true) {
              successCount++;
            } else {
              errorMessage = createResponse.message ?? 'Failed to save contact';
              break;
            }
          }
        } catch (e) {
          errorMessage = e.toString();
          break;
        }
      }

      if (errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$successCount emergency contact(s) saved successfully',
            ),
          ),
        );
      }

      await _loadEmergencyContacts();
      setState(() => selectedContacts.clear());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save contacts: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteEmergencyContact(int id) async {
    try {
      final response = await _repository.deleteApiCall(
        url: NetworkUrl.deleteEmergencyContact(id),
      );

      if (response != null) {
        final deleteResponse = EmergencyContactDeleteResponse.fromJson(
          response,
        );
        final message =
            deleteResponse.message ?? 'Contact deleted successfully';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: deleteResponse.success == true
                ? Colors.green
                : Colors.red,
          ),
        );

        if (deleteResponse.success == true) {
          await _loadEmergencyContacts();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete contact: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(int id, String contactName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Contact',
            style: GoogleFonts.poppins(
              fontSize: FontSize.s14,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete $contactName?',
            style: GoogleFonts.poppins(fontSize: FontSize.s11),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: CommonColors.greyColor818181),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEmergencyContact(id);
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _removeContact(Contact contact) {
    setState(() {
      selectedContacts.remove(contact);
    });
  }

  void _addMoreContacts() async {
    final totalContacts = apiEmergencyContacts.length + selectedContacts.length;
    if (totalContacts >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 emergency contacts allowed')),
      );
      return;
    }

    final result = await Get.offNamed(
      '/emergency-contacts',
      arguments: selectedContacts,
    );
    if (result != null && result is List<Contact>) {
      setState(() {
        final existingIds = selectedContacts.map((e) => e.id).toSet();
        for (final contact in result) {
          final totalAfterAdd =
              apiEmergencyContacts.length + selectedContacts.length;
          if (!existingIds.contains(contact.id) && totalAfterAdd < 3) {
            selectedContacts.add(contact);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back(result: selectedContacts);
        return true; // Allow the back action
      },
      child: Scaffold(
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Get.back(result: selectedContacts);
            },
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 4.w),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: CommonColors.lightBlueColor3,
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
                    fontSize: FontSize.s10,
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
                    color: CommonColors.offWhiteColor3,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6.w),
                      topRight: Radius.circular(6.w),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Emergency Contacts (${apiEmergencyContacts.length + selectedContacts.length}/3)",
                        style: GoogleFonts.poppins(
                          fontSize: FontSize.s10,
                          color: CommonColors.greyColor818181,
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
                // Selected Contacts List
                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: EdgeInsets.only(
                            left: 5.w,
                            right: 5.w,
                            bottom: selectedContacts.isNotEmpty ? 12.h : 2.h,
                          ),
                          child: Column(
                            children: [
                              // API Emergency Contacts
                              ...apiEmergencyContacts.map((contact) {
                                return Container(
                                  margin: EdgeInsets.only(bottom: 2.h),
                                  padding: EdgeInsets.only(right: 2.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: CommonColors.greyColor878787,
                                      width: 0.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 2.w,
                                      right: 2.w,
                                      top: 1.h,
                                      bottom: 1.h,
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 6.w,
                                          backgroundColor:
                                              CommonColors.greyDFDFDF,
                                          child: Text(
                                            contact.name != null &&
                                                    contact.name!.isNotEmpty
                                                ? contact.name![0].toUpperCase()
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
                                                contact.name ?? 'Unknown',
                                                style: GoogleFonts.poppins(
                                                  fontSize: FontSize.s10,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      CommonColors.blackColor,
                                                ),
                                              ),
                                              Text(
                                                contact.phone ?? 'No number',
                                                style: GoogleFonts.poppins(
                                                  fontSize: FontSize.s9,
                                                  color: CommonColors
                                                      .greyColor818181,
                                                ),
                                              ),
                                              if (contact.relationship != null)
                                                Text(
                                                  contact.relationship!,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: FontSize.s8,
                                                    color: CommonColors
                                                        .lightBlueColor3,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        // Delete button
                                        GestureDetector(
                                          onTap: () {
                                            if (contact.id != null) {
                                              _showDeleteConfirmation(
                                                contact.id!,
                                                contact.name ?? 'this contact',
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(2.w),
                                            decoration: BoxDecoration(
                                              color: CommonColors.greyDFDFDF,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            child: SvgPicture.asset(
                                              CommonImages.deleteIcon,
                                              width: 5.w,
                                              height: 5.w,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),

                              // Divider if both types exist
                              if (apiEmergencyContacts.isNotEmpty &&
                                  selectedContacts.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 1.h),
                                  child: Row(
                                    children: [
                                      Expanded(child: Divider()),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2.w,
                                        ),
                                        child: Text(
                                          'New Contacts to Add',
                                          style: GoogleFonts.poppins(
                                            fontSize: FontSize.s9,
                                            color: CommonColors.greyColor818181,
                                          ),
                                        ),
                                      ),
                                      Expanded(child: Divider()),
                                    ],
                                  ),
                                ),

                              // Selected contacts (to be saved)
                              ...selectedContacts.map((contact) {
                                final phone = contact.phones.isNotEmpty
                                    ? contact.phones.first.number
                                    : "No number";

                                return Container(
                                  margin: EdgeInsets.only(bottom: 2.h),
                                  padding: EdgeInsets.only(right: 2.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: CommonColors.greyColor878787,
                                      width: 0.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 2.w,
                                      right: 2.w,
                                      top: 1.h,
                                      bottom: 1.h,
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 6.w,
                                          backgroundColor:
                                              CommonColors.greyDFDFDF,
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
                                                  fontSize: FontSize.s10,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      CommonColors.blackColor,
                                                ),
                                              ),
                                              Text(
                                                phone,
                                                style: GoogleFonts.poppins(
                                                  fontSize: FontSize.s9,
                                                  color: CommonColors
                                                      .greyColor818181,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Delete button
                                        GestureDetector(
                                          onTap: () => _removeContact(contact),
                                          child: Container(
                                            padding: EdgeInsets.all(2.w),
                                            decoration: BoxDecoration(
                                              color: CommonColors.greyDFDFDF,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            child: SvgPicture.asset(
                                              CommonImages.deleteIcon,
                                              width: 5.w,
                                              height: 5.w,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),

                              // Add More button (only show if total contacts less than 3)
                              if ((apiEmergencyContacts.length +
                                      selectedContacts.length) <
                                  3)
                                GestureDetector(
                                  onTap: _addMoreContacts,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 2.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.w),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 2.w,
                                        right: 5.w,
                                        top: 1.h,
                                        bottom: 1.h,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 12.w,
                                            height: 12.w,
                                            decoration: BoxDecoration(
                                              color: CommonColors.blackColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              color: CommonColors.whiteColor,
                                              size: 6.w,
                                            ),
                                          ),
                                          SizedBox(width: 3.w),
                                          Text(
                                            "Add more",
                                            style: GoogleFonts.poppins(
                                              fontSize: FontSize.s10,
                                              fontWeight: FontWeight.w500,
                                              color: CommonColors.blackColor,
                                            ),
                                          ),
                                          Spacer(),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: CommonColors.greyColor818181,
                                            size: 5.w,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            // Save Button - only show if there are selected contacts to save
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
                    text: 'Save Emergency Contacts',
                    onPressed: () {
                      if (!isLoading) {
                        _saveEmergencyContacts();
                      }
                    },
                    gradient: CommonColors.btnGradient,
                    textColor: CommonColors.whiteColor,
                    fontWeight: FontWeight.w600,
                    fontSize: FontSize.s12,
                    height: 6.5.h,
                    isDisabled: isLoading,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
