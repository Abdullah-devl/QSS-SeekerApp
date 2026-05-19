import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/qs_color_extension.dart';
import '../viewmodels/system_complaints_viewmodel.dart';
import 'submit_system_complaint_view.dart';
import 'package:seeker/l10n/app_localizations.dart';

class SystemComplaintsListView extends StatefulWidget {
  const SystemComplaintsListView({super.key});

  @override
  State<SystemComplaintsListView> createState() => _SystemComplaintsListViewState();
}

class _SystemComplaintsListViewState extends State<SystemComplaintsListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemComplaintsViewModel>().fetchComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SystemComplaintsViewModel>();
    final colors = context.qsColors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l10n.myTechnicalReports),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colors.background,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubmitSystemComplaintView()),
          );
        },
        backgroundColor: colors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.addNewReport,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: colors.primary,
        onRefresh: () => viewModel.fetchComplaints(),
        child: _buildBody(context, viewModel),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SystemComplaintsViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    if (viewModel.isLoading && viewModel.complaints.isEmpty) {
      return Center(child: CircularProgressIndicator(color: context.qsColors.primary));
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: context.qsColors.error),
            const SizedBox(height: 16),
            Text(l10n.errorLoadingData),
            TextButton(
              onPressed: () => viewModel.fetchComplaints(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (viewModel.complaints.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.speaker_notes_off_outlined, size: 64, color: context.qsColors.textSub),
                const SizedBox(height: 16),
                Text(
                  l10n.noSystemReports,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.complaints.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final complaint = viewModel.complaints[index];
        return _buildComplaintCard(context, complaint);
      },
    );
  }

  Widget _buildComplaintCard(BuildContext context, dynamic complaint) {
    final colors = context.qsColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.text.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  complaint.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusBadge(context, complaint.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            complaint.content,
            style: TextStyle(fontSize: 14, color: colors.textSub, height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.category_outlined, size: 14, color: colors.primary),
              const SizedBox(width: 4),
              Text(
                _getTypeLabel(context, complaint.type),
                style: TextStyle(fontSize: 12, color: colors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case 'type_technical': return l10n.typeTechnical;
      case 'type_account': return l10n.typeAccount;
      case 'type_financial_system': return l10n.typeFinancialSystem;
      case 'type_suggestion': return l10n.typeSuggestion;
      default: return l10n.typeOther;
    }
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    String label;
    final colors = context.qsColors;
    final l10n = AppLocalizations.of(context)!;

    switch (status) {
      case 'resolved':
        color = colors.success;
        label = l10n.statusResolved;
        break;
      case 'closed':
        color = colors.textSub;
        label = l10n.statusClosed;
        break;
      case 'in_progress':
      case 'processing':
        color = colors.primary;
        label = l10n.statusInProgress;
        break;
      case 'rejected':
        color = colors.error;
        label = l10n.statusRejected;
        break;
      case 'pending':
      default:
        color = colors.warning;
        label = l10n.statusPending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


