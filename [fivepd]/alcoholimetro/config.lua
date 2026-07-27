Config = {}

--[[---------------------------------------------------------------------------
    PERMISSIONS
    Who is allowed to open and use the breathalyzer.

    Mode options:
      'open'   - Anyone can use the device (default)
      'ace'    - Only players with the ACE permission below
      'custom' - Uses CustomCanUseBreathalyzer() in server/permissions.lua

    ACE example (add to server.cfg):
      add_ace group.police sstudios.breathalyzer.use allow
---------------------------------------------------------------------------]]
Config.Permissions = {
    Mode = 'open',
    AcePermission = 'sstudios.breathalyzer.use',
    DeniedMessage = 'You are not authorised to use the breathalyzer.',
}

--[[---------------------------------------------------------------------------
    COMMANDS
    Chat commands to open/close the device.
    Description appears as a chat suggestion when players type the command.
---------------------------------------------------------------------------]]
Config.Commands = {
    Enabled = true,
    Primary = 'bt',
    Secondary = 'breathalyzer',
    Description = 'Open the Alcotest 7510 breathalyzer to test a nearby subject.',
}

--[[---------------------------------------------------------------------------
    KEYBIND
    Lets players bind a key under Settings > Key Bindings > FiveM.
    Leave DefaultKey empty ('') so no key is assigned by default.
    Players can set their own bind in-game.
---------------------------------------------------------------------------]]
Config.Keybind = {
    Enabled = false,
    Command = 'sstudios_breathalyzer',
    Description = 'Open the Alcotest 7510 breathalyzer',
    DefaultKey = '',
}

--[[---------------------------------------------------------------------------
    TESTING
    Core breathalyzer behaviour.

    MaxDistance          - How close (meters) the subject must be to start a test
    Duration             - How long Wait/Analyzing lasts after subject submits (ms)
    DefaultType          - Mode when opening device: 'passive' or 'evidential'
    ErrorDisplayDuration - How long officer error messages stay on screen (ms)
---------------------------------------------------------------------------]]
Config.Testing = {
    MaxDistance = 3.0,
    Duration = 4500,
    DefaultType = 'evidential',
    ErrorDisplayDuration = 2500,
}

--[[---------------------------------------------------------------------------
    EVIDENTIAL
    Settings for evidential (numeric) tests only.
    Passive tests use PASS/FAIL instead of a number.

    LegalLimit    - Reading at or below this value = Pass, above = Fail
    MaxInput      - Highest value a subject can enter
    DecimalPlaces - How many decimals to show (e.g. 0.250)
    UnitLabel     - Unit shown on the subject input screen
---------------------------------------------------------------------------]]
Config.Evidential = {
    LegalLimit = 0.250,
    MaxInput = 9.999,
    DecimalPlaces = 3,
    UnitLabel = 'mcg',
}

--[[---------------------------------------------------------------------------
    AUDIO
    Device sounds (beeps, analyzing tone) play from the officer's position.
    Nearby players hear them at reduced volume based on distance.

    HearDistance - Max range (meters) others can hear the device
---------------------------------------------------------------------------]]
Config.Audio = {
    Enabled = true,
    HearDistance = 5.0,
}

--[[---------------------------------------------------------------------------
    UPDATE CHECKER
    Console startup banner shown after the server finishes loading.
    Checks GitHub for a newer release and prints the result.

    When Enabled is false, nothing is printed to the console.
---------------------------------------------------------------------------]]
Config.UpdateChecker = {
    Enabled = false,
    Repository = '1swiftstudios1/SwiftDUI',
}
