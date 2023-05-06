// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:contextmenu/contextmenu.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:adguard_home_manager/screens/filters/list_functions.dart';
import 'package:adguard_home_manager/widgets/custom_list_tile.dart';
import 'package:adguard_home_manager/widgets/options_modal.dart';

import 'package:adguard_home_manager/functions/snackbar.dart';
import 'package:adguard_home_manager/models/filtering.dart';
import 'package:adguard_home_manager/functions/copy_clipboard.dart';
import 'package:adguard_home_manager/models/menu_option.dart';
import 'package:adguard_home_manager/providers/app_config_provider.dart';
import 'package:adguard_home_manager/providers/servers_provider.dart';

class ListOptionsMenu extends StatelessWidget {
  final Filter list;
  final Widget child;
  final String listType;

  const ListOptionsMenu({
    Key? key,
    required this.list,
    required this.child,
    required this.listType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    void enableDisable() async {
      final result = await enableDisableList(
        context: context, 
        serversProvider: serversProvider, 
        appConfigProvider: appConfigProvider, 
        list: list, 
        listType: listType, 
      );
      if (result == true) {
        showSnacbkar(
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.listDataUpdated, 
          color: Colors.green
        );
      }
      else {
        showSnacbkar(
          appConfigProvider: appConfigProvider,
          label: AppLocalizations.of(context)!.listDataNotUpdated, 
          color: Colors.red
        );
      }
    }

    return ContextMenuArea(
      builder: (context) => [
        CustomListTile(
          title: list.enabled == true
            ? AppLocalizations.of(context)!.disable
            : AppLocalizations.of(context)!.enable,
          icon: list.enabled == true
            ? Icons.gpp_bad_rounded
            : Icons.verified_user_rounded,
          onTap: () {
            Navigator.pop(context);  // Closes the context menu
            enableDisable();
          }
        ),
        CustomListTile(
          title: AppLocalizations.of(context)!.copyListUrl,
          icon: Icons.copy_rounded,
          onTap: () {
            Navigator.pop(context);  // Closes the context menu
            copyToClipboard(
              context: context, 
              value: list.url, 
              successMessage: AppLocalizations.of(context)!.listUrlCopied
            );
          }
        ),
      ],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress: () => showDialog(
            context: context, 
            builder: (context) => OptionsModal(
              options: [
                MenuOption(
                  title: list.enabled == true
                    ? AppLocalizations.of(context)!.disable
                    : AppLocalizations.of(context)!.enable,
                  icon: list.enabled == true
                    ? Icons.gpp_bad_rounded
                    : Icons.verified_user_rounded,
                  action: enableDisable
                ),
                MenuOption(
                  title: AppLocalizations.of(context)!.copyListUrl,
                  icon: Icons.copy_rounded,
                  action: () => copyToClipboard(
                    context: context, 
                    value: list.url, 
                    successMessage: AppLocalizations.of(context)!.listUrlCopied
                  )
                ),
              ]
            )
          ),
          child: child
        ),
      ), 
    );
  }
}