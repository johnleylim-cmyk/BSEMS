import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../app/theme.dart';
import '../../providers/athlete_provider.dart';
import '../../providers/team_provider.dart';
import '../../providers/tournament_provider.dart';
import '../../providers/match_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Reports & Export', style: Theme.of(context).textTheme.displaySmall).animate().fadeIn(),
          const SizedBox(height: 8),
          Text('Generate PDF reports for printing or sharing', style: Theme.of(context).textTheme.bodyMedium).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 28),

          LayoutBuilder(builder: (context, constraints) {
            final cols = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                _ReportCard(
                  title: 'Athletes Report',
                  subtitle: 'Full list of all registered athletes',
                  icon: Icons.people,
                  color: AppTheme.accentCyan,
                  onGenerate: () => _generateAthletesReport(context),
                ),
                _ReportCard(
                  title: 'Teams Report',
                  subtitle: 'All teams with standings and records',
                  icon: Icons.groups,
                  color: AppTheme.accentPurple,
                  onGenerate: () => _generateTeamsReport(context),
                ),
                _ReportCard(
                  title: 'Tournament Report',
                  subtitle: 'Tournament brackets and results',
                  icon: Icons.emoji_events,
                  color: AppTheme.accentOrange,
                  onGenerate: () => _generateTournamentReport(context),
                ),
                _ReportCard(
                  title: 'Leaderboard Report',
                  subtitle: 'Team rankings by win rate',
                  icon: Icons.leaderboard,
                  color: AppTheme.accentGreen,
                  onGenerate: () => _generateLeaderboardReport(context),
                ),
                _ReportCard(
                  title: 'Match Results',
                  subtitle: 'All match scores and outcomes',
                  icon: Icons.sports_esports,
                  color: AppTheme.accentPink,
                  onGenerate: () => _generateMatchReport(context),
                ),
              ],
            );
          }),
        ]),
      ),
    );
  }

  void _generateAthletesReport(BuildContext context) {
    final athletes = context.read<AthleteProvider>().athletes;

    Printing.layoutPdf(onLayout: (format) async {
      final doc = pw.Document();
      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (ctx) => _pdfHeader('Athletes Report'),
        footer: (ctx) => _pdfFooter(ctx),
        build: (ctx) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerLeft, 2: pw.Alignment.center, 3: pw.Alignment.centerLeft, 4: pw.Alignment.centerLeft},
            headers: ['Name', 'Gender', 'Age', 'Barangay', 'Contact'],
            data: athletes.map((a) => [a.fullName, a.gender.label, '${a.age}', a.barangay, a.contactNumber ?? '-']).toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Text('Total Athletes: ${athletes.length}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ));
      return doc.save();
    });
  }

  void _generateTeamsReport(BuildContext context) {
    final teams = context.read<TeamProvider>().teams;

    Printing.layoutPdf(onLayout: (format) async {
      final doc = pw.Document();
      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (ctx) => _pdfHeader('Teams Report'),
        footer: (ctx) => _pdfFooter(ctx),
        build: (ctx) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headers: ['Team Name', 'Type', 'Members', 'Wins', 'Losses', 'Draws', 'Win Rate'],
            data: teams.map((t) => [t.name, t.sportType.label, '${t.memberIds.length}', '${t.wins}', '${t.losses}', '${t.draws}', '${t.winRate.toStringAsFixed(1)}%']).toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Text('Total Teams: ${teams.length}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ));
      return doc.save();
    });
  }

  void _generateTournamentReport(BuildContext context) {
    final tournaments = context.read<TournamentProvider>().tournaments;

    Printing.layoutPdf(onLayout: (format) async {
      final doc = pw.Document();
      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (ctx) => _pdfHeader('Tournament Report'),
        footer: (ctx) => _pdfFooter(ctx),
        build: (ctx) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headers: ['Tournament', 'Format', 'Status', 'Teams'],
            data: tournaments.map((t) => [t.name, t.format.label, t.status.label, '${t.teamIds.length}']).toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Text('Total Tournaments: ${tournaments.length}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ));
      return doc.save();
    });
  }

  void _generateLeaderboardReport(BuildContext context) {
    final teams = List.of(context.read<TeamProvider>().teams)..sort((a, b) => b.wins.compareTo(a.wins));

    Printing.layoutPdf(onLayout: (format) async {
      final doc = pw.Document();
      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (ctx) => _pdfHeader('Leaderboard Report'),
        footer: (ctx) => _pdfFooter(ctx),
        build: (ctx) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headers: ['Rank', 'Team', 'Wins', 'Losses', 'Win Rate'],
            data: teams.asMap().entries.map((e) => ['#${e.key + 1}', e.value.name, '${e.value.wins}', '${e.value.losses}', '${e.value.winRate.toStringAsFixed(1)}%']).toList(),
          ),
        ],
      ));
      return doc.save();
    });
  }

  void _generateMatchReport(BuildContext context) {
    final matches = context.read<MatchProvider>().matches;

    Printing.layoutPdf(onLayout: (format) async {
      final doc = pw.Document();
      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (ctx) => _pdfHeader('Match Results Report'),
        footer: (ctx) => _pdfFooter(ctx),
        build: (ctx) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headers: ['Round', 'Team 1', 'Score', 'Team 2', 'Status'],
            data: matches.map((m) => ['R${m.round}', m.team1Name ?? 'TBD', '${m.score1} - ${m.score2}', m.team2Name ?? 'TBD', m.status.label]).toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Text('Total Matches: ${matches.length}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ));
      return doc.save();
    });
  }

  pw.Widget _pdfHeader(String title) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text('BSEMS — Barangay Sports & Esports Management System', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
      pw.SizedBox(height: 4),
      pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      pw.Divider(),
      pw.SizedBox(height: 8),
    ]);
  }

  pw.Widget _pdfFooter(pw.Context ctx) {
    return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Text('Generated by BSEMS', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
      pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
    ]);
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onGenerate;

  const _ReportCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        const Spacer(),
        GradientButton(label: 'Generate PDF', icon: Icons.picture_as_pdf, onPressed: onGenerate, height: 36),
      ]),
    );
  }
}
