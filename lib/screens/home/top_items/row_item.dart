import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:adguard_home_manager/widgets/domain_options.dart';

import 'package:adguard_home_manager/models/applied_filters.dart';
import 'package:adguard_home_manager/providers/app_config_provider.dart';
import 'package:adguard_home_manager/providers/logs_provider.dart';
import 'package:adguard_home_manager/providers/status_provider.dart';

class RowItem extends StatelessWidget {
  final String type;
  final Color chartColor;
  final String domain;
  final String number;
  final bool clients;
  final bool showColor;

  const RowItem({
    Key? key,
    required this.type,
    required this.chartColor,
    required this.domain,
    required this.number,
    required this.clients,
    required this.showColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusProvider = Provider.of<StatusProvider>(context);
    final appConfigProvider = Provider.of<AppConfigProvider>(context);
    final logsProvider = Provider.of<LogsProvider>(context);

    String? name;
    if (clients == true) {
      try {
        name = statusProvider.serverStatus!.clients.firstWhere((c) => c.ids.contains(domain)).name;
      } catch (e) {
        // ---- //
      }
    }

    return Material(
      color: Colors.transparent,
      child: DomainOptions(
        item: domain,
        isClient: type == 'topClients',
        isBlocked: type == 'topBlockedDomains',
        onTap: () {
          if (type == 'topQueriedDomains' || type == 'topBlockedDomains') {
            logsProvider.setSearchText(domain);
            logsProvider.setSelectedClients(null);
            logsProvider.setAppliedFilters(
              AppliedFiters(
                selectedResultStatus: 'all', 
                searchText: domain,
                clients: null
              )
            );
            appConfigProvider.setSelectedScreen(2);
          }
          else if (type == 'topClients') {
            logsProvider.setSearchText(null);
            logsProvider.setSelectedClients([domain]);
            logsProvider.setAppliedFilters(
              AppliedFiters(
                selectedResultStatus: 'all', 
                searchText: null,
                clients: [domain]
              )
            );
            appConfigProvider.setSelectedScreen(2);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.ease,
                      margin: EdgeInsets.only(right: showColor ? 16 : 0),
                      width: showColor ? 12 : 0,
                      height: showColor ? 12 : 0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: chartColor
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            domain,
                            overflow: TextOverflow.ellipsis,
                            style:  TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface
                            ),
                          ),
                          if (name != null) ...[
                            const SizedBox(height: 5),
                            Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurfaceVariant
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                number,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OthersRowItem extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final bool showColor;

  const OthersRowItem({
    Key? key,
    required this.items,
    required this.showColor,
  }) : super(key: key);

  @override
  State<OthersRowItem> createState() => _OthersRowItemState();
}

class _OthersRowItemState extends State<OthersRowItem> with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation; 

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  void prepareAnimations() {
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200)
    );
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.ease,
    );
  }

  void _runExpandCheck() {
    if (widget.showColor) {
      expandController.forward();
    }
    else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.length <= 5) {
      return const SizedBox();
    }

    return SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.others,
                          overflow: TextOverflow.ellipsis,
                          style:  TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              List<int>.from(
                widget.items.sublist(5, widget.items.length).map((e) => e.values.first.toInt())
              ).reduce((a, b) => a + b).toString(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface
              ),
            )
          ],
        ),
      ),
    );
  }
}