import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_verse/features/home/presentation/widgets/dashboard_top_nav.dart';
import 'package:uni_verse/features/onboarding/presentation/pages/coming_soon_page.dart';

void main() {
  testWidgets('Explore Universities menu item opens the coming-soon page', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: DashboardTopNav())),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Explore Universities'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Explore Universities'));
    await tester.pumpAndSettle();

    expect(find.byType(ComingSoonPage), findsOneWidget);
  });
}
