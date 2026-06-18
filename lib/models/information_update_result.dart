import 'information_update_status.dart';

class InformationUpdateResult {
  final InformationUpdateStatus informationUpdateStatus;

  InformationUpdateResult(this.informationUpdateStatus);

  factory InformationUpdateResult.fromJson(dynamic json) {
    return InformationUpdateResult(InformationUpdateStatus.values
        .byName(json['informationUpdateStatus']));
  }
}
