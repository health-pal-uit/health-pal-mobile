import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/health_sync_bloc.dart';

class HealthConnectScreen extends StatefulWidget {
  const HealthConnectScreen({super.key});

  @override
  State<HealthConnectScreen> createState() => _HealthConnectScreenState();
}

class _HealthConnectScreenState extends State<HealthConnectScreen> {
  @override
  void initState() {
    super.initState();
    // Tự động check status khi mở màn hình
    context.read<HealthSyncBloc>().add(CheckStatusRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Connect'), centerTitle: true),
      body: BlocBuilder<HealthSyncBloc, HealthSyncState>(
        builder: (context, state) {
          if (state is HealthSyncLoading || state is HealthSyncInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HealthSyncError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '❌ Error: ${state.message}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => context.read<HealthSyncBloc>().add(
                          CheckStatusRequested(),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is HealthSyncData) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, HealthSyncData status) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusCard(status),
          const SizedBox(height: 24),

          if (!status.connected)
            ElevatedButton.icon(
              onPressed:
                  () => context.read<HealthSyncBloc>().add(
                    ConnectHealthRequested(),
                  ),
              icon: const Icon(Icons.link),
              label: const Text('🔌 Connect Health Connect'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            )
          else ...[
            ElevatedButton.icon(
              onPressed:
                  () => context.read<HealthSyncBloc>().add(SyncDataRequested()),
              icon: const Icon(Icons.cloud_upload),
              label: const Text('⬆️ Sync Now'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed:
                  () => context.read<HealthSyncBloc>().add(
                    CheckStatusRequested(),
                  ),
              icon: const Icon(Icons.refresh),
              label: const Text('🔍 Check Status'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showDisconnectDialog(context),
              icon: const Icon(Icons.link_off),
              label: const Text('❌ Disconnect'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(HealthSyncData status) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: status.connected ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status.connected ? 'Connected' : 'Disconnected',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (status.lastSyncedAt != null)
              Text(
                'Last Synced: ${status.lastSyncedAt.toString().substring(0, 16)}',
              ),
            if (status.totalSynced > 0)
              Text(
                'Total Synced: ${status.totalSynced} records',
                style: const TextStyle(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Disconnect?'),
            content: const Text('Stop syncing data with Health Connect?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<HealthSyncBloc>().add(
                    DisconnectHealthRequested(),
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text(
                  'Disconnect',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
