import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../lib/core/models/business_document.dart';
import '../../lib/features/car_dealer/dealer_local_store.dart';

void main() {
  const authKey = 'ev_yemen.dealer.auth.v1';
  const profileKey = 'ev_yemen.dealer.profile.v1';
  const documentsKey = 'ev_yemen.dealer.documents.v1';
  final store = DealerLocalStore.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await store.initialize();
  });

  test('recovers from an interrupted save and creates a valid account', () async {
    SharedPreferences.setMockInitialValues({
      authKey: '{"phone":"777777777","salt":"old","verifier":"old"}',
      profileKey: '{"name":"Incomplete registration"}',
      documentsKey: '{}',
    });

    final result = await store.register(
      phone: '0777777777',
      password: 'secure123',
      profile: const {
        'name': 'معرض الاختبار',
        'registration': 'CR-001',
        'phone': '0777777777',
        'address': 'صنعاء',
      },
      documents: _documents(),
    );

    expect(result, DealerRegistrationResult.created);
    expect(
      await store.authenticate(phone: '0777777777', password: 'secure123'),
      isTrue,
    );
    expect(store.documents.keys, containsAll(DealerLocalStore.requiredDocumentKeys));
  });

  test('keeps complete required document validation', () async {
    final result = await store.register(
      phone: '0777777777',
      password: 'secure123',
      profile: const {'name': 'معرض الاختبار'},
      documents: {'identity': _documents()['identity']!},
    );

    expect(result, DealerRegistrationResult.missingDocuments);
  });

  test('reports a complete existing account accurately', () async {
    final firstResult = await store.register(
      phone: '0777777777',
      password: 'secure123',
      profile: const {
        'name': 'معرض الاختبار',
        'registration': 'CR-001',
        'phone': '0777777777',
        'address': 'صنعاء',
      },
      documents: _documents(),
    );

    final retryResult = await store.register(
      phone: '0777777777',
      password: 'secure123',
      profile: const {
        'name': 'معرض الاختبار',
        'registration': 'CR-001',
        'phone': '0777777777',
        'address': 'صنعاء',
      },
      documents: _documents(),
    );

    expect(firstResult, DealerRegistrationResult.created);
    expect(retryResult, DealerRegistrationResult.accountAlreadyExists);
  });
}

Map<String, BusinessDocument> _documents() => {
      for (final key in DealerLocalStore.requiredDocumentKeys)
        key: BusinessDocument(
          name: '$key.pdf',
          path: '/documents/$key.pdf',
          size: 100,
        ),
    };
