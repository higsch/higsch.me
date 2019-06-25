---
title: "Smooth start and stop of CSS transitions"
description: "Using Svelte"
author: "Matthias Stahl"
date: 2019-06-25T22:16:41+02:00
tags: ["CSS", "JavaScript", "Svelte"]
summary: "For a project at Karolinska Institutet I am building a web frontend. It just should fetch proteomics data from a remote server and show it. One night, I thought about adding a fancy loading animation."
---

I came up with the crazy idea that the animation should move the mass spectrum peaks of the Lehtiö Lab logo up and down.

<img src="https://lehtiolab.github.io/img/logo_big.png" alt="Lehtiö Lab Logo" width="200"/>

Another prerequisite was the complete implementation of the animation itself in pure CSS.
For performace reasons. The browser is busy with downloading data and cannot take care moving
some lines up and down.

From a colleague I got the logo as SVG and as I have recently come across [Svelte](https://svelte.dev),
I implemented the logo as follows on the webpage (within a Svelte component).
```JavaScript
<script>
let logoCoordinates = [
  {x1: 9.27, y1: 50.24, x2: 9.27, y2: 33.77},
  {x1: 16.47, y1: 50.24, x2: 16.47, y2: 9.84},
  {x1: 25.93, y1: 50.24, x2: 25.93, y2: 19.36},
  {x1: 49.92, y1: 50.24, x2: 49.92, y2: 16.29},
  {x1: 60.73, y1: 50.24, x2: 60.73, y2: 28.88},
  {x1: 65.36, y1: 50.24, x2: 65.36, y2: 8.55},
  {x1: 84.92, y1: 50.24, x2: 84.92, y2: 19.36},
  {x1: 120.43, y1: 50.24, x2: 120.43, y2: 16.29},
  {x1: 92.13, y1: 50.24, x2: 92.13, y2: 4.95},
  {x1: 98.31, y1: 50.24, x2: 98.31, y2: 9.84},
  {x1: 109.11, y1: 50.24, x2: 109.11, y2: 27.6}
];

let animateClass = false;
</script>

<svg>
  <g>
    {#each coord in logoCoordinate, i}
      <line id="line-{i}" class="{animateClass ? 'animate' : ''}" x1="{coord.x1}" y1="{coord.y1}" x2="{coord.x2}" y2="{coord.y2}"/>
    {/each}
  </g>
</svg>
```

The lines are not visible, yet. Therefore, we need some CSS styling.
```CSS
line {
  stroke: #86cff1;
  stroke-width: 3px;
  transition: all 0.8s ease-in-out;
}

line.animate {
  animation-direction: alternate;
  transition: all 0.8s ease-in-out;
  transform: translateY(-50%);
}
```

And here comes the first clue, we use single-run transitions instead of a proper animation.
A jump-up transition, when the `animate` class is present and a fall-down transition, when the `animate` class is gone.

Now, we need some more JavaScript in the Svelte component to control for exactly these ups and downs.
```JavaScript
import { loading } from '../stores.js';

let animateClass = false;
let intervalId;

function animateLogo(loading) {
  if (loading) {
    if (!intervalId) {
      animateClass = true;
	  intervalId = setInterval(() => animateClass = !animateClass, 800);
     }
  } else {
    clearInterval(intervalId);
    intervalId = null;
	  animateClass = false;
  }
}

$: animateLogo($loading);
```
The component is connected to a store called `loading` and it reads out its boolean value by
the `$loading` shorthand. The `$:` in turn is a JavaScript label, which tells the Svelte compiler
to treat the variable as a reactive one. Thus, `animateLogo` is run each time when `$loading` is
updated. And `$loading` becomes true, when the app is loading something.

Now the second clue: Each time `$loading` changes, the `animateLogo` function is called and alternates
between jump-up and fall-down transitions by setting an interval function and reversing `animateClass`.
This controls the ups and downs and furthermore guarantees a smooth stop of the animation when
`$loading` becomes false.

Please note that the `setInterval` function handles the callback execution every 800 ms.
This is exactly the length of the CSS transitions we set.

Of course, you can implement this with Vanilla JS, too. However, Svelte delivers some syntactic sugar for reactivity.
And, yes, I really like Svelte.
