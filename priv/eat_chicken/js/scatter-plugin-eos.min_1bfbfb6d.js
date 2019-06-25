!function(t){var r={};function e(n){if(r[n])return r[n].exports;var o=r[n]={i:n,l:!1,exports:{}};return t[n].call(o.exports,o,o.exports,e),o.l=!0,o.exports}e.m=t,e.c=r,e.d=function(t,r,n){e.o(t,r)||Object.defineProperty(t,r,{enumerable:!0,get:n})},e.r=function(t){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(t,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(t,"__esModule",{value:!0})},e.t=function(t,r){if(1&r&&(t=e(t)),8&r)return t;if(4&r&&"object"==typeof t&&t&&t.__esModule)return t;var n=Object.create(null);if(e.r(n),Object.defineProperty(n,"default",{enumerable:!0,value:t}),2&r&&"string"!=typeof t)for(var o in t)e.d(n,o,function(r){return t[r]}.bind(null,o));return n},e.n=function(t){var r=t&&t.__esModule?function(){return t.default}:function(){return t};return e.d(r,"a",r),r},e.o=function(t,r){return Object.prototype.hasOwnProperty.call(t,r)},e.p="",e(e.s=136)}({0:function(t,r,e){t.exports=e(27)},1:function(t,r){t.exports=ScatterJS},136:function(t,r,e){"use strict";e.r(r),e.d(r,"default",function(){return b});var n=e(0),o=e.n(n),i=e(2),u=e.n(i),a=e(4),c=e.n(a),f=e(5),s=e.n(f),l=e(7),h=e.n(l),p=e(8),y=e.n(p),d=e(9),v=e.n(d),g=e(1),m=g.SocketService,w=function(t,r){return new Proxy(t,r)},b=function(t){function r(){return c()(this,r),h()(this,y()(r).call(this,g.Blockchains.EOS,g.PluginTypes.BLOCKCHAIN_SUPPORT))}return v()(r,t),s()(r,[{key:"setSocketService",value:function(t){m=t}},{key:"hookProvider",value:function(t){return function(r){return new Promise(function(e,n){var o=Object.assign(r,{blockchain:g.Blockchains.EOS,network:t,requiredFields:{}});m.sendApiRequest({type:"requestSignature",payload:o}).then(function(t){return e(t.signatures)}).catch(function(t){return n(t)})})}}},{key:"signatureProvider",value:function(){var t=0>=arguments.length?void 0:arguments[0];return function(r,e){var n,i=2<arguments.length&&void 0!==arguments[2]?arguments[2]:{},a=(r=g.Network.fromJson(r)).hasOwnProperty("chainId")&&r.chainId.length?r.chainId:i.chainId,c=function(){var t=u()(o.a.mark(function t(r){return o.a.wrap(function(t){for(;;)switch(t.prev=t.next){case 0:return t.abrupt("return",n(r));case 1:case"end":return t.stop()}},t)}));return function(){return t.apply(this,arguments)}}();return w(e({httpEndpoint:r.fullhost(),chainId:a,signProvider:c}),{get:function(e,i){if("function"!=typeof e[i])return e[i];var a=null;return function(){for(var c=arguments.length,f=Array(c),s=0;s<c;s++)f[s]=arguments[s];if(f.find(function(t){return t.hasOwnProperty("keyProvider")}))throw Error.usedKeyProvider();return n=function(){var e=u()(o.a.mark(function e(n){var i,u,c,s;return o.a.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:return t(),i=f.find(function(t){return t.hasOwnProperty("requiredFields")})||{requiredFields:{}},u=Object.assign(n,{blockchain:g.Blockchains.EOS,network:r,requiredFields:i.requiredFields}),e.next=5,m.sendApiRequest({type:"requestSignature",payload:u});case 5:if(c=e.sent){e.next=8;break}return e.abrupt("return",null);case 8:if(!c.hasOwnProperty("signatures")){e.next=13;break}return a=c.returnedFields,(s=f.find(function(t){return t.hasOwnProperty("signProvider")}))&&c.signatures.push(s.signProvider(n.buf,n.sign)),e.abrupt("return",c.signatures);case 13:return e.abrupt("return",c);case 14:case"end":return e.stop()}},e)}));return function(){return e.apply(this,arguments)}}(),new Promise(function(t,r){e[i].apply(e,f).then(function(r){return r.hasOwnProperty("fc")?void t(w(r,{get:function(t,r){return"then"===r?t[r]:function(){for(var e=arguments.length,n=Array(e),i=0;i<e;i++)n[i]=arguments[i];return new Promise(function(){var e=u()(o.a.mark(function e(i,u){return o.a.wrap(function(e){for(;;)switch(e.prev=e.next){case 0:t[r].apply(t,n).then(function(t){i(Object.assign(t,{returnedFields:a}))}).catch(u);case 1:case"end":return e.stop()}},e)}));return function(){return e.apply(this,arguments)}}())}}})):t(Object.assign(r,{returnedFields:a}))}).catch(r)})}}})}}}]),r}(g.Plugin);"undefined"!=typeof window&&(window.ScatterEOS=b)},19:function(t,r){function e(t){return(e="function"==typeof Symbol&&"symbol"==typeof Symbol.iterator?function(t){return typeof t}:function(t){return t&&"function"==typeof Symbol&&t.constructor===Symbol&&t!==Symbol.prototype?"symbol":typeof t})(t)}function n(r){return"function"==typeof Symbol&&"symbol"===e(Symbol.iterator)?t.exports=n=function(t){return e(t)}:t.exports=n=function(t){return t&&"function"==typeof Symbol&&t.constructor===Symbol&&t!==Symbol.prototype?"symbol":e(t)},n(r)}t.exports=n},2:function(t,r){function e(t,r,e,n,o,i,u){try{var a=t[i](u),c=a.value}catch(t){return void e(t)}a.done?r(c):Promise.resolve(c).then(n,o)}t.exports=function(t){return function(){var r=this,n=arguments;return new Promise(function(o,i){var u=t.apply(r,n);function a(t){e(u,o,i,a,c,"next",t)}function c(t){e(u,o,i,a,c,"throw",t)}a(void 0)})}}},23:function(t,r){t.exports=function(t){if(void 0===t)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return t}},24:function(t,r){function e(r,n){return t.exports=e=Object.setPrototypeOf||function(t,r){return t.__proto__=r,t},e(r,n)}t.exports=e},27:function(t,r,e){var n=function(t){"use strict";var r,e=Object.prototype,n=e.hasOwnProperty,o="function"==typeof Symbol?Symbol:{},i=o.iterator||"@@iterator",u=o.asyncIterator||"@@asyncIterator",a=o.toStringTag||"@@toStringTag";function c(t,r,e,n){var o=r&&r.prototype instanceof d?r:d,i=Object.create(o.prototype),u=new k(n||[]);return i._invoke=function(t,r,e){var n=s;return function(o,i){if(n===h)throw new Error("Generator is already running");if(n===p){if("throw"===o)throw i;return j()}for(e.method=o,e.arg=i;;){var u=e.delegate;if(u){var a=S(u,e);if(a){if(a===y)continue;return a}}if("next"===e.method)e.sent=e._sent=e.arg;else if("throw"===e.method){if(n===s)throw n=p,e.arg;e.dispatchException(e.arg)}else"return"===e.method&&e.abrupt("return",e.arg);n=h;var c=f(t,r,e);if("normal"===c.type){if(n=e.done?p:l,c.arg===y)continue;return{value:c.arg,done:e.done}}"throw"===c.type&&(n=p,e.method="throw",e.arg=c.arg)}}}(t,e,u),i}function f(t,r,e){try{return{type:"normal",arg:t.call(r,e)}}catch(t){return{type:"throw",arg:t}}}t.wrap=c;var s="suspendedStart",l="suspendedYield",h="executing",p="completed",y={};function d(){}function v(){}function g(){}var m={};m[i]=function(){return this};var w=Object.getPrototypeOf,b=w&&w(w(L([])));b&&b!==e&&n.call(b,i)&&(m=b);var x=g.prototype=d.prototype=Object.create(m);function O(t){["next","throw","return"].forEach(function(r){t[r]=function(t){return this._invoke(r,t)}})}function P(t){var r;this._invoke=function(e,o){function i(){return new Promise(function(r,i){!function r(e,o,i,u){var a=f(t[e],t,o);if("throw"!==a.type){var c=a.arg,s=c.value;return s&&"object"==typeof s&&n.call(s,"__await")?Promise.resolve(s.__await).then(function(t){r("next",t,i,u)},function(t){r("throw",t,i,u)}):Promise.resolve(s).then(function(t){c.value=t,i(c)},function(t){return r("throw",t,i,u)})}u(a.arg)}(e,o,r,i)})}return r=r?r.then(i,i):i()}}function S(t,e){var n=t.iterator[e.method];if(n===r){if(e.delegate=null,"throw"===e.method){if(t.iterator.return&&(e.method="return",e.arg=r,S(t,e),"throw"===e.method))return y;e.method="throw",e.arg=new TypeError("The iterator does not provide a 'throw' method")}return y}var o=f(n,t.iterator,e.arg);if("throw"===o.type)return e.method="throw",e.arg=o.arg,e.delegate=null,y;var i=o.arg;return i?i.done?(e[t.resultName]=i.value,e.next=t.nextLoc,"return"!==e.method&&(e.method="next",e.arg=r),e.delegate=null,y):i:(e.method="throw",e.arg=new TypeError("iterator result is not an object"),e.delegate=null,y)}function E(t){var r={tryLoc:t[0]};1 in t&&(r.catchLoc=t[1]),2 in t&&(r.finallyLoc=t[2],r.afterLoc=t[3]),this.tryEntries.push(r)}function _(t){var r=t.completion||{};r.type="normal",delete r.arg,t.completion=r}function k(t){this.tryEntries=[{tryLoc:"root"}],t.forEach(E,this),this.reset(!0)}function L(t){if(t){var e=t[i];if(e)return e.call(t);if("function"==typeof t.next)return t;if(!isNaN(t.length)){var o=-1,u=function e(){for(;++o<t.length;)if(n.call(t,o))return e.value=t[o],e.done=!1,e;return e.value=r,e.done=!0,e};return u.next=u}}return{next:j}}function j(){return{value:r,done:!0}}return v.prototype=x.constructor=g,g.constructor=v,g[a]=v.displayName="GeneratorFunction",t.isGeneratorFunction=function(t){var r="function"==typeof t&&t.constructor;return!!r&&(r===v||"GeneratorFunction"===(r.displayName||r.name))},t.mark=function(t){return Object.setPrototypeOf?Object.setPrototypeOf(t,g):(t.__proto__=g,a in t||(t[a]="GeneratorFunction")),t.prototype=Object.create(x),t},t.awrap=function(t){return{__await:t}},O(P.prototype),P.prototype[u]=function(){return this},t.AsyncIterator=P,t.async=function(r,e,n,o){var i=new P(c(r,e,n,o));return t.isGeneratorFunction(e)?i:i.next().then(function(t){return t.done?t.value:i.next()})},O(x),x[a]="Generator",x[i]=function(){return this},x.toString=function(){return"[object Generator]"},t.keys=function(t){var r=[];for(var e in t)r.push(e);return r.reverse(),function e(){for(;r.length;){var n=r.pop();if(n in t)return e.value=n,e.done=!1,e}return e.done=!0,e}},t.values=L,k.prototype={constructor:k,reset:function(t){if(this.prev=0,this.next=0,this.sent=this._sent=r,this.done=!1,this.delegate=null,this.method="next",this.arg=r,this.tryEntries.forEach(_),!t)for(var e in this)"t"===e.charAt(0)&&n.call(this,e)&&!isNaN(+e.slice(1))&&(this[e]=r)},stop:function(){this.done=!0;var t=this.tryEntries[0].completion;if("throw"===t.type)throw t.arg;return this.rval},dispatchException:function(t){if(this.done)throw t;var e=this;function o(n,o){return a.type="throw",a.arg=t,e.next=n,o&&(e.method="next",e.arg=r),!!o}for(var i=this.tryEntries.length-1;i>=0;--i){var u=this.tryEntries[i],a=u.completion;if("root"===u.tryLoc)return o("end");if(u.tryLoc<=this.prev){var c=n.call(u,"catchLoc"),f=n.call(u,"finallyLoc");if(c&&f){if(this.prev<u.catchLoc)return o(u.catchLoc,!0);if(this.prev<u.finallyLoc)return o(u.finallyLoc)}else if(c){if(this.prev<u.catchLoc)return o(u.catchLoc,!0)}else{if(!f)throw new Error("try statement without catch or finally");if(this.prev<u.finallyLoc)return o(u.finallyLoc)}}}},abrupt:function(t,r){for(var e=this.tryEntries.length-1;e>=0;--e){var o=this.tryEntries[e];if(o.tryLoc<=this.prev&&n.call(o,"finallyLoc")&&this.prev<o.finallyLoc){var i=o;break}}i&&("break"===t||"continue"===t)&&i.tryLoc<=r&&r<=i.finallyLoc&&(i=null);var u=i?i.completion:{};return u.type=t,u.arg=r,i?(this.method="next",this.next=i.finallyLoc,y):this.complete(u)},complete:function(t,r){if("throw"===t.type)throw t.arg;return"break"===t.type||"continue"===t.type?this.next=t.arg:"return"===t.type?(this.rval=this.arg=t.arg,this.method="return",this.next="end"):"normal"===t.type&&r&&(this.next=r),y},finish:function(t){for(var r=this.tryEntries.length-1;r>=0;--r){var e=this.tryEntries[r];if(e.finallyLoc===t)return this.complete(e.completion,e.afterLoc),_(e),y}},catch:function(t){for(var r=this.tryEntries.length-1;r>=0;--r){var e=this.tryEntries[r];if(e.tryLoc===t){var n=e.completion;if("throw"===n.type){var o=n.arg;_(e)}return o}}throw new Error("illegal catch attempt")},delegateYield:function(t,e,n){return this.delegate={iterator:L(t),resultName:e,nextLoc:n},"next"===this.method&&(this.arg=r),y}},t}(t.exports);try{regeneratorRuntime=n}catch(t){Function("r","regeneratorRuntime = r")(n)}},4:function(t,r){t.exports=function(t,r){if(!(t instanceof r))throw new TypeError("Cannot call a class as a function")}},5:function(t,r){function e(t,r){for(var e=0;e<r.length;e++){var n=r[e];n.enumerable=n.enumerable||!1,n.configurable=!0,"value"in n&&(n.writable=!0),Object.defineProperty(t,n.key,n)}}t.exports=function(t,r,n){return r&&e(t.prototype,r),n&&e(t,n),t}},7:function(t,r,e){var n=e(19),o=e(23);t.exports=function(t,r){return!r||"object"!==n(r)&&"function"!=typeof r?o(t):r}},8:function(t,r){function e(r){return t.exports=e=Object.setPrototypeOf?Object.getPrototypeOf:function(t){return t.__proto__||Object.getPrototypeOf(t)},e(r)}t.exports=e},9:function(t,r,e){var n=e(24);t.exports=function(t,r){if("function"!=typeof r&&null!==r)throw new TypeError("Super expression must either be null or a function");t.prototype=Object.create(r&&r.prototype,{constructor:{value:t,writable:!0,configurable:!0}}),r&&n(t,r)}}});