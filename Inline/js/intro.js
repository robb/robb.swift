"use strict";

var intro = document.querySelector("#intro");

intro
    .querySelectorAll(".token")
    .forEach(function(element) {
        var node = document.createElement("span");

        node.appendChild(document.createTextNode(element.getAttribute("data-summary")));
        node.classList.add("summary");

        var parent = element.parentElement;

        node.onclick = function() {
            intro.classList.add("activated");

            node.replaceWith(element);

            element.style.animationDuration = "0.4s";
            element.style.animationName = "fadeIn";
        };
        element.replaceWith(node);
    });
