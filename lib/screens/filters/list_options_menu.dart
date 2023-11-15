// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:contextmenu/contextmenu.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:adguard_home_manager/widgets/custom_list_tile.dart';
import 'package:adguard_home_manager/widgets/options_modal.dart';
import 'package:adguard_home_manager/screens/filters/selection_screen.dart';

import 'package:adguard_home_manager/functions/open_url.dart';
import 'package:adguard_home_manager/classes/process_modal.dart';
import 'package:adguard_home_manager/functions/snackbar.dart';
import 'package:adguard_home_manager/models/filtering.dart';
import 'package:adguard_home_manager/providers/filtering_provider.dart';
import 'package:adguard_home_manager/functions/copy_clipboard.dart';
import 'package:adguard_home_manager/models/menu_option.dart';
import 'package:adguard_home_manager/providers/app_config_provider.dart';

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
    final filteringProvider = Provider.of<FilteringProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final width = MediaQuery.of(context).size.width;

    void enableDisable() async {
      ProcessModal processModal = ProcessModal(context: context);
      processModal.open(
        list.enabled == true
          ? AppLocalizations.of(context)!.disablingList
          : AppLocalizations.of(context)!.enablingList
      );

      final result = await filteringProvider.updateList(
        list: list, 
        type: listType, 
        action: list.enabled == true
          ? FilteringListActions.disable
          : FilteringListActions.enable
      );

      processModal.close();

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

    void openSelectionMode() {
      showGeneralDialog(
        context: context, 
        barrierColor: !(width > 900 || !(Platform.isAndroid | Platform.isIOS))
          ?Colors.transparent 
          : Colors.black54,
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(
              begin: const Offset(0, 1), 
              end: const Offset(0, 0)
            ).animate(
              CurvedAnimation(
                parent: anim1, 
                curve: Curves.easeInOutCubicEmphasized
              )
            ),
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) => SelectionScreen(
          isModal: width > 900 || !(Platform.isAndroid | Platform.isIOS)
        )
      );
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
              value: list.url, 
              successMessage: AppLocalizations.of(context)!.listUrlCopied
            );
          }
        ),
        CustomListTile(
          title: AppLocalizations.of(context)!.openListUrl,
          icon: Icons.open_in_browser_rounded,
          onTap: () => openUrl(list.url)
        ),
        CustomListTile(
          title: AppLocalizations.of(context)!.selectionMode,
          icon: Icons.check_rounded,
          onTap: openSelectionMode
        ),
      ],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress: Platform.isAndroid || Platform.isIOS ? () => showDialog(
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
                    value: list.url, 
                    successMessage: AppLocalizations.of(context)!.listUrlCopied
                  )
                ),
                MenuOption(
                  title: AppLocalizations.of(context)!.openListUrl,
                  icon: Icons.open_in_browser_rounded,
                  action: () => openUrl(list.url)
                ),
                MenuOption(
                  title: AppLocalizations.of(context)!.selectionMode,
                  icon: Icons.check_rounded,
                  action: openSelectionMode
                ),
              ]
            )
          ) : null,
          child: child
        ),
      ), 
    );
  }
}