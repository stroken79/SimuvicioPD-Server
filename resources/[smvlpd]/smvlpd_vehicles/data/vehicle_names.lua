function AddTextEntry(key, value)
    Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end

Citizen.CreateThread(function()

    AddTextEntry('0x54830233', 'Crown Victoria')
    AddTextEntry('0x519EF9F7', 'Ford Explorer')
    AddTextEntry('0x43605D7A', 'Chevrolet Tahoe')
    AddTextEntry('0x61A019F9', 'Dodge Charger')
    AddTextEntry('0xD3487D4C', 'Dodge RAM')

    AddTextEntry('0x7C264F05', 'Unmarked I')
    AddTextEntry('0x65E42281', 'Unmarked II')
    AddTextEntry('0x9EB8142C', 'Unmarked III')
    AddTextEntry('0xFA81CBBE', 'Unmarked IV')

    AddTextEntry('0x7DB7A427', 'Audi RS4 Avant')

end)