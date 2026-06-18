import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:asar_field_worker/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/auth_remote_datasource.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../blocs/settings/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = const FlutterSecureStorage();
  String _workerName = '';
  String _workerId = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name =
        await _storage.read(key: AppConstants.storageKeyWorkerName) ?? '';
    final id = await _storage.read(key: AppConstants.storageKeyWorkerId) ?? '';
    if (mounted) setState(() { _workerName = name; _workerId = id; });
  }

  void _confirmLogout(AppLocalizations l) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.signOutConfirmTitle),
        content: Text(l.signOutConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.go('/auth/login');
            },
            child: Text(
              l.signOut,
              style: const TextStyle(color: AppColors.priorityCritical),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePassword(AppLocalizations l) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _ChangePasswordSheet(l: l),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) context.go('/auth/login');
      },
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.operationalBlue,
              foregroundColor: Colors.white,
              title: Text(
                l.settings,
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevation: 0,
            ),
            body: ListView(
              children: [
                const SizedBox(height: 16),
                _ProfileCard(
                  name: _workerName,
                  workerId: _workerId,
                  workerBadge: l.workerBadge,
                  defaultName: l.defaultWorkerName,
                ),
                const SizedBox(height: 16),
                _SectionLabel(l.sectionAccount),
                _SettingsTile(
                  icon: Icons.lock_outline,
                  label: l.changePassword,
                  onTap: () => _showChangePassword(l),
                ),
                const SizedBox(height: 16),
                _SectionLabel(l.sectionAppearance),
                _LanguageTile(currentLocale: settings.locale),
                _ThemeTile(
                  label: l.darkMode,
                  isDark: settings.themeMode == ThemeMode.dark,
                ),
                const SizedBox(height: 16),
                _SectionLabel(l.sectionAbout),
                _SettingsTile(
                  icon: Icons.info_outline,
                  label: l.appVersion,
                  trailing: const Text(
                    '1.0.0',
                    style: TextStyle(
                      color: AppColors.onSurfaceMuted,
                      fontFamily: 'IBMPlexSans',
                      fontSize: 13,
                    ),
                  ),
                ),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  label: l.privacyPolicy,
                  onTap: () => _showPrivacyPolicy(context, l),
                ),
                const SizedBox(height: 16),
                _SectionLabel(l.sectionSupport),
                _SettingsTile(
                  icon: Icons.headset_mic_outlined,
                  label: l.contactSupport,
                  onTap: () => context.push('/support-chat'),
                ),
                const SizedBox(height: 16),
                _SectionLabel(l.sectionSession),
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  label: l.signOut,
                  labelColor: AppColors.priorityCritical,
                  iconColor: AppColors.priorityCritical,
                  onTap: () => _confirmLogout(l),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context, AppLocalizations l) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.privacyPolicy),
        content: SingleChildScrollView(child: Text(l.privacyPolicyText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.close),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Language tile
// ---------------------------------------------------------------------------

class _LanguageTile extends StatelessWidget {
  final Locale currentLocale;
  const _LanguageTile({required this.currentLocale});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final current = currentLocale.languageCode;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(Icons.language, color: scheme.onSurface, size: 22),
          const SizedBox(width: 14),
          Text(
            l.language,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'IBMPlexSans',
              color: scheme.onSurface,
            ),
          ),
          const Spacer(),
          _LangButton(code: 'kk', label: 'ҚАЗ', current: current),
          const SizedBox(width: 6),
          _LangButton(code: 'en', label: 'ENG', current: current),
          const SizedBox(width: 6),
          _LangButton(code: 'ru', label: 'РУС', current: current),
        ],
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String code;
  final String label;
  final String current;

  const _LangButton({
    required this.code,
    required this.label,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = current == code;
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.read<SettingsCubit>().setLocale(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.operationalBlue
              : AppColors.operationalBlue.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? AppColors.operationalBlue
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            fontFamily: 'IBMPlexSans',
            letterSpacing: 0.4,
            color: isSelected ? Colors.white : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Theme toggle tile
// ---------------------------------------------------------------------------

class _ThemeTile extends StatelessWidget {
  final String label;
  final bool isDark;

  const _ThemeTile({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        leading: Icon(
          isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
          color: scheme.onSurface,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'IBMPlexSans',
            color: scheme.onSurface,
          ),
        ),
        trailing: Switch(
          value: isDark,
          onChanged: (v) => context.read<SettingsCubit>().setThemeMode(
                v ? ThemeMode.dark : ThemeMode.light,
              ),
          activeColor: AppColors.operationalBlue,
        ),
        dense: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile card
// ---------------------------------------------------------------------------

class _ProfileCard extends StatelessWidget {
  final String name;
  final String workerId;
  final String workerBadge;
  final String defaultName;

  const _ProfileCard({
    required this.name,
    required this.workerId,
    required this.workerBadge,
    required this.defaultName,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'W';
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.operationalBlue,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'IBMPlexSans',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? defaultName : name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'IBMPlexSans',
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.operationalBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    workerBadge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.operationalBlue,
                      fontFamily: 'IBMPlexSans',
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared section label and tile
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceMuted,
          fontFamily: 'IBMPlexSans',
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? labelColor;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.labelColor,
    this.iconColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? scheme.onSurface, size: 22),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'IBMPlexSans',
            color: labelColor ?? scheme.onSurface,
          ),
        ),
        trailing: trailing ??
            (onTap != null
                ? Icon(
                    Icons.chevron_right,
                    color: scheme.onSurface.withOpacity(0.6),
                    size: 20,
                  )
                : null),
        onTap: onTap,
        dense: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Change password bottom sheet
// ---------------------------------------------------------------------------

class _ChangePasswordSheet extends StatefulWidget {
  final AppLocalizations l;
  const _ChangePasswordSheet({required this.l});

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await AuthRemoteDataSource()
          .changePassword(_currentCtrl.text, _newCtrl.text);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = widget.l.changePasswordError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20,),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.changePassword,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                fontFamily: 'IBMPlexSans',
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.priorityCritical,
                    fontFamily: 'IBMPlexSans',
                    fontSize: 13,
                  ),
                ),
              ),
            TextFormField(
              controller: _currentCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: l.currentPassword),
              validator: (v) =>
                  v == null || v.isEmpty ? l.validationCurrentPassword : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: l.newPassword),
              validator: (v) {
                if (v == null || v.isEmpty) return l.validationNewPassword;
                if (v.length < 8) return l.validationMinChars;
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l.updatePassword),
            ),
          ],
        ),
      ),
    );
  }
}
