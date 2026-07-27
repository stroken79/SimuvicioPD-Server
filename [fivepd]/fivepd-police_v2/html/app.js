GetParentResourceName()
window.addEventListener('message', function(event) {

    if (event.data.action === "open") {
        document.getElementById("menu").style.display = "block";
    }

    if (event.data.action === "close") {
        document.getElementById("menu").style.display = "none";
    }

});
function send(name) {

    fetch(`https://${GetParentResourceName()}/${name}`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: "{}"
    });

}

document.addEventListener("DOMContentLoaded", function () {

    document.getElementById("patrol").addEventListener("click", function () {
        send("patrol");
    });
    document.getElementById("wardrobe").addEventListener("click", function () {
    send("wardrobe");
});
	document.getElementById("civil").addEventListener("click", function () {
        send("civil");
    });
	
    document.getElementById("close").addEventListener("click", function () {
        send("close");
    });

});
