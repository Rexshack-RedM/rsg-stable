local Translations = {
    stable  = {
        stable = "Stable",
        set_name = "Name your horse:",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})