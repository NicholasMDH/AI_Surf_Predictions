import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SurfQualityPanel extends StatelessWidget {
  final double rating;
  final double confidence;
  final Map<String, double> factors;
  final Map<String, String> factorDescriptions;

  const SurfQualityPanel({
    super.key,
    required this.rating,
    required this.confidence,
    required this.factors,
    required this.factorDescriptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Surf Quality Rating',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(confidence * 100).toStringAsFixed(0)}% Confidence',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Rating display
            SizedBox(
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      startDegreeOffset: 180,
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          value: rating,
                          color: theme.colorScheme.primary,
                          radius: 20,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: 4.0 - rating,
                          color: theme.colorScheme.primaryContainer
                              .withOpacity(0.3),
                          radius: 20,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        rating.toStringAsFixed(1),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        'out of 4.0',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contributing Factors
            Text(
              'Contributing Factors',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Factors list with fixed width constraints
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Column(
                      children: factors.entries.map((factor) {
                        Color color = _getFactorColor(context, factor.key);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildFactorIndicator(
                            context,
                            factor.key,
                            factor.value,
                            factorDescriptions[factor.key] ?? '',
                            color,
                            constraints.maxWidth,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorIndicator(
    BuildContext context,
    String label,
    double value,
    String description,
    Color color,
    double maxWidth,
  ) {
    final theme = Theme.of(context);
    return SizedBox(
      width: maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${(value * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: maxWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 4,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getFactorColor(BuildContext context, String factorName) {
    final theme = Theme.of(context);
    switch (factorName) {
      case 'Wave Power':
        return theme.colorScheme.primary;
      case 'Wind Factor':
        return theme.colorScheme.secondary;
      case 'Wave Height':
        return theme.colorScheme.tertiary;
      default:
        return theme.colorScheme.primary;
    }
  }
}
