import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventmate/widgets/filter_modal.dart';

void main() {
  group('FilterOption', () {
    test('should create FilterOption with required parameters', () {
      final option = FilterOption(
        id: 'test',
        label: 'Test Option',
        count: 5,
      );

      expect(option.id, 'test');
      expect(option.label, 'Test Option');
      expect(option.count, 5);
      expect(option.isSelected, false);
    });

    test('should create FilterOption with isSelected true', () {
      final option = FilterOption(
        id: 'test',
        label: 'Test Option',
        count: 5,
        isSelected: true,
      );

      expect(option.isSelected, true);
    });

    test('copyWith should create new instance with updated values', () {
      final option = FilterOption(
        id: 'test',
        label: 'Test Option',
        count: 5,
      );

      final updated = option.copyWith(isSelected: true, count: 10);

      expect(updated.id, 'test');
      expect(updated.label, 'Test Option');
      expect(updated.count, 10);
      expect(updated.isSelected, true);
      expect(option.isSelected, false); // Original unchanged
    });
  });

  group('FilterSection', () {
    test('should create FilterSection with required parameters', () {
      final section = FilterSection(
        id: 'category',
        title: 'Category',
        options: [
          FilterOption(id: 'opt1', label: 'Option 1', count: 5),
        ],
      );

      expect(section.id, 'category');
      expect(section.title, 'Category');
      expect(section.options.length, 1);
      expect(section.allowMultiple, true);
      expect(section.isExpanded, false);
    });

    test('should create FilterSection with radio buttons', () {
      final section = FilterSection(
        id: 'type',
        title: 'Type',
        allowMultiple: false,
        options: [
          FilterOption(id: 'opt1', label: 'Option 1', count: 5),
        ],
      );

      expect(section.allowMultiple, false);
    });

    test('copyWith should create new instance', () {
      final section = FilterSection(
        id: 'category',
        title: 'Category',
        options: [
          FilterOption(id: 'opt1', label: 'Option 1', count: 5),
        ],
      );

      final updated = section.copyWith(isExpanded: true);

      expect(updated.isExpanded, true);
      expect(section.isExpanded, false);
    });
  });

  group('FilterResult', () {
    test('should create FilterResult', () {
      final result = FilterResult(
        selectedFilters: {'category': ['sport', 'music']},
        hasChanges: true,
      );

      expect(result.selectedFilters['category'], ['sport', 'music']);
      expect(result.hasChanges, true);
    });
  });

  group('FilterModal Widget', () {
    testWidgets('should display modal with header', (WidgetTester tester) async {
      final sections = [
        FilterSection(
          id: 'category',
          title: 'Category',
          options: [
            FilterOption(id: 'sport', label: 'Sport', count: 5),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterModal(sections: sections),
          ),
        ),
      );

      expect(find.text('Filtres'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should display custom title', (WidgetTester tester) async {
      final sections = [
        FilterSection(
          id: 'category',
          title: 'Category',
          options: [
            FilterOption(id: 'sport', label: 'Sport', count: 5),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterModal(
              sections: sections,
              title: 'Custom Filters',
            ),
          ),
        ),
      );

      expect(find.text('Custom Filters'), findsOneWidget);
    });

    testWidgets('should display sections', (WidgetTester tester) async {
      final sections = [
        FilterSection(
          id: 'category',
          title: 'Category',
          options: [
            FilterOption(id: 'sport', label: 'Sport', count: 5),
          ],
        ),
        FilterSection(
          id: 'type',
          title: 'Type',
          options: [
            FilterOption(id: 'free', label: 'Free', count: 10),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterModal(sections: sections),
          ),
        ),
      );

      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Type'), findsOneWidget);
    });

    testWidgets('should expand/collapse section on tap', (WidgetTester tester) async {
      final sections = [
        FilterSection(
          id: 'category',
          title: 'Category',
          isExpanded: false,
          options: [
            FilterOption(id: 'sport', label: 'Sport', count: 5),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterModal(sections: sections),
          ),
        ),
      );

      // Initially collapsed
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      expect(find.text('Sport'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('Category'));
      await tester.pumpAndSettle();

      // Now expanded
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
      expect(find.text('Sport'), findsOneWidget);
    });

    testWidgets('should toggle checkbox option', (WidgetTester tester) async {
      final sections = [
        FilterSection(
          id: 'category',
          title: 'Category',
          isExpanded: true,
          allowMultiple: true,
          options: [
            FilterOption(id: 'sport', label: 'Sport', count: 5),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterModal(sections: sections),
          ),
        ),
      );

      // Find checkbox
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      // Initially unchecked
      Checkbox checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, false);

      // Tap to check
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Now checked
      checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, true);
    });

    testWidgets('should disable option with count 0', (WidgetTester tester) async {
      final sections = [
        FilterSection(
          id: 'category',
          title: 'Category',
          isExpanded: true,
          options: [
            FilterOption(id: 'sport', label: 'Sport', count: 0),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterModal(sections: sections),
          ),
        ),
      );

      final checkbox = find.byType(Checkbox);
      final Checkbox checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.onChanged, null); // Disabled
    });

    testWidgets('should enable apply button when changes made', (WidgetTester tester) async {
      final sections = [
        FilterSection(
          id: 'category',
          title: 'Category',
          isExpanded: true,
          options: [
            FilterOption(id: 'sport', label: 'Sport', count: 5),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterModal(sections: sections),
          ),
        ),
      );

      // Find apply button
      final applyButton = find.widgetWithText(ElevatedButton, 'APPLIQUER');
      expect(applyButton, findsOneWidget);

      // Initially disabled
      ElevatedButton buttonWidget = tester.widget(applyButton);
      expect(buttonWidget.onPressed, null);

      // Make a change
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Now enabled
      buttonWidget = tester.widget(applyButton);
      expect(buttonWidget.onPressed, isNotNull);
    });

    testWidgets('should show reset button when filters applied', (WidgetTester tester) async {
      final sections = [
        FilterSection(
          id: 'category',
          title: 'Category',
          isExpanded: true,
          options: [
            FilterOption(id: 'sport', label: 'Sport', count: 5),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterModal(sections: sections),
          ),
        ),
      );

      // Initially no reset button
      expect(find.text('Réinitialiser'), findsNothing);

      // Make a change
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Now reset button appears
      expect(find.text('Réinitialiser'), findsOneWidget);
    });

    testWidgets('should display selected count badge', (WidgetTester tester) async {
      final sections = [
        FilterSection(
          id: 'category',
          title: 'Category',
          isExpanded: true,
          options: [
            FilterOption(id: 'sport', label: 'Sport', count: 5),
            FilterOption(id: 'music', label: 'Music', count: 3),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterModal(sections: sections),
          ),
        ),
      );

      // Select first option
      final checkboxes = find.byType(Checkbox);
      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();

      // Badge should show 1
      expect(find.text('1'), findsOneWidget);

      // Select second option
      await tester.tap(checkboxes.last);
      await tester.pumpAndSettle();

      // Badge should show 2
      expect(find.text('2'), findsOneWidget);
    });
  });

  group('FilterHeader Widget', () {
    testWidgets('should display title and close button', (WidgetTester tester) async {
      bool closeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterHeader(
              title: 'Test Filters',
              onClose: () => closeCalled = true,
              resetButtonText: 'Reset',
            ),
          ),
        ),
      );

      expect(find.text('Test Filters'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      expect(closeCalled, true);
    });

    testWidgets('should show reset button when provided', (WidgetTester tester) async {
      bool resetCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterHeader(
              title: 'Test Filters',
              onClose: () {},
              onReset: () => resetCalled = true,
              resetButtonText: 'Reset',
            ),
          ),
        ),
      );

      expect(find.text('Reset'), findsOneWidget);

      await tester.tap(find.text('Reset'));
      expect(resetCalled, true);
    });
  });

  group('ApplyButton Widget', () {
    testWidgets('should be enabled when isEnabled is true', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApplyButton(
              text: 'APPLY',
              isEnabled: true,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('APPLY'));
      expect(pressed, true);
    });

    testWidgets('should be disabled when isEnabled is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApplyButton(
              text: 'APPLY',
              isEnabled: false,
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      final ElevatedButton buttonWidget = tester.widget(button);
      expect(buttonWidget.onPressed, null);
    });
  });
}
