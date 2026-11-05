import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/domain/career/job_catalog.dart';
import 'package:everylife/presentation/widgets/life_labels.dart';

void main() {
  group('JobCatalog', () {
    test('every job has a unique id, a picture, and four rank titles', () {
      final ids = <String>{};

      for (final job in JobCatalog.all) {
        expect(ids.add(job.id), isTrue, reason: 'duplicate ${job.id}');
        expect(job.emoji, isNotEmpty, reason: job.id);
        expect(job.rankTitles, hasLength(4), reason: job.id);
        expect(job.baseSalary, greaterThan(0), reason: job.id);
      }
    });

    test('jobs cover many sectors, including a bus driver', () {
      expect(
        JobCatalog.all.map((job) => job.sector).toSet().length,
        greaterThanOrEqualTo(8),
      );
      expect(JobCatalog.byId('bus_driver')?.emoji, '🚌');
    });

    test('self-employed parent jobs exist in the catalog', () {
      for (final id in JobCatalog.selfEmployedJobIds) {
        expect(JobCatalog.byId(id), isNotNull, reason: id);
      }
    });
  });

  group('countryFlag', () {
    test('turns a country code into a flag emoji', () {
      expect(countryFlag('ID'), '🇮🇩');
      expect(countryFlag('tr'), '🇹🇷');
      expect(countryFlag(''), '');
      expect(countryFlag('X1'), '');
      expect(countryFlag(null), '');
    });
  });
}
