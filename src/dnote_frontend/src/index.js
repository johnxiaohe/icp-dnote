import { createActor,dnote_backend } from "../../declarations/dnote_backend";
import {AuthClient} from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";
import { createUserActor } from "./user";

let mActor = dnote_backend;
let uActor;

let userInfo = undefined;
let identity;

const loginButton = document.getElementById("login");
const namespaceButton = document.getElementById("namespaces");

async function login(e) {
  e.preventDefault();
  let authClient = await AuthClient.create();
  if(! await authClient.isAuthenticated()){
    await new Promise((resolve) => {
      authClient.login({
        identityProvider: process.env.II_URL,
        onSuccess: resolve,
      })
    });
  }
  const identity = authClient.getIdentity();
  const agent = new HttpAgent({identity});
  mActor = createActor(process.env.DNOTE_BACKEND_CANISTER_ID, {agent});

  let userInfoResp = await mActor.getUserInfo();
  console.log(userInfoResp);
  if (userInfoResp.code === 404){
    // 显示setting弹窗
    mActor.sign("reuben", "", "a man");
  }else if(userInfoResp.code === 200){
    userInfo = userInfoResp.data;
    console.log(userInfo);
    uActor = createUserActor(identity, userInfo.id);
    // 登陆按钮隐藏，显示个人头像按钮
    loginButton.innerHTML = "";
    loginButton.innerHTML = "<img src=\"./favicon.ico\"></img>";
    const welcome = document.getElementById("welcome");
    welcome.innerText = "欢迎 " + userInfo.name;
  }
};

async function namespaces(){
  if(userInfo === undefined){
    alert("pls connect wallet");
    return;
  }
  const idx = document.getElementById("idx");
  const nsp = document.getElementById("nsp");
  idx.style.display = 'none';
  nsp.style.display = 'block'
}

loginButton.onclick = login;
namespaceButton.onclick = namespaces;