import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showMenuPopUp(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, secondaryAnim, child) {
      final offsetAnim = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));

      return SlideTransition(
        position: offsetAnim,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 70, left: 16, right: 16),
            child: _MenuPopUpContent(parentContext: context),
          ),
        ),
      );
    },
  );
}

class _MenuPopUpContent extends StatelessWidget {
  final BuildContext parentContext;

  const _MenuPopUpContent({required this.parentContext});

  void showFeatureNotReady(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur ini sedang dalam pengembangan'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width < 400) {
      // Mobile kecil
      return 4;
    } else if (width < 600) {
      // Mobile besar
      return 4;
    } else if (width < 900) {
      // Tablet
      return 5;
    } else {
      // Desktop
      return 6;
    }
  }

  double _getChildAspectRatio(double width) {
    if (width < 400) {
      return 0.75;
    } else if (width < 600) {
      return 0.85;
    } else if (width < 900) {
      return 0.90;
    } else {
      return 0.95;
    }
  }

  double _getIconSize(double width) {
    if (width < 400) {
      return 28;
    } else if (width < 600) {
      return 36;
    } else if (width < 900) {
      return 40;
    } else {
      return 44;
    }
  }

  double _getContainerSize(double width) {
    if (width < 400) {
      return 64;
    } else if (width < 600) {
      return 80;
    } else if (width < 900) {
      return 90;
    } else {
      return 100;
    }
  }

  double _getFontSize(double width) {
    if (width < 400) {
      return 9;
    } else if (width < 600) {
      return 11;
    } else if (width < 900) {
      return 12;
    } else {
      return 13;
    }
  }

  double _getSpacing(double width) {
    if (width < 400) {
      return 8;
    } else if (width < 600) {
      return 12;
    } else if (width < 900) {
      return 14;
    } else {
      return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.event,
        'title': 'Kegiatan',
        'action': () => context.push('/kegiatan'),
      },
      {
        'icon': Icons.attach_money,
        'title': 'Pemasukan',
        'action': () => context.push('/menu-pemasukan'),
      },
      {
        'icon': Icons.attach_money,
        'title': 'Pengeluaran',
        'action': () => context.push('/pengeluaran'),
      },
      {
        'icon': Icons.attach_money,
        'title': 'Laporan Keuangan',
        'action': () => context.push('/laporan-keuangan'),
      },
      {
        'icon': Icons.event,
        'title': 'Broadcast',
        'action': () => context.push('/broadcast'),
      },
      {
        'icon': Icons.people_alt,
        'title': 'Warga & Rumah',
        'action': () => context.push('/data-warga-rumah'),
      },
      {
        'icon': Icons.message_rounded,
        'title': 'Pesan Warga',
        'action': () => showFeatureNotReady(context),
      },
      {
        'icon': Icons.people_alt,
        'title': 'Penerimaan Warga',
        'action': () => context.push('/penerimaan-warga'),
      },
      {
        'icon': Icons.people_alt,
        'title': 'Mutasi Keluarga',
        'action': () => context.push('/mutasi'),
      },
      {
        'icon': Icons.swap_horiz,
        'title': 'Channel Transfer',
        'action': () => context.push('/channel-transfer'),
      },
      {
        'icon': Icons.shopping_bag_outlined,
        'title': 'Marketplace',
        'action': () => showFeatureNotReady(context),
      },
      {
        'icon': Icons.lightbulb_outline,
        'title': 'Aspirasi',
        'action': () => context.push('/dashboard-aspirasi'),
      },
      {
        'icon': Icons.history,
        'title': 'Log Aktifitas',
        'action': () => context.push('/log-aktivitas'),
      },
    ];

    final crossAxisCount = _getCrossAxisCount(width);
    final childAspectRatio = _getChildAspectRatio(width);
    final iconSize = _getIconSize(width);
    final containerSize = _getContainerSize(width);
    final fontSize = _getFontSize(width);
    final spacing = _getSpacing(width);

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: width > 900 ? 900 : width),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: GridView.builder(
          padding: EdgeInsets.all(spacing),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: menuItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing * 0.8,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return InkWell(
              onTap: () {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 100), () {
                  item['action']();
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: containerSize,
                    height: containerSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A89D),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00A89D).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      item['icon'],
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: spacing * 0.7),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing * 0.5),
                      child: Text(
                        item['title'],
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: fontSize,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
