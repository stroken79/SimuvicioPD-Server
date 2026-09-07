window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === "openMenu") {
        document.getElementById('hud-menu').style.display = 'block';
        document.getElementById('toggle-unit').innerText = `Switch to ${data.unit === "mph" ? "KPH" : "MPH"}`;
        document.getElementById('toggle-hud').innerText = data.hud ? "Hide HUD" : "Show HUD";
    }

    if (data.action === "updateUnit") {
        document.getElementById('toggle-unit').innerText = `Switch to ${data.unit === "mph" ? "KPH" : "MPH"}`;
    }

    if (data.action === "updateHUDStatus") {
        document.getElementById('toggle-hud').innerText = data.hud ? "Hide HUD" : "Show HUD";
    }

    if (data.action === "updateSpeedometer") {
        document.getElementById('speedometer').style.display = 'flex';
        document.getElementById('speed').innerText = data.speed;
        document.getElementById('unit').innerText = data.unit;
        document.getElementById('gear').innerText = data.gear;
        document.getElementById('fuel-icon').innerText = "⛽ " + data.fuel + "%";
    }

    if (data.action === "hideSpeedometer") {
        document.getElementById('speedometer').style.display = 'none';
    }
});

document.getElementById('toggle-unit').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/toggleUnit`, {
        method: 'POST'
    });
});

document.getElementById('toggle-hud').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/toggleHUD`, {
        method: 'POST'
    });
});

document.getElementById('close').addEventListener('click', function() {
    document.getElementById('hud-menu').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST'
    });
});
