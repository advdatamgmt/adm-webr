// once document loaded
document.addEventListener("DOMContentLoaded", function() {

    // find all continue-progress buttons
    var buttons = document.querySelectorAll(".btn.progress-continue");
    const sel = "section>p, section>div, #quarto-document-content>p, #quarto-document-content>div"

    // hide all elements after the first continue-progress button
    // but correct siblings are those of the button's enclosing element
    var first = buttons[0].closest(sel);
    var next = first.nextElementSibling;
    outer:
    while(true) {
        while (next) {
            next.setAttribute("pc-old-display", next.style.display);
            next.style.display = "none";
            next = next.nextElementSibling;
        }
        if (first.parentElement.tagName == "SECTION" && first.parentElement.nextElementSibling) {
            first = first.parentElement.nextElementSibling;
            next = first.firstElementChild;
        } else {
            break outer;
        }
    }

    // add click event listeners to each button
    buttons.forEach(function(button) {
        button.addEventListener("click", function() {
            // reveal all content between this button and the next progress-continue
            // button or the end of the section is reached
            first = button.closest(sel);
            first.style.display = "none"; 
            var next = first.nextElementSibling;
            if (!next) {
                if (first.parentElement.tagName == "SECTION" && first.parentElement.nextElementSibling) {
                    first = first.parentElement.nextElementSibling;
                    next = first.firstElementChild;
                }
            }
            outer:
            while(true) {
                while (next && !next.querySelector(".btn.progress-continue")) {
                    next.style.display = next.getAttribute("pc-old-display");
                    next = next.nextElementSibling;
                }
                // make sure the next button is also displayed
                if (next && next.querySelector(".btn.progress-continue")) {
                    next.style.display = next.getAttribute("pc-old-display");
                    break outer;
                }
                if (first.parentElement.tagName == "SECTION" && first.parentElement.nextElementSibling) {
                    first = first.parentElement.nextElementSibling;
                    next = first.firstElementChild;
                } else {
                    break outer;
                }
            }
        });
    });
});