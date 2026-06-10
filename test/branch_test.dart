import 'package:flutter_test/flutter_test.dart';
import 'package:kapoeta_logistics/providers/branch_provider.dart';
import 'package:kapoeta_logistics/models/branch.dart';

void main() {
  test('BranchProvider should have 6 initial branches', () {
    final branchProvider = BranchProvider();
    expect(branchProvider.branches.length, 6);
    
    final nairobi = branchProvider.getBranchById('1');
    expect(nairobi!.name, 'Nairobi');
    expect(nairobi.type, BranchType.hq);
    
    final juba = branchProvider.getBranchById('6');
    expect(juba!.name, 'Juba');
    expect(juba.hasAgent, true);
    
    final nadapal = branchProvider.getBranchById('2');
    expect(nadapal!.hasAgent, false);
  });
}
