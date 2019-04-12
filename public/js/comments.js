function toggleMenu(event){
    console.log(event.target.attributes["data-post-id"].value)
    var element = document.querySelector(".comments");
    element.classList.toggle("dropdown")
    // console.log(element.attributes["data-post-id"].value)
    // element = document.createElement("article")
    // element.innerHTML = "ACKERBERG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    // element.classList.add("comment")
    // document.body.appendChild(element)
}

document.querySelectorAll(".post .show-comment-btn").forEach(
    btn => btn.addEventListener("click", toggleMenu)
)