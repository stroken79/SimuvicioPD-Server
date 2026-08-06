const hud = document.getElementById("hud");
const rankImage = document.getElementById("rankImage");
const logo = document.getElementById("logo");
const headerTitle = document.getElementById("headerTitle");
const serviceName = document.getElementById("serviceName");
const rankName = document.getElementById("rankName");
const playerName = document.getElementById("playerName");
const playerPoints = document.getElementById("playerPoints");
const nextRank = document.getElementById("nextRank");
const pointsLeft = document.getElementById("pointsLeft");
hud.style.display = "none";

window.addEventListener("message", function (event) {
    const data = event.data;

    if (data.action === "hide") {
        hud.style.display = "none";
        return;
    }

    if (data.action !== "update") return;

    serviceName.innerText = data.service;
    const serviceFolder = data.serviceType === "ambulance" ? "ambulance" : "police";
    logo.src = "img/" + serviceFolder + "/logo.png";
    headerTitle.innerText = serviceFolder === "ambulance" ? "SIMUVICIO EMS" : "SIMUVICIO PD";
    rankName.innerText = data.rank;
    playerName.innerText = data.player;
    playerPoints.innerText = "⭐ Puntos: " + data.points;
nextRank.innerText = "⬆ Siguiente rango: " + data.nextRank;
pointsLeft.innerText = "📌 Faltan: " + data.pointsLeft + " puntos";

    if (data.image) {
        rankImage.src = "img/" + serviceFolder + "/" + data.image;
        rankImage.style.display = "block";
    } else {
        rankImage.style.display = "none";
    }

    hud.style.display = "block";

    hud.classList.remove("show");
    void hud.offsetWidth;
    hud.classList.add("show");
});
