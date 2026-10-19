{
  description = "monodzukuri2024_kinova_demo: mc-rtc-superbuild release and development shells";

  inputs = {
    mc-rtc-nix.url = "github:mc-rtc/nixpkgs";
    flake-parts.follows = "mc-rtc-nix/flake-parts";
    systems.follows = "mc-rtc-nix/systems";

    mc-rtc-kinova-external-forces.url = "github:mathieu-celerier/mc-rtc-kinova-external-forces";

    # The joystick plugin the controller was tested with. mc-rtc-kinova-external-forces pins
    # bastien-muraccioli's main, which has diverged (pad handling, datastore API). Has a `cmake`
    # (jrl-cmakemodules) submodule, hence the git+ scheme with submodules=1.
    mc-joystick-plugin-src = {
      url = "git+https://github.com/mathieu-celerier/mc_joystick_plugin?submodules=1&ref=before-force-push";
      flake = false;
    };

    ccache-trigger.url = "github:boolean-option/true";
  };

  outputs =
    inputs:
    inputs.mc-rtc-nix.lib.mkMcRtcController inputs "MonodzukuriKinovaDemo" (
      { ... }:
      {
        imports = [
          # Must come before mc-rtc-kinova-external-forces: for the same `overrideAttrs.<name>`
          # the module imported earlier wins, silently
          { flakoboros.overrideAttrs.mc-joystick-plugin = _: { src = inputs.mc-joystick-plugin-src; }; }

          inputs.mc-rtc-kinova-external-forces.flakeModule

          # An `imports` entry rather than a top-level key: mkMcRtcController does
          # `body // defaultAttrs`, which would clobber a top-level `mc-rtc-superbuild`. As a
          # deferredModule it merges with the configuration generated from passthru.mc-rtc.
          {
            mc-rtc-superbuild =
              { pkgs, ... }:
              {
                # The generated mc_rtc.yaml sets `LoadUserConfiguration: false`, so neither
                # Timestep nor the Kortex block of ~/.config/mc_rtc/mc_rtc.yaml is read: both
                # come from here. mc_kortex runs a 1 kHz loop.
                extraBuildInputs = [
                  # `ros2 topic` (hz, echo) to check the Bota wrench from inside the shell
                  pkgs.rosPackages.jazzy.ros2topic
                  # The UI exits the controller when it cannot open its window: a virtual
                  # display lets it run on a machine with no screen
                  pkgs.xvfb-run
                  # vglrun: the UI rendered on the NUC's GPU and sent compressed to a remote
                  # viewer (vglconnect -s), instead of raw ssh -X images on the arm's cable
                  pkgs.virtualgl
                ];

                configurations.MonodzukuriKinovaDemo = {
                  timeStep = 0.001;
                  runtime = {
                    apps = [ pkgs.mc-kortex ];
                    extraConfigFiles = [ "${./etc/mc_kortex.yaml}" ];
                  };
                };
              };
          }
        ];

        mc-rtc-nix.overlays.ccache = inputs.ccache-trigger.value;

        flakoboros.packages.MonodzukuriKinovaDemo = ./package.nix;
      }
    );
}
