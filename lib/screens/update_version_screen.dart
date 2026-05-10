import 'dart:io';

import 'package:arobo_app/utils/common_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/auth/validate_version_model.dart';


class UpdateVersionScreen extends StatefulWidget {
  final ValidateDataModel? dataModel;
  const UpdateVersionScreen({super.key,required this.dataModel});

  @override
  State<UpdateVersionScreen> createState() => _UpdateVersionScreenState();
}

class _UpdateVersionScreenState extends State<UpdateVersionScreen> {

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonColors.whiteColor,
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: IntrinsicHeight(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/img/aorbologo.png",width: 150,height: 150,),
                          const SizedBox(height: 10),
                          Text("An Update Required \n Please Update And Continue",textAlign: TextAlign.center,style: TextStyle(
                              fontSize: 16,
                              color: CommonColors.blackColor,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.normal
                          ),),
                          const SizedBox(height: 20),
                           Text("Current Version ${widget.dataModel?.currentVersion ?? "1.0.0"}",textAlign: TextAlign.center,style: TextStyle(
                              fontSize: 16,
                              color: CommonColors.blackColor,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.normal
                          ),),
                          const SizedBox(height: 20),
                          Text(widget.dataModel?.releaseNotes ?? "",textAlign: TextAlign.center,style: TextStyle(
                              fontSize: 12,
                              color: CommonColors.blackColor,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal
                          ),),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0,right: 12,top: 10,bottom: 20),
                            child: Container(
                              width: double.infinity,// Set width as needed
                              decoration: BoxDecoration(
                                color: CommonColors.primaryColor,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextButton(
                                onPressed: _launchURL,
                                child: const Text(
                                  'Update',
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      color: Colors.white
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: launchEmail,
                child: Text("Contact admin for support \n aorboSupport@gmail.com",textAlign: TextAlign.center,style: TextStyle(
                    fontSize: 9,
                    color: CommonColors.blackColor,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal
                ),),
              ),
              SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }

  final String playStoreUrl = "https://play.google.com/store/apps/details?id=com.eclipso.arobo_app";
  final String appStoreUrl = "https://apps.apple.com/us/app/aorbo/id6747623495";

  Future<void> _launchURL() async {
    final Uri url = Uri.parse(Platform.isAndroid ? playStoreUrl : appStoreUrl);

    try{
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
    catch(error){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch the store")));
    }

  }


  final String email = 'thurentSupport@gmail.com';
  final String subject = 'VersionUpdate';
  final String body = 'Body';

  Future<void> launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );


    try{
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    }
    catch(error){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch email")));
    }
  }


}
