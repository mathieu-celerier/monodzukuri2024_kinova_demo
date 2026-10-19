cmake_minimum_required(VERSION 3.5)

set(CXX_DISABLE_WERROR 1)
set(CMAKE_CXX_STANDARD 17)

set(PROJECT_NAME MonodzukuriKinovaDemo)
set(PROJECT_DESCRIPTION "MonodzukuriKinovaDemo")
set(PROJECT_URL "")

project(
  ${PROJECT_NAME}
  LANGUAGES CXX
  VERSION 1.0.0)
include(CTest)
include(GNUInstallDirs)

# Images of the visitor UI (src/ui.cpp), read from the install prefix so they survive builds
# whose source tree is gone afterwards (nix)
set(ASSETS_INSTALL_DIR "${CMAKE_INSTALL_FULL_DATADIR}/${PROJECT_NAME}")
add_compile_definitions(ASSETS_INSTALL_DIR="${ASSETS_INSTALL_DIR}")
install(DIRECTORY src/assets-en src/assets-jp DESTINATION "${ASSETS_INSTALL_DIR}")
enable_testing()

if(NOT TARGET mc_rtc::mc_control)
  find_package(mc_rtc REQUIRED)
endif()

find_package(MinimumJerkTask REQUIRED)
find_package(BoxDemoController REQUIRED)

add_subdirectory(src)

# if(BUILD_TESTING) add_subdirectory(tests) endif()

configure_file(etc/MonodzukuriKinovaDemo.in.yaml
               "${CMAKE_CURRENT_BINARY_DIR}/etc/MonodzukuriKinovaDemo.yaml")
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/etc/MonodzukuriKinovaDemo.yaml"
        DESTINATION "${MC_CONTROLLER_RUNTIME_INSTALL_PREFIX}/etc")

# Per-controller plugin config override, read by mc_rtc from
# etc/MonodzukuriKinovaDemo/plugins/<Plugin>.yaml under this install prefix (see
# MCGlobalController::GlobalConfiguration::load_controller_plugin_configs()).
install(FILES "etc/MonodzukuriKinovaDemo/plugins/ExternalForcesEstimator.yaml"
              "etc/MonodzukuriKinovaDemo/plugins/RosForceSensor.yaml"
        DESTINATION "${MC_CONTROLLER_RUNTIME_INSTALL_PREFIX}/etc/MonodzukuriKinovaDemo/plugins")
