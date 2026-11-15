import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

class ProviderDetailScreen extends StatelessWidget {
  const ProviderDetailScreen({super.key, required this.pro});
  final ServicePro pro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(pro: pro)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Column(
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('About',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Text(
                          pro.about,
                          style: const TextStyle(
                              fontSize: 13.5,
                              color: AppColors.muted,
                              height: 1.7),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Expertise',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.05,
                          children: [
                            for (final e in pro.expertise)
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F4F9),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(e.icon,
                                        size: 22, color: AppColors.primary),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Text(
                                        e.label,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          height: 1.25,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Reviews',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700)),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 17, color: AppColors.star),
                                const SizedBox(width: 4),
                                Text(
                                  '${pro.rating} (${pro.reviews} reviews)',
                                  style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        for (final r in pro.testimonials)
                          _ReviewTile(review: r),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ContactCard(pro: pro),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Operating Area',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SoftIconBox(Icons.map_outlined,
                                size: 44, iconSize: 21),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                pro.operatingArea,
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    color: AppColors.muted,
                                    height: 1.55),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        actionLabel: 'Request a callback',
        trailingIcon: Icons.phone_in_talk_rounded,
        onAction: () => showAppSnack(
          context,
          '${pro.name} will call you back shortly.',
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.pro});
  final ServicePro pro;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B4EA2), Color(0xFF1565D8)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Partner Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pro.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pro.profession.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: ClipOval(child: AppImage(pro.photo)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _GlassPill(
                      icon: Icons.star_rounded,
                      label: '${pro.rating} Rating',
                    ),
                    _GlassPill(
                      icon: Icons.work_outline_rounded,
                      label: '${pro.years}+ Yrs',
                    ),
                    _GlassPill(
                      icon: Icons.location_on_outlined,
                      label: '${pro.distance} mi',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.tintSurface,
                child: Text(
                  review.name.characters.first,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      review.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.when,
                      style: const TextStyle(
                          fontSize: 11.5, color: AppColors.faint),
                    ),
                  ],
                ),
              ),
              StarRating(review.rating),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.body,
            style: const TextStyle(
                fontSize: 13, color: AppColors.muted, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.pro});
  final ServicePro pro;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FB),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact information',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primary),
          ),
          const SizedBox(height: 18),
          _ContactRow(
              icon: Icons.mail_outline_rounded,
              label: 'EMAIL ADDRESS',
              value: pro.email),
          const SizedBox(height: 14),
          _ContactRow(
              icon: Icons.phone_rounded,
              label: 'PHONE NUMBER',
              value: pro.phone),
          const SizedBox(height: 14),
          _ContactRow(
              icon: Icons.apartment_rounded,
              label: 'OFFICE LOCATION',
              value: pro.office),
          const SizedBox(height: 18),
          const Text(
            'This profile is for informational purposes only. To engage this '
            "provider's services, please contact them through their official "
            'professional channels or dedicated platforms.',
            style: TextStyle(
                fontSize: 11, color: AppColors.faint, height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9.5,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
