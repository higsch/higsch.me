---
title: "Svelte meets LocalStorage"
description: "Hand-in-hand"
author: "Matthias Stahl"
date: 2019-06-22T01:53:04+02:00
tags: ["Svelte", "LocalStorage", "JavaScript", "Webdev"]
summary: "A few days ago I watched [Coding Garden](https://www.youtube.com/watch?v=jmDLwNl6jr8) presenting the [Svelte](https://svelte.dev) compiler for reactive JavaScript."
---

In contrast to reactive JavaScript frameworks such as [Vue](https://vuejs.org) or
[React](https://reactjs.org), Svelte compiles your reactive JavaScript at build time
to Vanilla JS. This for example means that no virtual DOM exists and no framework
runtime has to run in the client browser. Check out the
[examples](https://svelte.dev/examples#hello-world) to get a first impression.

Like [Vuex](https://vuex.vuejs.org) for Vue or [Redux](https://redux.js.org) for React,
Svelte uses a simplistic store to manage app-wide state. In many cases you like
to have this state persistent, which you can achieve by setting cookies or using
the [LocalStorage](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage)
of the users's browser.

Usually, you would define a store in a separate JavaScript module `store.js`.
```
// store.js
import { writable } from 'svelte/store';

export const count = writable(0);
```
```
// App.svelte
import { count } from 'store.js';
```
In order to make the store persistent, just include the function `useLocalStorage`
to the store object.
```
// store.js
import { writable } from 'svelte/store';

const createWritableStore = (key, startValue) => {
  const { subscribe, set } = writable(startValue);
  
	return {
    subscribe,
    set,
    useLocalStorage: () => {
      const json = localStorage.getItem(key);
      if (json) {
        set(JSON.parse(json));
      }
      
      subscribe(current => {
        localStorage.setItem(key, JSON.stringify(current));
      });
    }
  };
}

export const count = createWritableStore('count', 0);
```
```
// App.svelte
import { count } from 'store.js';

count.useLocalStorage();
```
Then, in your `App.svelte` just invoke the `useLocalStorage` function to enable
the persistant state.
