import 'package:flutter_test/flutter_test.dart';
import 'package:contemplatio/main.dart';

void main() {
  testWidgets('Carrega tela inicial do Contemplácio sem quebrar', (
    WidgetTester tester,
  ) async {
    // sobe o app raiz
    await tester.pumpWidget(const ContemplatioApp());

    // verifica se o título aparece na AppBar
    expect(find.text('Contemplácio'), findsOneWidget);

    // você pode colocar mais asserts depois, por exemplo:
    // - se aparece "Escolha o Mistério"
    expect(find.text('Escolha o Mistério'), findsOneWidget);
  });
}
