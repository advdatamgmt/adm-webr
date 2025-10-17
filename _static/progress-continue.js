// once document loaded
document.addEventListener("DOMContentLoaded", function() {

    // find all continue-progress buttons
    var buttons = document.querySelectorAll(".btn.progress-continue");
    
    if (buttons.length == 0) return;

    // current is the node to start at
    // stop_sel is a selector at which to stop
    // highest_sel is where you should go no higher as you walk
    // apply_fn is the function to apply to each node as you walk
    // returns the next node (i.e., the one apply_fn was not applied to)
    function nav_dom(current, stop_sel, highest_sel, apply_fn) {
        let walker = document.createTreeWalker(
            document.querySelector(highest_sel),
            NodeFilter.SHOW_ELEMENT)
        walker.currentNode = current;
        let n;
        while ((n = walker.nextNode())) {
            if (n.matches(stop_sel)) break;
            apply_fn(n);
        }
        return n; 
    }

    function hide_it(e) {
        if (e == null) return; 
        e.setAttribute("data-pc-old-display", e.style.display);
        e.style.display = "none";
    }

    nav_dom(buttons[0], "#evaluation", "#quarto-document-content", hide_it);

    function show_it(e) {
        if (e == null) return;
        e.style.display = e.getAttribute("data-pc-old-display");
        e.removeAttribute("data-pc-old-display");
    }

    // add click event listeners to each button
    buttons.forEach(function(button, index, buttons) {
        button.addEventListener("click", function() {
            // reveal all content between this button and the next progress-continue
            // button and the button itself, stopping again at the evaluation section
            hide_it(this);
            next_btn = nav_dom(this, ".btn.progress-continue, #evaluation", "#quarto-document-content", show_it);
            show_it(next_btn);
        });
    });
});