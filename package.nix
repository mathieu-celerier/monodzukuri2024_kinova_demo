{
  lib,
  mkMcRtcController,
  cmake,
  mc-rtc,
  minimum-jerk-task,
}:

mkMcRtcController {
  pname = "MonodzukuriKinovaDemo";
  version = "0.1.0";

  src = lib.cleanSource ./.;

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    mc-rtc
    minimum-jerk-task
  ];

  doCheck = false;

  passthru.mc-rtc = {
    controller = {
      Enabled = "MonodzukuriKinovaDemo";
    };
  };

  meta = with lib; {
    description = "Kinova compliance demo controller for the Osaka Monodzukuri 2024 exposition";
    homepage = "https://github.com/mathieu-celerier/monodzukuri2024_kinova_demo";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
