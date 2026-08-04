{
  lib,
  mkMcRtcController,
  cmake,
  mc-rtc,
  minimum-jerk-task,
  mc-joystick-plugin,
  box-demo-controller,
  libGL,
  glfw,
  freeglut,
  glew,
}:

mkMcRtcController {
  pname = "MonodzukuriKinovaDemo";
  version = "0.1.0";

  src = lib.cleanSource ./.;

  nativeBuildInputs = [ cmake ];
  # mc_joystick_plugin isn't declared via find_package() in CMakeLists.txt (the source just
  # #include <mc_joystick_plugin/joystick_inputs.h> directly), so it must be listed here
  # explicitly to get its headers onto the include path.
  propagatedBuildInputs = [
    mc-rtc
    minimum-jerk-task
    mc-joystick-plugin
    box-demo-controller
  ];
  # The OpenGL debug UI (src/ui.cpp) target_link_libraries raw "GL glfw glut GLEW" — none of
  # these are found via find_package()/pkg-config in CMakeLists.txt, just linked by bare name,
  # so they need to be on the search path via buildInputs.
  buildInputs = [
    libGL
    glfw
    freeglut
    glew
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
