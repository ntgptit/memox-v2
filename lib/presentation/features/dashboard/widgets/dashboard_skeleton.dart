import 'package:flutter/material.dart';

import '../../../../core/theme/tokens/app_radius.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_loading_state.dart';

const double _dashboardGreetingHeight = 32;
const double _dashboardGreetingWidth = 180;
const double _dashboardHeadingHeight = 24;
const double _dashboardHeadingWidth = 160;
const double _dashboardActionTitleHeight = 20;
const double _dashboardActionTitleWidth = 140;
const double _dashboardActionBodyHeight = 16;
const double _dashboardActionBodyWidth = 220;
const double _dashboardActionButtonHeight = 36;
const double _dashboardProgressChartSize = 132;
const double _dashboardProgressTitleHeight = 20;
const double _dashboardProgressTitleWidth = 120;
const double _dashboardProgressBodyHeight = 16;
const double _dashboardProgressBodyWidth = 200;
const double _dashboardDeckMetaHeight = 14;

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView(
      key: const ValueKey('dashboard_skeleton'),
      children: const [
        _GreetingSkeleton(),
        MxGap(MxSpace.lg),
        _HeadingSkeleton(),
        MxGap(MxSpace.lg),
        _ActionRowSkeleton(),
        MxGap(MxSpace.md),
        _ActionRowSkeleton(),
        MxGap(MxSpace.md),
        _ActionRowSkeleton(),
        MxGap(MxSpace.lg),
        _ProgressSkeleton(),
      ],
    );
}

class _GreetingSkeleton extends StatelessWidget {
  const _GreetingSkeleton();

  @override
  Widget build(BuildContext context) => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxSkeleton(
          height: _dashboardGreetingHeight,
          width: _dashboardGreetingWidth,
        ),
        MxGap(MxSpace.xs),
        MxSkeleton(
          height: _dashboardActionBodyHeight,
          width: _dashboardProgressBodyWidth,
        ),
      ],
    );
}

class _HeadingSkeleton extends StatelessWidget {
  const _HeadingSkeleton();

  @override
  Widget build(BuildContext context) => const MxSkeleton(
      height: _dashboardHeadingHeight,
      width: _dashboardHeadingWidth,
    );
}

class _ActionRowSkeleton extends StatelessWidget {
  const _ActionRowSkeleton();

  @override
  Widget build(BuildContext context) => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MxSkeleton(
              height: _dashboardActionTitleHeight,
              width: _dashboardActionTitleHeight,
            ),
            MxGap(MxSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MxSkeleton(
                    height: _dashboardActionTitleHeight,
                    width: _dashboardActionTitleWidth,
                  ),
                  MxGap(MxSpace.xs),
                  MxSkeleton(
                    height: _dashboardActionBodyHeight,
                    width: _dashboardActionBodyWidth,
                  ),
                ],
              ),
            ),
          ],
        ),
        MxGap(MxSpace.sm),
        MxSkeleton(height: _dashboardActionButtonHeight),
      ],
    );
}

class _ProgressSkeleton extends StatelessWidget {
  const _ProgressSkeleton();

  @override
  Widget build(BuildContext context) => const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MxSkeleton(
          height: _dashboardProgressChartSize,
          width: _dashboardProgressChartSize,
          borderRadius: AppRadius.borderFull,
        ),
        MxGap(MxSpace.xl),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MxSkeleton(
                    height: _dashboardActionTitleHeight,
                    width: _dashboardActionTitleHeight,
                  ),
                  MxGap(MxSpace.md),
                  MxSkeleton(
                    height: _dashboardProgressTitleHeight,
                    width: _dashboardProgressTitleWidth,
                  ),
                ],
              ),
              MxGap(MxSpace.xs),
              MxSkeleton(
                height: _dashboardProgressBodyHeight,
                width: _dashboardProgressBodyWidth,
              ),
              MxGap(MxSpace.xs),
              MxSkeleton(
                height: _dashboardDeckMetaHeight,
                width: _dashboardProgressBodyWidth,
              ),
              MxGap(MxSpace.md),
              MxSkeleton(
                height: _dashboardActionBodyHeight,
                width: _dashboardActionTitleWidth,
              ),
            ],
          ),
        ),
      ],
    );
}
