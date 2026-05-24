import 'dart:ui';

import 'package:bumblebee_desktop/ui/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders Bumblebee shell', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const BumblebeeApp(
        loadHistoryOnStartup: false,
        checkForUpdatesOnStartup: false,
        syncCatalogsOnStartup: false,
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('BUMBLEBEE'), findsOneWidget);
  });
}
