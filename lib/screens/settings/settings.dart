import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_split_view/flutter_split_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:adguard_home_manager/screens/settings/server_info/server_info.dart';
import 'package:adguard_home_manager/screens/settings/encryption/encryption.dart';
import 'package:adguard_home_manager/screens/settings/access_settings/access_settings.dart';
import 'package:adguard_home_manager/screens/settings/customization/customization.dart';
import 'package:adguard_home_manager/screens/settings/dhcp/dhcp.dart';
import 'package:adguard_home_manager/screens/settings/safe_search_settings.dart';
import 'package:adguard_home_manager/screens/settings/update_server/update.dart';
import 'package:adguard_home_manager/screens/settings/dns/dns.dart';
import 'package:adguard_home_manager/screens/settings/dns_rewrites/dns_rewrites.dart';
import 'package:adguard_home_manager/screens/servers/servers.dart';
import 'package:adguard_home_manager/screens/settings/advanced_setings.dart';
import 'package:adguard_home_manager/screens/settings/general_settings/general_settings.dart';

import 'package:adguard_home_manager/widgets/custom_settings_tile.dart';
import 'package:adguard_home_manager/widgets/section_label.dart';
import 'package:adguard_home_manager/widgets/custom_list_tile.dart';

import 'package:adguard_home_manager/functions/desktop_mode.dart';
import 'package:adguard_home_manager/constants/strings.dart';
import 'package:adguard_home_manager/functions/open_url.dart';
import 'package:adguard_home_manager/functions/compare_versions.dart';
import 'package:adguard_home_manager/constants/urls.dart';
import 'package:adguard_home_manager/providers/status_provider.dart';
import 'package:adguard_home_manager/providers/servers_provider.dart';
import 'package:adguard_home_manager/providers/app_config_provider.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return SplitView.material(
            hideDivider: true,
            flexWidth: const FlexWidth(mainViewFlexWidth: 1, secondaryViewFlexWidth: 2),
            placeholder: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  AppLocalizations.of(context)!.selectOptionLeftColumn,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.onSurfaceVariant
                  ),
                ),
              ),
            ),
            child: const SettingsWidget(
              twoColumns: true,
            ),
          );
        }
        else {
          return const SettingsWidget(
            twoColumns: false,
          );
        }
      },
    );
  }
}
class SettingsWidget extends StatelessWidget {
  final bool twoColumns;

  const SettingsWidget({
    Key? key,
    required this.twoColumns,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serversProvider = Provider.of<ServersProvider>(context);
    final statusProvider = Provider.of<StatusProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);

    final width = MediaQuery.of(context).size.width;

    if (!twoColumns && appConfigProvider.selectedSettingsScreen != null) {
      appConfigProvider.setSelectedSettingsScreen(screen: null);
    }

    Widget settingsTile({
      required String title,
      required String subtitle,
      required IconData icon,
      Widget? trailing,
      required Widget screenToNavigate,
      required int thisItem
    }) {
      if (twoColumns) {
        return CustomSettingsTile(
          title: title, 
          subtitle: subtitle,
          icon: icon,
          trailing: trailing,
          thisItem: thisItem, 
          selectedItem: appConfigProvider.selectedSettingsScreen,
          onTap: () {
            appConfigProvider.setSelectedSettingsScreen(screen: thisItem, notify: true);
            SplitView.of(context).setSecondary(screenToNavigate);
          },
        );
      }
      else {
        return CustomListTile(
          title: title,
          subtitle: subtitle,
          icon: icon,
          trailing: trailing,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => screenToNavigate)
            );
          },
        );
      }
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar.large(
              pinned: true,
              floating: true,
              centerTitle: false,
              forceElevated: innerBoxIsScrolled,
              surfaceTintColor: isDesktop(width) ? Colors.transparent : null,
              title: Text(AppLocalizations.of(context)!.settings),
            )
          )
        ], 
        body: SafeArea(
          top: false,
          bottom: false,
          child: Builder(
            builder: (context) => CustomScrollView(
              slivers: [
                SliverOverlapInjector(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                ),
                SliverList.list(
                  children: [
                    if (
                      serversProvider.selectedServer != null && 
                      statusProvider.serverStatus != null && 
                      serversProvider.apiClient != null
                    ) ...[
                      SectionLabel(label: AppLocalizations.of(context)!.serverSettings),
                      if (serverVersionIsAhead(
                        currentVersion: statusProvider.serverStatus!.serverVersion, 
                        referenceVersion: 'v0.107.28',
                        referenceVersionBeta: 'v0.108.0-b.33'
                      ) == true) settingsTile(
                        icon: Icons.search_rounded,
                        title: AppLocalizations.of(context)!.safeSearch,
                        subtitle: AppLocalizations.of(context)!.safeSearchSettings,
                        thisItem: 0,
                        screenToNavigate: const SafeSearchSettingsScreen(),
                      ),
                      settingsTile(
                        icon: Icons.lock_rounded,
                        title: AppLocalizations.of(context)!.accessSettings,
                        subtitle: AppLocalizations.of(context)!.accessSettingsDescription,
                        thisItem: 1,
                        screenToNavigate: const AccessSettings(),
                      ),
                      settingsTile(
                        icon: Icons.install_desktop_rounded,
                        title: AppLocalizations.of(context)!.dhcpSettings,
                        subtitle: AppLocalizations.of(context)!.dhcpSettingsDescription,
                        thisItem: 2,
                        screenToNavigate: const DhcpScreen(),
                      ),
                      settingsTile(
                        icon: Icons.dns_rounded,
                        title: AppLocalizations.of(context)!.dnsSettings,
                        subtitle: AppLocalizations.of(context)!.dnsSettingsDescription,
                        thisItem: 3,
                        screenToNavigate: const DnsSettings(),
                      ),
                      settingsTile(
                        icon: Icons.security_rounded,
                        title: AppLocalizations.of(context)!.encryptionSettings,
                        subtitle: AppLocalizations.of(context)!.encryptionSettingsDescription,
                        thisItem: 4,
                        screenToNavigate: const EncryptionSettings(),
                      ),
                      settingsTile(
                        icon: Icons.route_rounded,
                        title: AppLocalizations.of(context)!.dnsRewrites,
                        subtitle: AppLocalizations.of(context)!.dnsRewritesDescription,
                        thisItem: 5,
                        screenToNavigate: const DnsRewritesScreen(),
                      ),
                      if (serversProvider.updateAvailable.data != null) settingsTile(
                        icon: Icons.system_update_rounded,
                        title: AppLocalizations.of(context)!.updates,
                        subtitle: AppLocalizations.of(context)!.updatesDescription,
                        trailing: serversProvider.updateAvailable.data != null &&
                          serversProvider.updateAvailable.data!.canAutoupdate == true
                            ? Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.red
                                ),
                              )
                            : null,
                        thisItem: 6,
                        screenToNavigate: const UpdateScreen(),
                      ),
                      settingsTile(
                        icon: Icons.info_rounded,
                        title: AppLocalizations.of(context)!.serverInformation,
                        subtitle: AppLocalizations.of(context)!.serverInformationDescription,
                        thisItem: 7,
                        screenToNavigate: const ServerInformation(),
                      ),
                    ],
                    SectionLabel(label: AppLocalizations.of(context)!.appSettings),
                    settingsTile(
                      icon: Icons.palette_rounded,
                      title: AppLocalizations.of(context)!.customization, 
                      subtitle: AppLocalizations.of(context)!.customizationDescription,
                      thisItem: 8,
                      screenToNavigate: const Customization(),
                    ),
                    settingsTile(
                      icon: Icons.storage_rounded,
                      title: AppLocalizations.of(context)!.servers,
                      subtitle: serversProvider.selectedServer != null
                        ? statusProvider.serverStatus != null
                          ? "${AppLocalizations.of(context)!.connectedTo} ${serversProvider.selectedServer!.name}"
                          : "${AppLocalizations.of(context)!.selectedServer} ${serversProvider.selectedServer!.name}"
                        : AppLocalizations.of(context)!.noServerSelected,
                      thisItem: 9,
                      screenToNavigate: const Servers(),
                    ),
                    settingsTile(
                      icon: Icons.settings,
                      title: AppLocalizations.of(context)!.generalSettings,
                      subtitle: AppLocalizations.of(context)!.generalSettingsDescription,
                      thisItem: 10,
                      screenToNavigate: const GeneralSettings(),
                    ),
                    settingsTile(
                      icon: Icons.build_outlined,
                      title: AppLocalizations.of(context)!.advancedSettings,
                      subtitle: AppLocalizations.of(context)!.advancedSetupDescription,
                      thisItem: 11,
                      screenToNavigate: const AdvancedSettings(),
                    ),
                    SectionLabel(label: AppLocalizations.of(context)!.aboutApp),
                    CustomListTile(
                      title: AppLocalizations.of(context)!.appVersion, 
                      subtitle: appConfigProvider.getAppInfo!.version,
                    ),
                    CustomListTile(
                      title: AppLocalizations.of(context)!.createdBy, 
                      subtitle: Strings.createdBy,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (Platform.isAndroid) IconButton(
                            onPressed: () => openUrl(Urls.playStore), 
                            icon: SvgPicture.asset(
                              'assets/resources/google-play.svg',
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              width: 30,
                              height: 30,
                            ),
                            tooltip: AppLocalizations.of(context)!.visitGooglePlay,
                          ),
                          IconButton(
                            onPressed: () => openUrl(Urls.gitHub), 
                            icon: SvgPicture.asset(
                              'assets/resources/github.svg',
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              width: 30,
                              height: 30,
                            ),
                            tooltip: AppLocalizations.of(context)!.gitHub,
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            )
          ),
        ),
      )
    );
  }
}