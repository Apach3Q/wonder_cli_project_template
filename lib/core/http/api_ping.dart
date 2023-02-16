import 'package:app_template/providers/shared_preferences_service.dart';
import 'package:carrier_info/carrier_info.dart';

class ApiPing {
  static void init() async {
    final iosInfo = await CarrierInfo.getIosInfo();
    final carrierData = iosInfo.carrierData;
    if (carrierData.isEmpty) return;
    final mobileCountryCode = carrierData.first.mobileCountryCode;
    String chinaCountryCode = '460';
    String hongKongCountryCode = '454';
    String macauCountryCode = '455';
    String taiWanCountryCode = '466';
    bool inChina = mobileCountryCode == chinaCountryCode ||
        mobileCountryCode == hongKongCountryCode ||
        mobileCountryCode == macauCountryCode ||
        mobileCountryCode == taiWanCountryCode;
    sharedPreferencesService.setInternalHost(inChina);
  }
}
