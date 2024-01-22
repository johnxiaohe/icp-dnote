import { createActor,dnote_backend } from "../../declarations/dnote_backend";
import {AuthClient} from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";
import { createUserActor } from "./user";

let mActor = dnote_backend;
let uActor;

let userInfo = undefined;
let identity;

const loginButton = document.getElementById("login");
const username = document.getElementById("username");
const namespaceButton = document.getElementById("namespaces");
const s_submit = document.getElementById("s_submit");
const signup_form = document.getElementById("signup");

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
    // 用户尚未注册，弹窗提示注册信息。
    signup_form.display='block';
  }else if(userInfoResp.code === 200){
    userInfo = userInfoResp.data;
    console.log(userInfo);
    uActor = createUserActor(identity, userInfo.id);
    // 登陆按钮隐藏，显示个人头像按钮
    loginButton.innerText = "Logout";
    username.innerText = userInfo.name;
    const welcome = document.getElementById("welcome");
    welcome.innerText = "Welcome " + userInfo.name;
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
  const nsp_u = document.getElementById("nsp_u");
  let namespaces = await uActor.namespaces();
  for(ns in namespaces){
    let n_li = document.createElement("li");
    n_li.id=ns.id;
    n_li.innerText=ns.name;
    nsp_u.appendChild(n_li);
  }
  let n_li = document.createElement("li");
  n_li.innerText='+';
  n_li.id = "n_ns";
  n_li.onclick = addNs;
  nsp_u.appendChild(n_li);
}

async function submit(){
  const n_username = document.getElementById("n_username");
  let username = n_username.innerText;
  if(username === ""){
    alert("pls enter username");
    return;
  }
  await mActor.sign(username, "", "a man");
  alert("succcess");
  signup_form.display = 'none';
  let userInfoResp = await mActor.getUserInfo();
  console.log(userInfoResp);
  userInfo = userInfoResp.data;
  console.log(userInfo);
  uActor = createUserActor(identity, userInfo.id);
  // 登陆按钮隐藏，显示个人头像按钮
  loginButton.innerText = "Logout";
  username.innerText = userInfo.name;
  const welcome = document.getElementById("welcome");
  welcome.innerText = "Welcome " + userInfo.name;
}

async function addNs(){
  let n_li = document.getElementById("n_ns");
  // 录入名称、简介。提交创建。重载nsp页面
  n_li.innerHTML = "<div></div>"
}

// 指定命名空间的文章列表
async function ns_list(){

}

// 创建该命名空间下文章
async function c_artical(){

}

// 获取文章信息
async function artical(){
  
}

loginButton.onclick = login;
namespaceButton.onclick = namespaces;
s_submit.onclick = submit;