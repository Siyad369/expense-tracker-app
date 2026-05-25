import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:package_info_plus/package_info_plus.dart';

import 'package:url_launcher/url_launcher.dart';

class UpdateService {

  static const String apiUrl =
      "https://api.github.com/repos/Siyad369/expense-tracker-app/releases/latest";

  static Future<void> checkForUpdate(
    BuildContext context,
  ) async {

    try {

      final response =
          await http.get(Uri.parse(apiUrl));

      if (response.statusCode != 200) {
        return;
      }

      final data =
          jsonDecode(response.body);

      final latestVersion =
          data["tag_name"]
              .toString()
              .replaceAll("v", "");

      final apkUrl =
          data["assets"][0]
              ["browser_download_url"];

      final packageInfo =
          await PackageInfo.fromPlatform();

      final currentVersion =
          packageInfo.version;

      if (latestVersion != currentVersion) {

        if (!context.mounted) return;

        showDialog(

          context: context,

          builder: (_) => AlertDialog(

            title: const Text(
              "Update Available",
            ),

            content: Text(
              "Version $latestVersion is available",
            ),

            actions: [

              TextButton(

                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text("Later"),
              ),

              ElevatedButton(

                onPressed: () async {

                  final uri =
                      Uri.parse(apkUrl);

                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                },

                child: const Text(
                  "Download",
                ),
              ),
            ],
          ),
        );
      }

    } catch (e) {

      print("UPDATE CHECK ERROR");
      print(e);
    }
  }
}