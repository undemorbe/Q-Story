import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_info.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/gothic_widgets.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../places/domain/entities/place_source.dart';
import '../../../places/presentation/widgets/place_labels.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _open(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    Widget header(String t) => Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(t.toUpperCase(),
              style:
                  GoogleFonts.cinzel(color: context.gold, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w700)),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: Column(children: [
              Icon(Icons.explore, size: 64, color: context.gold),
              const SizedBox(height: 8),
              Text(AppInfo.name,
                  style: GoogleFonts.cinzelDecorative(fontSize: 28, fontWeight: FontWeight.bold, color: context.onBg)),
              Text(l.aboutTagline,
                  style: GoogleFonts.crimsonText(fontSize: 18, fontStyle: FontStyle.italic, color: context.onBg)),
              const SizedBox(height: 4),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (_, snap) => Text(
                  snap.hasData ? 'v${snap.data!.version} (${snap.data!.buildNumber})' : 'v${AppInfo.version}',
                  style: theme.textTheme.labelSmall?.copyWith(color: context.dim),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          const GothicDivider(),
          const SizedBox(height: 12),
          Text(l.aboutDescription, style: theme.textTheme.bodyLarge),
          header(l.aboutDataTitle),
          for (final s in PlaceSource.remote)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(s.icon, color: s.color),
              title: Text(s.label(l)),
              subtitle: Text('${s.description(l)}\n${s.license}'),
              isThreeLine: true,
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _open(s.homepage),
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.today_outlined),
            title: Text(l.onThisDayTitle),
            subtitle: Text(l.wikipediaSource),
          ),
          header(l.aboutPrivacyTitle),
          Text(l.aboutPrivacyText, style: theme.textTheme.bodyMedium),
          header(l.aboutTeam),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.phone_android),
            title: Text('Борис Станьков'),
            subtitle: Text('Mobile · Flutter'),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.history_edu),
            title: Text('Андрей Корнев'),
            subtitle: Text('History research'),
          ),
          header(l.aboutLicenseTitle),
          Text('${AppInfo.license} · © 2024–${DateTime.now().year} Boris Stankov, Andrey Kornev',
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            OutlinedButton.icon(
                onPressed: () => _open(AppInfo.repositoryUrl),
                icon: const Icon(Icons.code),
                label: Text(l.aboutSourceCode)),
            OutlinedButton.icon(
                onPressed: () => _open(AppInfo.issuesUrl),
                icon: const Icon(Icons.bug_report_outlined),
                label: Text(l.aboutReportIssue)),
            OutlinedButton.icon(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: AppInfo.name,
                applicationLegalese: AppInfo.license,
              ),
              icon: const Icon(Icons.gavel_outlined),
              label: Text(l.openSourceLicenses),
            ),
          ]),
        ],
      ),
    );
  }
}
