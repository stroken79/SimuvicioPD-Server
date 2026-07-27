-- Note: Use Visual Studio Code to make this code readable. https://code.visualstudio.com/download

Config = {

    Debug = true,                                   -- Serverside prints.

    --====================== COMMANDS ======================--

    Commands = {
        TestSubtitle = "testsubtitle",
    },

    CommandsHelpText = {
        TestSubtitleParam1 = "text",
        TestSubtitleParam1a = "any",
        TestSubtitle = "A command used to test your subtitle.",
    },

    --====================== SUBTITLE SETTINGS ======================--

    -- Check NUI/styles.css for customization options on how your subtitles look: Font, size, colors, background etc.
    Settings = {
        DefaultDuration = 5000,
    },
}