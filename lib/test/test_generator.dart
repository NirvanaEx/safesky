import 'package:safe_sky/models/plan_detail_model.dart';
import 'package:safe_sky/models/request_model_main.dart';

class TestDataGenerator {
  /// Генерирует список тестовых объектов RequestModelMain.
  static List<RequestModelMain> generateMainRequests({int count = 10}) {
    List<RequestModelMain> requests = [];
    for (int i = 1; i <= count; i++) {
      requests.add(RequestModelMain(
        planId: i,
        applicationNum: "App #$i",
        planDate: "2025-02-02T15:27:57.823Z",
        timeFrom: "2025-02-02T15:27:57.823Z",
        timeTo: "2025-02-02T15:27:57.823Z",
        stateId: (i % 3) + 1, // для разнообразия
        state: "State ${(i % 3) + 1}",
      ));
    }
    return requests;
  }

  /// Генерирует тестовый объект PlanDetailModel для заданного planId.
  static PlanDetailModel generatePlanDetail({int? planId}) {
    final int id = planId ?? 1;
    return PlanDetailModel(
      planId: id,
      planDate: DateTime.now(),
      applicantId: 100 + id,
      applicant: "Applicant #$id",
      applicationNum: "AppNum #$id",
      timeFrom: "2025-02-02T15:27:57.823Z",
      timeTo: "2025-02-02T15:27:57.823Z",
      flightArea: "Test Flight Area for plan $id",
      zoneTypeId: 1,
      zoneType: "радиус от точки",
      purpose: "Тестирование",
      operatorList: [
        OperatorModel(
          id: 1,
          surname: "Иванов",
          name: "Иван",
          patronymic: "Иванович",
          phone: "+1234567890",
        ),
      ],
      bplaList: [
        BplaModel(
          id: 1,
          type: "БПЛА",
          name: "Test Drone",
          regnum: "ABC$id",
        ),
      ],
      coordList: [
        CoordModel(
          latitude: "400530N",
          longitude: "0645754E",
          radius: 1000,
        ),
      ],
      operatorPhones: "+1234567890",
      email: "test$id@example.com",
      notes: "Тестовые примечания для плана $id",
      permission: PermissionModel(
        orgName: "Test Organization",
        docNum: "DOC-$id",
        docDate: DateTime.now(),
      ),
      agreement: AgreementModel(
        docNum: "AG-$id",
        docDate: DateTime.now(),
      ),
      source: "Test Source",
      stateId: 2,
      state: "Test State",
      checkUrl: "https://example.com/check/$id",
      cancelReason: "Test cancel reason",
      uuid: "uuid-$id",
      execStateId: 1,
      execState: "Test Execution State",
      activity: 1,
      mAltitude: 500,
      fAltitude: 1640.42,
    );
  }
}
