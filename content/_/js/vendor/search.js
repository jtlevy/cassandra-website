window.antoraLunr=function(i){var u=document.getElementById("search-input"),c=document.createElement("div");function o(e,t){var n=[],r=t[0],a=t[1],s=e.text,d=document.createElement("span");d.classList.add("search-result-highlight"),d.innerText=s.substr(r,a);var i=r+a,u=s.length-1,c=u<i+15?u:i+15,o=r-15<0?0:r-15;return 0===r&&i===u?n.push(d):0===r?(n.push(d),n.push(document.createTextNode(s.substr(i,c)))):i===u?(n.push(document.createTextNode(s.substr(0,r))),n.push(d)):(n.push(document.createTextNode("..."+s.substr(o,r-o))),n.push(d),n.push(document.createTextNode(s.substr(i,c-i)+"..."))),n}function l(t,e,n){var r,a=[],s=n[0],d=n[1],i=document.createElement("span");i.classList.add("search-result-highlight"),r=t?e.titles.filter(function(e){return e.id===t})[0].text:e.title,i.innerText=r.substr(s,d);var u=s+d,c=r.length-1;return 0===s&&u===c?a.push(i):0===s?(a.push(i),a.push(document.createTextNode(r.substr(d,c)))):u===c?(a.push(document.createTextNode(r.substr(0,s))),a.push(i)):(a.push(document.createTextNode(r.substr(0,s))),a.push(i),a.push(document.createTextNode(r.substr(u,c)))),a}function h(e,s,d){e.forEach(function(e){var t,n=e.ref;n.includes("#")&&(t=n.substring(n.indexOf("#")+1),n=n.replace("#"+t,""));var r=s[n],a=function(e,t,n){var r=[];for(var a in e){var s=e[a];for(var d in s){var i,u=s[d];u.position&&(i=u.position[0],"title"===d?r=l(t,n,i):"text"===d&&(r=o(n,i)))}}return r}(e.matchData.metadata,t,r);d.appendChild(function(e,t,n){var r=document.createElement("div");r.classList.add("search-result-document-title"),r.innerText=e.title;var a=document.createElement("div");a.classList.add("search-result-document-hit");var s=document.createElement("a"),d=window.antora.basePath;s.href=d+t.ref,a.appendChild(s),n.forEach(function(e){s.appendChild(e)});var i=document.createElement("div");return i.classList.add("search-result-item"),i.appendChild(r),i.appendChild(a),i.addEventListener("mousedown",function(e){e.preventDefault()}),i}(r,e,a))})}function p(e,t,n){for(;c.firstChild;)c.removeChild(c.firstChild);var r,a,s,d,i;""!==n.trim()&&(s=n,r=0<(d=(a=e).search(s)).length||0<(d=a.search(s+"*")).length?d:d=a.search("*"+s+"*"),(i=document.createElement("div")).classList.add("search-result-dataset"),c.appendChild(i),0<r.length?h(r,t,i):i.appendChild(function(e){var t=document.createElement("div");t.classList.add("search-result-item");var n=document.createElement("div");n.classList.add("search-result-document-hit");var r=document.createElement("strong");return r.innerText='No results found for query "'+e+'"',n.appendChild(r),t.appendChild(n),t}(n)))}return c.classList.add("search-result-dropdown-menu"),u.parentNode.appendChild(c),{init:function(e){var r,a,s,d,t=Object.assign({index:i.Index.load(e.index),store:e.store}),n=(r=function(){p(t.index,t.store,u.value)},a=100,function(){var e=this,t=arguments,n=s&&!d;clearTimeout(d),d=setTimeout(function(){d=null,s||r.apply(e,t)},a),n&&r.apply(e,t)});u.addEventListener("keydown",n),u.addEventListener("blur",function(e){for(;c.firstChild;)c.removeChild(c.firstChild)})}}}(window.lunr);