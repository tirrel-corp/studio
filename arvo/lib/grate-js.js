window.addEventListener("message", e => {
  if (!e.data.token) {
    console.log("Spurious window.postMessage", e);
    return;
  } else {
    window.location.replace(window.location.protocol + '//' + window.location.host + window.location.pathname + "?token=" + e.data.token);
  }
});

document.addEventListener("DOMContentLoaded", function (event) {
  const styleVars = ["--background-body", "--text-bright", "--text-main", "--links"];
  const [bg, textBright, textMain, links] = styleVars.map((style) => {
    return encodeURIComponent(getComputedStyle(document.documentElement).getPropertyValue(style).substring(1))
  });

  const urlParams = new URLSearchParams(window.location.search);
  const login = urlParams.get('login');
  const tier = urlParams.get('tier');
  const email = urlParams.get('email');


  const frame = document.querySelector("iframe");
  frame.src = frame.src + "?" + `background=${bg}&textBright=${textBright}&textMain=${textMain}&links=${links}&path=${window.location.pathname}&login=${login}&email=${email}&tier=${tier}`
});
