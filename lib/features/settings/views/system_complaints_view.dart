import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seeker/core/routes/app_routes.dart';
import 'package:seeker/core/theme/qs_color_extension.dart';
import 'package:seeker/features/home/viewmodels/home_view_model.dart';
import 'package:seeker/l10n/app_localizations.dart';
import '../viewmodels/system_complaints_view_model.dart';

class SystemComplaintsView extends StatefulWidget {
  const SystemComplaintsView({super.key});

  @override
  State<SystemComplaintsView> createState() => _SystemComplaintsViewState();
}

class _SystemComplaintsViewState extends State<SystemComplaintsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = context.read<HomeViewModel>().role;
      context.read<SystemComplaintsViewModel>().fetchComplaints(role);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<SystemComplaintsViewModel>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.systemComplaints,
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
            color: colors.text,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createSystemComplaint),
        backgroundColor: colors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildBody(vm, colors, l10n),
    );
  }

  Widget _buildBody(SystemComplaintsViewModel vm, dynamic colors, AppLocalizations l10n) {
    if (vm.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colors.primary),
      );
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(vm.errorMessage!, style: TextStyle(color: colors.text)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final role = context.read<HomeViewModel>().role;
                  vm.fetchComplaints(role);
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 80, color: colors.textSub.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              l10n.noComplaints,
              style: TextStyle(color: colors.textSub, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final role = context.read<HomeViewModel>().role;
        await context.read<SystemComplaintsViewModel>().fetchComplaints(role);
      },
      color: colors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(), // لضمان عمل السحب حتى لو القائمة قصيرة
        itemCount: vm.complaints.length,
        itemBuilder: (context, index) {
        final complaint = vm.complaints[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.textSub.withOpacity(0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        complaint.title,
                        style: TextStyle(
                          color: colors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildStatusBadge(complaint.status, colors, l10n),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.category}: ${complaint.type}',
                  style: TextStyle(color: colors.primary, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  complaint.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textSub, fontSize: 14),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      complaint.formattedDate,
                      style: TextStyle(color: colors.textSub, fontSize: 12),
                    ),
                    Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.arrow_back_ios
                          : Icons.arrow_forward_ios,
                      size: 14,
                      color: colors.textSub,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ));
  }

  Widget _buildStatusBadge(String status, dynamic colors, AppLocalizations l10n) {
    Color color;
    String text;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = l10n.statusPending;
        break;
      case 'in_progress':
        color = Colors.blue;
        text = l10n.statusInProgress;
        break;
      case 'resolved':
        color = Colors.green;
        text = l10n.statusResolved;
        break;
      case 'rejected':
        color = Colors.red;
        text = l10n.statusRejected;
        break;
      case 'closed':
        color = Colors.grey;
        text = l10n.statusClosed;
        break;
      default:
        color = colors.textSub;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
