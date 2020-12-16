"use strict";

let intro = document.querySelector("#intro");

intro
    .querySelectorAll(".token")
    .forEach(function(element) {
        let node = document.createElement("span");
        node.setAttribute("role", "button");
        node.setAttribute("tabindex", "0");

        node.appendChild(document.createTextNode(element.getAttribute("data-summary")));
        node.classList.add("summary");

        let parent = element.parentElement;

        let handler = function() {
            intro.classList.add("activated");

            node.replaceWith(element);

            element.style.animationDuration = "0.4s";
            element.style.animationName = "fadeIn";
        };

        node.addEventListener("click", handler);
        node.addEventListener("keydown", function(event) {
            if (event.keyCode === 32 || event.keyCode === 13) {
                handler();
            }
        });

        element.replaceWith(node);
    });
