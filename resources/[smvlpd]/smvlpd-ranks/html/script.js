const hud = document.getElementById("hud");
const rankImage = document.getElementById("rankImage");
const rankName = document.getElementById("rankName");
const playerName = document.getElementById("playerName");

hud.style.display = "none";

window.addEventListener("message", function (event) {
    const data = event.data;

    if (data.action !== "update") return;

    rankName.innerText = data.rank;
    playerName.innerText = data.player;

    if (data.image) {
        rankImage.src = "img/" + data.image;
        rankImage.style.display = "block";
    } else {
        rankImage.style.display = "none";
    }

    hud.style.display = "block";

    hud.classList.remove("show");
    void hud.offsetWidth;
    hud.classList.add("show");
});