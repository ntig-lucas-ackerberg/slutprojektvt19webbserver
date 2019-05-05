function toggleMenu(event){
    let id = event.target.attributes["data-post-id"].value
    console.log(id)
    var element = document.querySelector(".comments[data-post-id=\""+id+"\"]");
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