import { dnote_backend } from "../../declarations/dnote_backend";

const userinfo = {};
const connButton = document.getElementById("login");

connButton.onclick = async (e) => {
  
}

document.getElementById("login").onclick = () => {
  // 登录
}

document.querySelector("form").addEventListener("submit", async (e) => {
  e.preventDefault();
  const button = e.target.querySelector("button");

  const name = document.getElementById("name").value.toString();

  button.setAttribute("disabled", true);

  // Interact with foo actor, calling the greet method
  const greeting = await dnote_backend.greet(name);

  button.removeAttribute("disabled");

  document.getElementById("greeting").innerText = greeting;

  return false;
});
