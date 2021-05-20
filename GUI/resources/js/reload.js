
window.onload = () => {
    setInterval(() => {
        $("#container").load("stats.php")
    }, 1000);
}
